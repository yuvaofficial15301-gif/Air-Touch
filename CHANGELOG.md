# Changelog

## Unreleased (installer / platform rewrite on top of 3.0.0)

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
