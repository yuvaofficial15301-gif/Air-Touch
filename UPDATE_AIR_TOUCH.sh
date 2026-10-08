#!/usr/bin/env bash
# Upgrade dependencies within the pins in requirements.txt (MediaPipe stays 0.10.14).
set -u
AT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$AT_ROOT" || exit 1
. "$AT_ROOT/bootstrap/find_python.sh"
at_find_python
PY="${AT_PY:-$AT_FALLBACK_PY}"
[ -z "$PY" ] && { echo "UPDATE FAILED: Python was not found."; exit 3; }
"$PY" "$AT_ROOT/bootstrap/install_runtime.py" --mode update
rc=$?
[ $rc -eq 0 ] && echo "UPDATE COMPLETE" || echo "UPDATE FAILED (exit code $rc)"
exit $rc
