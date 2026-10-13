#!/usr/bin/env bash
# Air Touch - installer and launcher for Linux and macOS.
#   bash START_AIR_TOUCH.sh                 install/verify, then start Air Touch
#   bash START_AIR_TOUCH.sh --install-only  install/verify only
#   bash START_AIR_TOUCH.sh --update        upgrade dependencies within the pins
#   bash START_AIR_TOUCH.sh --engine-only   start the engine without the console
# Self-contained on purpose: it needs nothing but this file and bootstrap/*.py.
set -u
AT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$AT_ROOT" || exit 1
MODE="${1:-start}"

echo "================================================================"
echo "                         AIR TOUCH"
echo "================================================================"

# --- integrity check: a partial clone/upload is the most common cause of odd errors
missing=""
if [ ! -f "$AT_ROOT/MANIFEST.txt" ]; then
    missing=" MANIFEST.txt"
else
    while IFS= read -r f || [ -n "$f" ]; do
        case "$f" in ''|\#*) continue ;; esac
        [ -f "$AT_ROOT/$f" ] || missing="$missing $f"
    done < "$AT_ROOT/MANIFEST.txt"
fi
if [ -n "$missing" ]; then
    echo "================================================================"
    echo " INSTALLATION FAILED - your copy of Air Touch is INCOMPLETE"
    echo "================================================================"
    echo " These files are missing:"
    for f in $missing; do echo "   $f"; done
    echo
    echo " Cause: not every file/folder reached GitHub (or your clone). Fix:"
    echo "   1. Use the extracted Air-Touch zip directly, or"
    echo "   2. Push ALL files: git add -A && git commit -m ... && git push   (check: git ls-files)"
    exit 1
fi

# --- engine only: no installer, just run
if [ "$MODE" = "--engine-only" ]; then
    if [ ! -x .venv/bin/python ]; then
        echo "Air Touch is not installed yet. Run: bash START_AIR_TOUCH.sh"
        exit 1
    fi
    export PYTHONPATH="$AT_ROOT/src"
    exec .venv/bin/python -m airtouch.cli
fi

# --- find any Python able to run the installer (it finds/gets a compatible one itself)
PY=""; FALLBACK=""
for c in python3.12 python3.11 python3.10 \
         /opt/homebrew/bin/python3.12 /usr/local/bin/python3.12 \
         /opt/homebrew/bin/python3.11 /usr/local/bin/python3.11 \
         python3 python; do
    p="$(command -v "$c" 2>/dev/null)" || continue
    out="$("$p" "$AT_ROOT/bootstrap/pycheck.py" 2>/dev/null)" || out=""
    if [ -n "$out" ]; then PY="$out"; break; fi
    [ -z "$FALLBACK" ] && FALLBACK="$p"
done
PY="${PY:-$FALLBACK}"
if [ -z "$PY" ]; then
    echo "INSTALLATION FAILED"
    echo "Python was not found. Install Python 3 first (Linux: 'sudo apt install python3 python3-venv';"
    echo "macOS: 'brew install python@3.12'), then run this script again."
    exit 3
fi

if [ "$MODE" = "--update" ]; then
    "$PY" "$AT_ROOT/bootstrap/install_runtime.py" --mode update
    rc=$?
    [ $rc -eq 0 ] && echo "UPDATE COMPLETE" || echo "UPDATE FAILED (exit code $rc)"
    exit $rc
fi

"$PY" "$AT_ROOT/bootstrap/install_runtime.py" --mode install
rc=$?
if [ $rc -ne 0 ]; then
    echo "Air Touch was NOT started because installation failed (exit code $rc)."
    exit $rc
fi
[ "$MODE" = "--install-only" ] && exit 0

echo; echo "Starting Air Touch...  (Q/ESC closes the camera window; Ctrl+C stops the console)"
export PYTHONPATH="$AT_ROOT/src"
exec "$AT_ROOT/.venv/bin/python" -m airtouch.cli --ui
