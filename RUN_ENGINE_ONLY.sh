#!/usr/bin/env bash
# Start only the engine (camera window, no developer console).
AT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$AT_ROOT" || exit 1
if [ ! -x .venv/bin/python ]; then
    echo "Air Touch is not installed yet. Run: bash START_AIR_TOUCH.sh"
    exit 1
fi
export PYTHONPATH="$AT_ROOT/src"
exec .venv/bin/python -m airtouch.cli
