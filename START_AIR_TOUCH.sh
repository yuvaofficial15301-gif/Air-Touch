#!/usr/bin/env bash
# Air Touch - installer and launcher for Linux and macOS.
#   bash START_AIR_TOUCH.sh                 install/verify, then start Air Touch
#   bash START_AIR_TOUCH.sh --install-only  install/verify only
set -u
AT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$AT_ROOT" || exit 1
. "$AT_ROOT/bootstrap/find_python.sh"

echo "================================================================"
echo "                         AIR TOUCH"
echo "================================================================"

at_find_python
PY="${AT_PY:-$AT_FALLBACK_PY}"
if [ -z "$PY" ]; then
    echo "INSTALLATION FAILED"
    echo "Python was not found. Install Python 3.12 (Linux: your package manager, e.g."
    echo "'sudo apt install python3.12 python3.12-venv'; macOS: 'brew install python@3.12'),"
    echo "then run this script again."
    exit 3
fi

"$PY" "$AT_ROOT/bootstrap/install_runtime.py" --mode install
rc=$?
if [ $rc -ne 0 ]; then
    echo "Air Touch was NOT started because installation failed (exit code $rc)."
    exit $rc
fi
[ "${1:-}" = "--install-only" ] && exit 0

echo; echo "Starting Air Touch...  (Q/ESC closes the camera window; Ctrl+C stops the console)"
export PYTHONPATH="$AT_ROOT/src"
exec "$AT_ROOT/.venv/bin/python" -m airtouch.cli --ui
