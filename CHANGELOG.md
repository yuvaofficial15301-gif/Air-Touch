# Changelog

## 3.1.1 — lean install and disk-space handling

### Fixed
- Install no longer drags in `jax`/`jaxlib`/`scipy`/`ml_dtypes` (declared by MediaPipe 0.10.14 but unused by hand tracking): MediaPipe is installed with `--no-deps` and its real dependencies are listed in `requirements.txt`. ~1.0 GB → ~0.46 GB, no multi-minute pip backtracking.
- `No space left on device` was reported as "Package: unknown". Now: free-space pre-check (exit code 8), a clear explanation with fixes, and a consented cache-clear + retry.
- Launchers list every missing file (`MANIFEST.txt`) when the copy/clone is incomplete.

## 3.1.0 — adaptive display, hardware-aware, validated config

### Added
- Screen/hardware adaptation: preview window sized and placed from the screen size, live screen-size refresh, hand tracking on a downscaled frame (`tracking.process_width`), `tracking.model_complexity: "auto"`, HUD with FPS and live gestures, closing the preview window stops the engine.
- Config validation (`config:` warnings, precise JSON errors) and keys `tracking.process_width`, `preview.max_screen_fraction`, `preview.position`.
- Rotating log file `logs/airtouch.log`, `--verbose`, `--version`.
- One-run setup on a new PC: consented installation of Linux system packages (libgl1, libglib2.0-0, python3-tk, python3-venv) and the Windows VC++ runtime (signature-checked); doctor prints the exact fix for native-library errors.
- Responsive light/dark developer console showing FPS, frame size, preview size, platform.
- GitHub Actions CI (Ubuntu/Windows/macOS), `CONTRIBUTING.md`, issue template.

## 3.0.x installer / platform rewrite

### Fixed
- Installer no longer fails when only `python`/`python3` (not the `py` launcher) is available; Windows can install Python 3.12 (with consent, signature-checked, per-user).
- MediaPipe is no longer uninstalled/reinstalled on every start; wrong versions are repaired only when detected.
- `requirements.txt` now matches what MediaPipe 0.10.14 needs (`opencv-contrib-python`, `numpy<2`); stray `opencv-python*` packages are removed.
- Camera errors were raised inside a background thread and lost; they are now reported with guidance (`CameraError`).
- PyAutoGUI fail-safe used to kill the engine thread silently; it now stops Air Touch with a message.
- `none` action returned `False` (late-binding lambda bug).
- Engine/CLI no longer crash on import or start where PyAutoGUI cannot load (headless Linux, missing `python3-tk` which makes PyAutoGUI call `sys.exit()`).
- CLI busy-wait (100% CPU) replaced with a sleep loop.
- Console now rejects non-local `Host` headers and cross-origin POSTs.

- POSIX launchers are now self-contained (`START_AIR_TOUCH.sh --update/--engine-only`); a missing helper file previously crashed with `command not found` / `unbound variable`. All launchers now detect an incomplete copy and say so.
- Windows `find_python.bat`: avoids the `for /f` + quoted-command trap and `%*` in subroutines; PowerShell installer no longer assigns to the automatic `$args` variable.
- Linux/macOS: with consent, a standalone Python 3.12 is downloaded to `.python/` when the system has none (e.g. Kali with Python 3.13).

### Changed (behaviour)
- `thumbs_up → play_pause`, `next`, `previous` now press the OS media keys (previously no-ops).
- `drag` is idempotent (mouse button no longer pressed twice).
- Camera backend is chosen per OS (was hard-coded `CAP_DSHOW`, Windows-only); Windows still prefers DirectShow.
- `uvicorn[standard]` → `uvicorn` (extras unused).
- `pyproject.toml`: dependencies now declared (read from `requirements.txt`), `requires-python >=3.10,<3.13`, `airtouch` console script.

### Added
- `platform_info`, `adapters/` (PlatformAdapter, PyAutoGUIAdapter, registry), `camera.py`, `doctor.py`.
- `camera.auto_fallback` config key, `--doctor`, `--list-cameras`, `--config`, `python -m airtouch`.
- Linux/macOS launchers (`START_AIR_TOUCH.sh`, `UPDATE_AIR_TOUCH.sh`, `RUN_ENGINE_ONLY.sh`).
- pytest suite, `.gitattributes` (CRLF for `.bat`/`.ps1`), fuller `.gitignore`, full README.

### Known limitations
- `scroll` only scrolls up; `mouse.enabled` in `config.json` is not read by the engine.
