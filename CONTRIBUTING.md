# Contributing to Air Touch

Thanks for helping! Air Touch is MIT-licensed; contributions are accepted under the same license.

## Setup

```bash
git clone https://github.com/yuvaofficial15301-gif/Air-Touch.git
cd Air-Touch
bash START_AIR_TOUCH.sh --install-only      # Windows: INSTALL_AIR_TOUCH.bat
source .venv/bin/activate                   # Windows: .venv\Scripts\activate
pip install -e ".[dev]"
pytest -q
```

## Guidelines

- Keep changes small and focused; one topic per pull request.
- Add or update a test for behaviour you change (`tests/`). Hardware-free tests use `tests/helpers.py` (`RecordingAdapter`, synthetic hands).
- Keep the core platform-independent: OS actions belong in an adapter (`src/airtouch/adapters/`).
- Keep `mediapipe==0.10.14` unless you are porting the engine to the MediaPipe Tasks API; if you change it, also change `REQUIRED_MEDIAPIPE` in `src/airtouch/doctor.py` (a test checks they match).
- `.bat`/`.ps1` files must stay CRLF (`.gitattributes` enforces it).
- Only mark a platform "Stable" in the README after it was tested on that platform.
- Never commit `.venv/`, `.python/`, `logs/`, caches or personal paths.

## Reporting bugs

Open an issue and paste the output of `python air_touch.py --doctor` (see the issue template).
