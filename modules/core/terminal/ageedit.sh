# Edit a passphrase-encrypted age file in nvim: decrypt to tmpfs, edit, re-encrypt in place.
# Creates the file if it doesn't exist.
[ $# -eq 1 ] || { echo "usage: ageedit FILE" >&2; exit 2; }
file=$1

tmp=$(mktemp -p "${XDG_RUNTIME_DIR:-/dev/shm}")
trap 'shred -u "$tmp" 2>/dev/null || rm -f "$tmp"' EXIT

if [ -e "$file" ]; then
  age -d -o "$tmp" "$file"
fi
before=$(sha256sum <"$tmp")

# No swap/undo/backup/viminfo, so plaintext doesn't leak to disk
nvim -n -i NONE -c 'set noundofile nobackup noswapfile' "$tmp"

if [ "$(sha256sum <"$tmp")" = "$before" ]; then
  echo "ageedit: no changes" >&2
  exit 0
fi

age -p -o "$file.new" "$tmp"
mv "$file.new" "$file"
