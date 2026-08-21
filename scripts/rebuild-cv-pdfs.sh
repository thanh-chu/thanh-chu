#!/bin/bash
# Regenerates static/cv/<name>.pdf for every cv-sources/<name>.html that is
# new or has been modified since its PDF was last built.
# Triggered automatically by the com.thanhchu.cv-pdf-watcher launchd agent
# whenever anything in cv-sources/ changes; safe to also run by hand.

REPO_DIR="/Users/chuhathanh/Workspaces/thanhchu.github.io"
SRC_DIR="$REPO_DIR/cv-sources"
DEST_DIR="$REPO_DIR/static/cv"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

mkdir -p "$DEST_DIR"

shopt -s nullglob
for html in "$SRC_DIR"/*.html; do
  base="$(basename "$html" .html)"
  pdf="$DEST_DIR/$base.pdf"

  if [ "$html" -nt "$pdf" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Rebuilding $base.pdf from $base.html"
    "$CHROME" --headless --disable-gpu --no-pdf-header-footer \
      --print-to-pdf="$pdf" --print-to-pdf-no-header \
      "file://$html" 2>>"$HOME/Library/Logs/cv-pdf-watcher.err.log"

    if [ -s "$pdf" ]; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')]   OK -> $pdf"
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')]   FAILED -> $pdf (see cv-pdf-watcher.err.log)"
    fi
  fi
done
