#!/usr/bin/env bash
# Upgrade dependencies within the pins in requirements.txt (MediaPipe stays 0.10.14).
exec bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/START_AIR_TOUCH.sh" --update
