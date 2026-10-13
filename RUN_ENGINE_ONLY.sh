#!/usr/bin/env bash
# Start only the engine (camera window, no developer console).
exec bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/START_AIR_TOUCH.sh" --engine-only
