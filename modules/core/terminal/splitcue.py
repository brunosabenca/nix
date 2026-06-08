#!/usr/bin/env python3
"""Split a FLAC+CUE into individual Opus tracks using ffmpeg."""
import re
import subprocess
import sys
import os

flac_path, cue_path, out_dir = sys.argv[1], sys.argv[2], sys.argv[3]

# Parse CUE
album_artist = ""
album_title = ""
album_date = ""
album_genre = ""
tracks = []
current = {}

with open(cue_path, encoding="utf-8", errors="replace") as f:
    for line in f:
        line = line.strip()
        m = re.match(r'REM DATE\s+"?(.+?)"?$', line)
        if m:
            album_date = m.group(1)
        m = re.match(r'REM GENRE\s+"?(.+?)"?$', line)
        if m:
            album_genre = m.group(1)
        m = re.match(r'PERFORMER "(.+)"', line)
        if m and not current:
            album_artist = m.group(1)
        m = re.match(r'TITLE "(.+)"', line)
        if m and not current:
            album_title = m.group(1)
        m = re.match(r"TRACK (\d+) AUDIO", line)
        if m:
            if current:
                tracks.append(current)
            current = {"num": int(m.group(1)), "title": "", "artist": album_artist, "start": None}
        m = re.match(r'TITLE "(.+)"', line)
        if m and current:
            current["title"] = m.group(1)
        m = re.match(r'PERFORMER "(.+)"', line)
        if m and current:
            current["artist"] = m.group(1)
        m = re.match(r"INDEX 01 (\d+):(\d+):(\d+)", line)
        if m and current:
            mm, ss, ff = int(m.group(1)), int(m.group(2)), int(m.group(3))
            current["start"] = mm * 60 + ss + ff / 75.0

if current:
    tracks.append(current)

os.makedirs(out_dir, exist_ok=True)

for i, track in enumerate(tracks):
    safe_title = re.sub(r'[<>:"/\\|?*]', "_", track["title"])
    out_file = os.path.join(out_dir, f"{track['num']:02d} - {safe_title}.opus")
    end = tracks[i + 1]["start"] if i + 1 < len(tracks) else None

    cmd = ["ffmpeg", "-y", "-i", flac_path, "-ss", str(track["start"])]
    if end:
        cmd += ["-to", str(end)]
    cmd += [
        "-c:a", "libopus", "-b:a", "128k", "-vn",
        "-metadata", f"title={track['title']}",
        "-metadata", f"artist={track['artist']}",
        "-metadata", f"album={album_title}",
        "-metadata", f"albumartist={album_artist}",
        "-metadata", f"tracknumber={track['num']}",
        "-metadata", f"totaltracks={len(tracks)}",
    ]
    if album_date:
        cmd += ["-metadata", f"date={album_date}"]
    if album_genre:
        cmd += ["-metadata", f"genre={album_genre}"]
    cmd.append(out_file)

    print(f"[{track['num']:02d}/{len(tracks)}] {track['title']}")
    subprocess.run(cmd, check=True, stderr=subprocess.DEVNULL)

print(f"Done — {len(tracks)} tracks written to {out_dir}")
