"""Render a Google Calendar ICS feed to a grayscale PNG for an e-ink Kindle."""

import argparse
import calendar
import math
import os
import json
import urllib.parse
import urllib.request
from datetime import date, datetime, time, timedelta
from zoneinfo import ZoneInfo

import recurring_ical_events
from icalendar import Calendar
from PIL import Image, ImageDraw, ImageFont

parser = argparse.ArgumentParser()
parser.add_argument("--out", required=True)
parser.add_argument("--width", type=int, required=True)
parser.add_argument("--height", type=int, required=True)
parser.add_argument("--tz", required=True)
parser.add_argument("--font", required=True)
parser.add_argument("--font-bold", required=True)
parser.add_argument("--days", type=int, default=30, help="agenda look-ahead")
parser.add_argument("--lat", type=float, help="latitude, enables weather")
parser.add_argument("--lon", type=float, help="longitude, enables weather")
parser.add_argument("--today", help="pretend today is YYYY-MM-DD (for testing)")
args = parser.parse_args()

tz = ZoneInfo(args.tz)
now = datetime.now(tz)
if args.today:
    now = datetime.combine(date.fromisoformat(args.today), time(12, 0), tz)
today = now.date()

url_file = os.path.join(os.environ["CREDENTIALS_DIRECTORY"], "ics-url")
with open(url_file) as f:
    url = f.read().strip()
# Last good copy of the feed. Must not live in the served directory: it holds
# the full event details.
cache_file = os.path.join(os.environ.get("CACHE_DIRECTORY", os.path.dirname(args.out)), "calendar.ics")
stale_since = None  # set when the feed is unreachable
try:
    with urllib.request.urlopen(url, timeout=30) as resp:
        raw = resp.read()
    cal = Calendar.from_ical(raw)
    with open(cache_file + ".tmp", "wb") as f:
        f.write(raw)
    os.replace(cache_file + ".tmp", cache_file)
except Exception as exc:  # keep showing the last good copy, and say so
    print("calendar unavailable:", exc)
    stale_since = datetime.fromtimestamp(os.path.getmtime(cache_file), tz) \
        if os.path.exists(cache_file) else now
    cal = None
    if os.path.exists(cache_file):
        with open(cache_file, "rb") as f:
            cal = Calendar.from_ical(f.read())

# WMO weather interpretation codes, as used by Open-Meteo
WMO = {
    0: "Clear", 1: "Mostly clear", 2: "Part cloud", 3: "Overcast",
    45: "Fog", 48: "Fog", 51: "Drizzle", 53: "Drizzle", 55: "Drizzle",
    56: "Frz drizzle", 57: "Frz drizzle", 61: "Light rain", 63: "Rain",
    65: "Heavy rain", 66: "Frz rain", 67: "Frz rain", 71: "Light snow",
    73: "Snow", 75: "Heavy snow", 77: "Snow grains", 80: "Showers",
    81: "Showers", 82: "Heavy showers", 85: "Snow showers",
    86: "Snow showers", 95: "Thunder", 96: "Thunder", 99: "Thunder",
}


def fetch_weather():
    if args.lat is None or args.lon is None:
        return None
    try:
        query = urllib.parse.urlencode({
            "latitude": args.lat,
            "longitude": args.lon,
            "current": "temperature_2m,weather_code",
            "daily": "weather_code,temperature_2m_max,temperature_2m_min,"
                     "precipitation_probability_max",
            "timezone": args.tz,
            "forecast_days": 7,
        })
        url = "https://api.open-meteo.com/v1/forecast?" + query
        with urllib.request.urlopen(url, timeout=20) as r:
            data = json.load(r)
        daily = {
            date.fromisoformat(d): (
                data["daily"]["weather_code"][i],
                round(data["daily"]["temperature_2m_max"][i]),
                round(data["daily"]["temperature_2m_min"][i]),
                data["daily"]["precipitation_probability_max"][i],
            )
            for i, d in enumerate(data["daily"]["time"])
        }
        return {
            "now": (data["current"]["weather_code"],
                    round(data["current"]["temperature_2m"])),
            "daily": daily,
        }
    except Exception as exc:  # weather is optional, never break the calendar
        print("weather unavailable:", exc)
        return None


def icon_kind(code):
    if code in (0, 1):
        return "clear"
    if code == 2:
        return "partly"
    if code == 3:
        return "cloud"
    if code in (45, 48):
        return "fog"
    if code in (71, 73, 75, 77, 85, 86):
        return "snow"
    if code in (95, 96, 99):
        return "thunder"
    if code in (51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82):
        return "rain"
    return "cloud"


def draw_cloud(d, x, y, s, fill=60, halo=False):
    pad = s * 0.04 if halo else 0
    colour = 255 if halo else fill
    d.ellipse((x + .10 * s - pad, y + .40 * s - pad, x + .46 * s + pad, y + .76 * s + pad), fill=colour)
    d.ellipse((x + .28 * s - pad, y + .20 * s - pad, x + .68 * s + pad, y + .66 * s + pad), fill=colour)
    d.ellipse((x + .54 * s - pad, y + .36 * s - pad, x + .90 * s + pad, y + .76 * s + pad), fill=colour)
    d.rectangle((x + .28 * s - pad, y + .46 * s, x + .72 * s + pad, y + .76 * s + pad), fill=colour)


def draw_sun(d, cx, cy, r, ray, width):
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=0)
    for i in range(8):
        a = i * math.pi / 4
        d.line((cx + math.cos(a) * (r + width * 1.5), cy + math.sin(a) * (r + width * 1.5),
                cx + math.cos(a) * ray, cy + math.sin(a) * ray), fill=0, width=width)


def draw_icon(d, kind, x, y, s):
    """Weather icon in the s x s box with top-left (x, y)."""
    w = max(3, int(s / 11))
    if kind == "clear":
        draw_sun(d, x + s / 2, y + s / 2, s * .22, s * .46, w)
    elif kind == "partly":
        draw_sun(d, x + s * .34, y + s * .32, s * .20, s * .40, w)
        draw_cloud(d, x + s * .14, y + s * .22, s * .86, halo=True)
        draw_cloud(d, x + s * .14, y + s * .22, s * .86)
    elif kind == "cloud":
        draw_cloud(d, x, y + s * .06, s)
    elif kind == "fog":
        draw_cloud(d, x, y - s * .06, s * .9)
        for i, f in enumerate((.74, .86, .98)):
            d.line((x + s * (.16 + .06 * (i % 2)), y + s * f * .98, x + s * (.84 - .06 * (i % 2)), y + s * f * .98),
                   fill=60, width=w)
    else:
        draw_cloud(d, x, y - s * .06, s * .94)
        if kind == "rain":
            for f in (.30, .50, .70):
                d.line((x + s * f + s * .06, y + s * .74, x + s * f - s * .02, y + s * .92), fill=0, width=w)
        elif kind == "snow":
            for f in (.28, .50, .72):
                r = max(4, int(s * .07))
                d.ellipse((x + s * f - r, y + s * .84 - r, x + s * f + r, y + s * .84 + r), fill=0)
        elif kind == "thunder":
            d.polygon([(x + s * .52, y + s * .62), (x + s * .38, y + s * .86), (x + s * .50, y + s * .86),
                       (x + s * .42, y + s * 1.04), (x + s * .64, y + s * .78), (x + s * .52, y + s * .78),
                       (x + s * .60, y + s * .62)], fill=0)


weather = fetch_weather()

first = today.replace(day=1)
last = first.replace(day=calendar.monthrange(first.year, first.month)[1])
window_start = min(first, today)
window_end = max(last, today + timedelta(days=args.days)) + timedelta(days=1)

events = []  # (start_dt, end_dt, all_day, summary)
for ev in (recurring_ical_events.of(cal).between(window_start, window_end) if cal else []):
    start = ev["DTSTART"].dt
    end = ev["DTEND"].dt if "DTEND" in ev else start
    all_day = not isinstance(start, datetime)
    if all_day:
        start = datetime.combine(start, time.min, tz)
        end = datetime.combine(end, time.min, tz)
    else:
        start, end = start.astimezone(tz), end.astimezone(tz)
    events.append((start, end, all_day, str(ev.get("SUMMARY", "(no title)"))))
events.sort(key=lambda e: (e[0], not e[2]))


def covers(ev, day):
    start, end, all_day, _ = ev
    day_start = datetime.combine(day, time.min, tz)
    day_end = day_start + timedelta(days=1)
    return start < day_end and (end > day_start or start >= day_start)


def last_day(ev):
    start, end, all_day, _ = ev
    if end <= start:
        return start.date()
    return (end - timedelta(microseconds=1)).date()


W, H = args.width, args.height
img = Image.new("L", (W, H), 255)
d = ImageDraw.Draw(img)


def font(size, bold=False):
    return ImageFont.truetype(args.font_bold if bold else args.font, size)


def fit(text, fnt, max_w):
    if d.textlength(text, font=fnt) <= max_w:
        return text
    while text and d.textlength(text + "…", font=fnt) > max_w:
        text = text[:-1]
    return text + "…"


M = W // 24
y = M

# Header
d.text((M, y), today.strftime("%A"), font=font(W // 14, True), fill=0)
y += W // 14 + 8
d.text((M, y), today.strftime("%-d %B %Y"), font=font(W // 22), fill=60)

if weather:
    code, temp = weather["now"]
    temp_font = font(W // 10, True)
    d.text((W - M, M), f"{temp}°", font=temp_font, fill=0, anchor="ra")
    # Sized so even the tallest icons (sun rays, thunder bolt) end above the
    # conditions line below the temperature.
    isz = int(W * 0.09)
    draw_icon(d, icon_kind(code), W - M - d.textlength(f"{temp}°", font=temp_font) - isz - W // 40,
              M, isz)
    sub = WMO.get(code, "")
    if today in weather["daily"]:
        _, hi, lo, _ = weather["daily"][today]
        sub += f"  {hi}°/{lo}°"
    d.text((W - M, M + W // 10 + 4), sub, font=font(W // 32), fill=60, anchor="ra")
elif args.lat is not None:  # weather is configured but the fetch failed
    d.text((W - M, M + W // 30), "weather unavailable", font=font(W // 36), fill=120, anchor="ra")
y += W // 22 + M
if weather or args.lat is not None:  # keep the layout the same without weather
    y = max(y, M + W // 10 + W // 32 + 4 + M)

# Month grid
cell_w = (W - 2 * M) // 7
weeks = calendar.Calendar(firstweekday=0).monthdatescalendar(first.year, first.month)
cell_h = min(int(cell_w * 0.8), 600 // len(weeks))
for i, name in enumerate(calendar.day_abbr):
    d.text((M + i * cell_w + cell_w // 2, y), name, font=font(W // 36, True),
           fill=20 if i >= 5 else 80, anchor="ma")
y += W // 36 + 14
for week in weeks:
    for i, day in enumerate(week):
        x = M + i * cell_w
        in_month = day.month == first.month
        count = sum(covers(e, day) for e in events) if in_month else 0
        if day == today:
            d.rounded_rectangle((x + 4, y + 2, x + cell_w - 4, y + cell_h - 2), radius=10, fill=0)
        if day == today:
            colour = 255
        elif not in_month:
            colour = 145
        elif day < today:
            colour = 110  # past days of this month recede
        else:
            colour = 0
        d.text((x + cell_w // 2, y + cell_h // 2 - 4), str(day.day),
               font=font(W // 24, day == today), fill=colour, anchor="mm")
        # one dot per event, up to three, so busy days stand out
        n = min(count, 3)
        r, gap = 6, 20
        for k in range(n):
            cx = x + cell_w // 2 + int((k - (n - 1) / 2) * gap)
            cy = y + cell_h - 16
            d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=255 if day == today else 0)
    y += cell_h
y += M // 2
d.line((M, y, W - M, y), fill=0, width=3)
y += M // 2

# Agenda
day_font, time_font, title_font = font(W // 26, True), font(W // 32), font(W // 30)
row = W // 30 + 14
head = W // 26 + 10
gap = 10
bottom = H - M - W // 40 - 16  # keep clear of the footer
time_w = max(d.textlength("all day", font=time_font), d.textlength("00:00", font=time_font))
title_x = M + 20 + int(time_w) + 24
asc_time, asc_title = time_font.getmetrics()[0], title_font.getmetrics()[0]

# Multi-day events are listed once, on the first day they are visible.
shown = {}
for ev in events:
    if last_day(ev) < today:
        continue
    shown.setdefault(max(ev[0].date(), today), []).append(ev)

# Flat list of (kind, payload, height) so overflow can be handled up front.
items = []
for offset in range(args.days):
    day = today + timedelta(days=offset)
    todays = shown.get(day, [])
    if not todays and offset > 0:
        continue
    if not todays:  # only ever Today: heading and message share one line
        items.append(("head_none", (offset, day), head + gap))
        continue
    items.append(("head", (offset, day), head))
    for k, ev in enumerate(todays):
        items.append(("event", (day, ev), row + (gap if k == len(todays) - 1 else 0)))

avail = bottom - y
n = len(items)
if sum(h for _, _, h in items) > avail:
    n = 0
    used = row  # reserve a row for "+N more"
    while n < len(items) and used + items[n][2] <= avail:
        used += items[n][2]
        n += 1
    while n > 0 and items[n - 1][0] == "head":  # never leave a day heading alone
        n -= 1
hidden = sum(1 for kind, _, _ in items[n:] if kind == "event")

for kind, payload, h in items[:n]:
    if kind == "head":
        offset, day = payload
        label = "Today" if offset == 0 else "Tomorrow" if offset == 1 else day.strftime("%A, %-d %b")
        d.text((M, y), label, font=day_font, fill=0)
        # Today's forecast is already in the header.
        if weather and offset > 0 and day in weather["daily"]:
            code, hi, lo, rain = weather["daily"][day]
            text = f"{hi}°/{lo}°"
            if rain and rain >= 30:
                text += f"  {rain}%"
            d.text((W - M, y + 4), text, font=time_font, fill=90, anchor="ra")
            isz = W // 22
            draw_icon(d, icon_kind(code), W - M - d.textlength(text, font=time_font) - isz - 12, y, isz)
    elif kind == "head_none":
        offset, day = payload
        label = "Today" if offset == 0 else day.strftime("%A, %-d %b")
        msg = "calendar offline" if cal is None else "nothing scheduled"
        base = y + day_font.getmetrics()[0]
        d.text((M, base), label, font=day_font, fill=0, anchor="ls")
        d.text((M + d.textlength(label, font=day_font) + 20, base), msg, font=title_font, fill=130, anchor="ls")
    else:
        day, (start, end, all_day, summary) = payload
        when = "all day" if all_day or start.date() < day else start.strftime("%H:%M")
        base = y + max(asc_time, asc_title)  # shared baseline for time and title
        d.text((M + 20, base), when, font=time_font, fill=90, anchor="ls")
        suffix = ""
        if last_day((start, end, all_day, summary)) > day:
            suffix = " · until " + last_day((start, end, all_day, summary)).strftime("%a %-d")
        room = W - M - title_x - d.textlength(suffix, font=title_font)
        d.text((title_x, base), fit(summary, title_font, room) + suffix, font=title_font, fill=0, anchor="ls")
    y += h
if hidden:
    d.text((M + 20, y), f"+{hidden} more", font=time_font, fill=90)

footer = "updated " + now.strftime("%a %H:%M")
if stale_since:
    footer += " · calendar offline since " + stale_since.strftime("%a %H:%M")
d.text((W - M, H - M), footer, font=font(W // 40), fill=60 if stale_since else 120, anchor="rd")

tmp = args.out + ".tmp"
img.save(tmp, format="PNG")
os.replace(tmp, args.out)
