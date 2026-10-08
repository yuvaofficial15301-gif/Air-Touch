# Air Touch

**Offline hand-gesture control framework** — control your computer (or your own app) with your hand in front of a webcam.

Created and maintained by **Yuvaraj N. (Yuva)** · MIT License

---

## Table of contents

[Overview](#overview) · [Features](#features) · [Architecture](#architecture) · [Supported Platforms](#supported-platforms) · [Requirements](#requirements) · [Quick Start](#quick-start) · [Windows](#windows-installation) · [Linux](#linux-installation) · [macOS](#macos-installation) · [Android](#android-status) · [First Run](#first-run) · [Subsequent Runs](#subsequent-runs) · [Installation Internals](#installation-internals) · [Python Environment](#python-environment) · [Dependencies](#dependencies) · [MediaPipe](#mediapipe-compatibility) · [Camera](#camera-setup) · [Gestures](#gesture-controls) · [Configuration](#configuration) · [Runtime Modes](#runtime-modes) · [Update](#update) · [Troubleshooting](#troubleshooting) · [Clean Reinstall](#clean-reinstallation) · [Developer Integration](#developer-integration) · [Custom Adapters](#custom-platform-adapters) · [Project Structure](#project-structure) · [Development](#development-setup) · [Testing](#testing) · [Security / Privacy](#security--privacy) · [Permissions](#permissions) · [Support Matrix](#platform-support-matrix) · [FAQ](#faq) · [License](#license) · [Credits](#credits)

---

## Overview

Air Touch watches your webcam, tracks your hands with Google's MediaPipe Hands, classifies what your hand is doing (pointing, pinching, fist, open palm, ...) and turns that into **events** and **actions**: move the mouse, click, scroll, drag, press media keys — or anything *you* register in your own application.

Everything runs locally on your computer.

## Features

- Webcam hand tracking (up to 2 hands, left/right aware)
- Cursor control with smoothing and edge margins, mapped to your real screen size
- Gestures: index pinch, middle pinch, two-finger, fist, open palm, thumbs-up, pointing
- Two-hand events: both open, both fist, hands together, both pinch
- Every gesture → action mapping is editable in `config.json`
- Register your own actions in Python (`register_action`)
- Local developer console (live gesture monitor) at `http://127.0.0.1:8765`
- Platform adapter layer: gesture logic is separate from OS input
- One-command installer that finds/creates Python, builds `.venv`, installs a **compatible MediaPipe** and verifies it
- Built-in runtime doctor (`--doctor`) and camera lister (`--list-cameras`)

## Architecture

```text
Camera ─▶ OpenCV ─▶ MediaPipe Hands ─▶ Gesture classifier ─▶ GestureEvent
                                                                  │
                                                                  ▼
                                       config.json mapping ─▶ Action Registry
                                                                  │
                                                                  ▼
                                                          Platform Adapter
                                         (PyAutoGUI desktop adapter │ your adapter)
                                                                  │
                                                                  ▼
                                                           Operating system
```

Launch-time flow:

```text
Launcher (.bat / .sh) ─▶ find Python 3.10–3.12 ─▶ bootstrap/install_runtime.py
      ─▶ .venv + pinned deps + MediaPipe check ─▶ airtouch.doctor ─▶ airtouch.cli --ui
```

| Layer | File | Role |
|-------|------|------|
| Platform detection | `src/airtouch/platform_info.py` | OS, CPU arch, Python, session type (X11/Wayland/headless), support level, capabilities |
| Adapters | `src/airtouch/adapters/` | `PlatformAdapter` base (no-op), `PyAutoGUIAdapter` (Windows/Linux/macOS), `select_adapter`, `register_adapter` |
| Camera | `src/airtouch/camera.py` | Backend choice per OS, camera listing, fallback, diagnostics |
| Gesture core | `src/airtouch/gestures.py`, `engine.py`, `events.py` | Classification, debounce, cursor mapping, event emission |
| Actions | `src/airtouch/actions.py` | Action-name → callable registry, built on the adapter |
| Config | `src/airtouch/config.py` | Defaults + `config.json` merge |
| Console / CLI | `src/airtouch/web.py`, `cli.py`, `ui/index.html` | Local dashboard and command line |
| Verification | `src/airtouch/doctor.py` | Runtime check → `AIR TOUCH RUNTIME READY` |
| Installer | `bootstrap/` | Python discovery/bootstrap, venv, dependencies, MediaPipe |

## Supported Platforms

Honest status levels: **Stable** · **Experimental** · **Planned** · **Unsupported**

| Platform | Status | Notes |
|----------|--------|-------|
| Windows 10/11 x64 | **Stable** (primary target) | Full desktop control. See [Verification status](#verification-status) for what was re-tested after the installer rewrite. |
| Linux x64 | **Experimental** | Needs an **X11** session, `python3-tk`. Wayland = tracking/events only (no mouse control). |
| macOS | **Experimental** (untested) | Code path exists (AVFoundation + PyAutoGUI); needs Camera + Accessibility permission. |
| Android | **Planned** | No adapter yet. The installer refuses to run and says so. |
| iOS / others | **Unsupported** | |

32-bit systems and Python 3.9 / 3.13+ are not supported (MediaPipe 0.10.14 has no wheels for them).

## Requirements

- A webcam
- 64-bit Windows 10/11, Linux (X11) or macOS
- Python **3.10, 3.11 or 3.12** (3.12 preferred) — the Windows launcher can install it for you
- Internet access for the first installation (pip downloads, ~300 MB)

You do **not** install pip packages, MediaPipe, OpenCV or a virtual environment by hand.

## Quick Start

**Windows**

```bat
git clone https://github.com/yuvaofficial15301-gif/Air-Touch.git
cd Air-Touch
START_AIR_TOUCH.bat
```

**Linux / macOS**

```bash
git clone https://github.com/yuvaofficial15301-gif/Air-Touch.git
cd Air-Touch
bash START_AIR_TOUCH.sh
```

That is all. The launcher finds (or on Windows offers to install) Python, creates `.venv`, installs the pinned dependencies, verifies MediaPipe Hands, checks your camera and starts Air Touch together with the developer console at <http://127.0.0.1:8765>.

## Windows Installation

1. Double-click `START_AIR_TOUCH.bat` (or run it in a terminal).
2. If no compatible Python is found, the launcher **explains what is missing and asks permission**. Answering `Y` downloads the official Python 3.12.10 installer from python.org, **verifies its digital signature** (Python Software Foundation) and installs it **for your user only** in `%LOCALAPPDATA%\Programs\Python\Python312` — no administrator rights, no PATH changes. Answering `N` stops with manual instructions.
3. Everything else is automatic.

Other Windows scripts:

| Script | What it does |
|--------|--------------|
| `START_AIR_TOUCH.bat` | Install/verify, then start Air Touch **with** the developer console |
| `INSTALL_AIR_TOUCH.bat` | Install/verify only; does not start Air Touch |
| `UPDATE_AIR_TOUCH.bat` | Upgrade dependencies within the pinned limits, re-verify |
| `RUN_ENGINE_ONLY.bat` | Start only the engine (see [Runtime Modes](#runtime-modes)) |

Unattended use: set `AIRTOUCH_YES=1` to pre-approve the Python install and `AIRTOUCH_NO_PAUSE=1` to skip the final "Press any key".

If MediaPipe fails to load with a DLL error, install the *Microsoft Visual C++ Redistributable (x64)*: <https://aka.ms/vs/17/release/vc_redist.x64.exe>.

## Linux Installation

```bash
# Debian / Ubuntu (one time; Python + venv + Tk, which PyAutoGUI needs)
sudo apt update && sudo apt install -y python3.12 python3.12-venv python3-tk python3-dev
# (Ubuntu 24.04 ships 3.12 as python3; on releases where 3.12 is unavailable use python3.11 / python3.10)

bash START_AIR_TOUCH.sh
```

- Linux never installs system packages for you. If Python is missing or too new/old, the installer prints the exact command for your distribution and stops.
- Mouse control needs an **X11** session. Under **Wayland**, Air Touch still tracks hands and emits events but reports "no OS control". Choose "Ubuntu on Xorg" at the login screen for full control.
- `chmod +x *.sh` is optional; `bash START_AIR_TOUCH.sh` always works.
- Install only: `bash START_AIR_TOUCH.sh --install-only`. Update: `bash UPDATE_AIR_TOUCH.sh`. Engine only: `bash RUN_ENGINE_ONLY.sh`.

## macOS Installation

```bash
brew install python@3.12        # or the installer from python.org
bash START_AIR_TOUCH.sh
```

Grant **Camera** and **Accessibility** permission to your terminal app when macOS asks (see [Permissions](#permissions)). macOS support is **Experimental and untested**; in particular OpenCV's preview window may misbehave when drawn from a worker thread on macOS — use `--no-window` plus the developer console if so.

## Android Status

**Planned, not implemented.** Windows/desktop PyAutoGUI cannot control Android, so a dedicated mobile adapter is required (the `PlatformAdapter` interface is the intended extension point). On Android (e.g. Termux) the installer detects the platform and exits with code 2 and an explanation instead of failing obscurely.

## First Run

1. Platform and Python are detected.
2. `.venv` is created in the repository folder.
3. Dependencies from `requirements.txt` are installed (several minutes the first time).
4. MediaPipe 0.10.14 is verified in a fresh process (`mp.solutions.hands`), then a real Hands self-test runs.
5. `airtouch.doctor` prints every check and ends with `AIR TOUCH RUNTIME READY`.
6. Air Touch starts: camera window + developer console.

If any step fails the launcher prints `INSTALLATION FAILED`, the reason, and **does not start Air Touch**.

## Subsequent Runs

The launcher reuses `.venv`, runs the doctor (a few seconds) and starts. Packages are reinstalled **only** if the environment is damaged, a pin is wrong (e.g. wrong MediaPipe) or `requirements.txt` changed after a `git pull`. A copied/broken `.venv` (different machine, removed base Python) is detected and rebuilt automatically.

## Installation Internals

`START_AIR_TOUCH.bat` / `.sh` are thin; the logic lives in `bootstrap/install_runtime.py` (standard library only, tested on Linux).

1. **Find Python** — Windows: `py -3.12`, `py -3.11`, `py -3.10`, `python`, `python3`, per-user install folders; POSIX: `python3.12`, `python3.11`, `python3.10`, Homebrew paths, `python3`, `python`. Each candidate is checked by `bootstrap/pycheck.py` (CPython 3.10–3.12, 64-bit).
2. **Bootstrap Python** — Windows only, with consent (`bootstrap/install_python.ps1`). Linux/macOS: guided instructions, no automatic system changes.
3. **Create/verify `.venv`**; recreate it if broken.
4. **Install** `requirements.txt` (removing a wrong MediaPipe or conflicting `opencv-python*` first).
5. **Verify MediaPipe** in a fresh process, repair once with `--force-reinstall mediapipe==0.10.14` if needed.
6. **Doctor** — final verification; writes `.venv/airtouch-install.json` (hash of `requirements.txt`) so later runs can skip pip.

`install_runtime.py` options: `--mode install` (default) · `--mode update` · `--mode check` (verify only).

| Exit code | Meaning |
|-----------|---------|
| 0 | Runtime ready |
| 1 | Unexpected error |
| 2 | Unsupported platform (Android, 32-bit, unknown OS) |
| 3 | No compatible Python |
| 4 | Virtual environment could not be created |
| 5 | Dependency installation failed (package + reason printed) |
| 6 | MediaPipe incompatible |
| 7 | Final verification failed |
| 130 | Cancelled with Ctrl+C |

## Python Environment

- Location: `.venv/` inside the repository (ignored by git).
- Activate manually (only needed for development):
  - Windows: `.venv\Scripts\activate`
  - Linux/macOS: `source .venv/bin/activate`
- Run without activating: `.venv\Scripts\python air_touch.py --doctor` (Windows) / `.venv/bin/python air_touch.py --doctor` (POSIX).

## Dependencies

Single source of truth: [`requirements.txt`](requirements.txt) (also used by `pip install -e .` through `pyproject.toml`).

| Dependency | Purpose | Platform | Version (constraint) | Resolved in tested env |
|------------|---------|----------|----------------------|------------------------|
| Python | Runtime | All desktop | 3.10 – 3.12, 64-bit (3.12 preferred) | 3.12.3 |
| MediaPipe | Hand tracking (`mp.solutions.hands`) | All desktop | **`==0.10.14`** | 0.10.14 |
| opencv-contrib-python | Camera capture / preview (`cv2`) | All desktop | `>=4.8,<4.12` | 4.11.0.86 |
| NumPy | Image/array processing | All desktop | `>=1.24,<2` | 1.26.4 |
| PyAutoGUI | Desktop mouse/keyboard (adapter) | Windows, Linux (X11), macOS | `>=0.9.54,<1` | 0.9.54 |
| FastAPI | Developer console API | All desktop | `>=0.115,<1` | 0.142.2 |
| Uvicorn | Serves the console on 127.0.0.1 | All desktop | `>=0.30,<1` | 0.54.0 |
| pytest, httpx | Tests (optional, `pip install -e ".[dev]"`) | Development | `>=8`, `>=0.27` | — |

Why these pins: MediaPipe 0.10.14 depends on `opencv-contrib-python`, so that is declared directly (installing both `opencv-python` and the contrib build lets two packages overwrite the same `cv2` module). NumPy 2 and the OpenCV wheels built for it are excluded because 0.10.14 predates NumPy 2. The previous `uvicorn[standard]` extras were dropped: the console only needs plain Uvicorn.

Windows-only / Linux-only packages are not forced on other platforms; if a platform needs different packages in future, split `requirements.txt` into per-platform files and point the installer at them.

## MediaPipe Compatibility

The engine uses the legacy API `mediapipe.solutions.hands`, which newer MediaPipe releases no longer provide. Therefore `mediapipe==0.10.14` is pinned and verified:

```python
import mediapipe as mp
assert hasattr(mp, "solutions")
assert mp.solutions.hands is not None
```

The installer runs this in a **fresh process**, prints the version, file path and availability of `mp.solutions` / `mp.solutions.hands`, then also runs a real Hands inference on a blank frame. A wrong version is removed and the pinned one installed. `UPDATE_AIR_TOUCH` can never move MediaPipe off the pin because the pin is in `requirements.txt`. Manual check any time:

```bash
.venv/bin/python air_touch.py --doctor          # Windows: .venv\Scripts\python air_touch.py --doctor
```

Moving to the newer MediaPipe Tasks API is future work; until then, keep the pin.

## Camera Setup

```bash
.venv/bin/python air_touch.py --list-cameras     # Windows: .venv\Scripts\python air_touch.py --list-cameras
```

Prints each usable camera, e.g. `camera.index = 1  (1280x720)`. Put that number in `config.json` → `camera.index`.

- Backend per OS: Windows DirectShow (then Media Foundation), macOS AVFoundation, Linux V4L2; each falls back to OpenCV's automatic choice.
- If the configured camera cannot be opened and `camera.auto_fallback` is `true` (default), indices 0–4 are tried and a message tells you which one was used.
- If no camera works you get `No usable camera was detected` plus OS-specific hints (permissions, other apps using the camera, `video` group).
- If the camera stops delivering frames while running, Air Touch stops with a clear message instead of freezing.

## Gesture Controls

These are the **real** gestures in `src/airtouch/gestures.py` and the default `config.json`. The same mapping applies to the left and right hand; the **right hand moves the cursor** by default.

| Gesture | How to make it | Default action |
|---------|----------------|----------------|
| `index_pinch` | Thumb tip touches index fingertip | `left_click` |
| `middle_pinch` | Thumb tip touches middle fingertip | `right_click` |
| `two_finger` | Index + middle up, ring + pinky down | `scroll` (scrolls **up** by `mouse.scroll_amount`; repeats at the debounce rate) |
| `fist` | All four fingers folded | `drag` (holds the left mouse button down) |
| `open_palm` | All four fingers up | `release` (lets go of the drag button) |
| `thumbs_up` | Thumb up, fingers folded | `play_pause` (media Play/Pause key) |
| `index_pointing` | Only index up | none (cursor movement only) |

Cursor movement (`cursor.move_when`): the cursor follows the **wrist** of the right hand while it shows `open_palm`, `index_pointing` or `two_finger`.

Two-hand events (`gestures.two_hand`) are emitted but mapped to `none` by default, so your application can give them meaning: `both_open`, `both_fist`, `both_pinch`, `hands_together`.

Controls: **Q or ESC** closes the camera window. **Ctrl+C** stops the console/engine. **PyAutoGUI fail-safe:** slam the cursor into the top-left screen corner to stop Air Touch immediately.

Available action names: `left_click`, `right_click`, `double_click`, `scroll`, `drag`, `release`, `none`, `play_pause`, `next`, `previous` — plus anything you register.

## Configuration

`config.json` in the repository root (created with defaults if missing; your values are merged over the defaults).

| Key | Default | Meaning |
|-----|---------|---------|
| `camera.index` | `0` | Camera number (see `--list-cameras`) |
| `camera.width` / `camera.height` | `1280` / `720` | Requested capture size |
| `camera.mirror` | `true` | Flip image horizontally (mirror view) |
| `camera.auto_fallback` | `true` | Try other cameras if `camera.index` fails |
| `tracking.max_hands` | `2` | Hands tracked at once |
| `tracking.min_detection_confidence` | `0.55` | MediaPipe detection threshold |
| `tracking.min_tracking_confidence` | `0.55` | MediaPipe tracking threshold |
| `tracking.model_complexity` | `1` | MediaPipe model: `0` faster, `1` more accurate |
| `tracking.gesture_debounce_ms` | `280` | Minimum time between repeats of the same gesture action |
| `cursor.enabled` | `true` | Allow cursor movement |
| `cursor.hand` | `"right"` | Hand that moves the cursor |
| `cursor.smoothing` | `0.35` | 0–1; higher = faster/jumpier, lower = smoother/laggier |
| `cursor.edge_margin` | `0.06` | Fraction of the camera frame ignored at each edge |
| `cursor.move_when` | `["open_palm","index_pointing","two_finger"]` | Gestures that move the cursor |
| `mouse.drag_enabled` | `true` | Allow `fist` to start dragging |
| `mouse.scroll_amount` | `7` | Amount passed to the `scroll` action |
| `mouse.enabled` | `true` | **Present in the file but not read by the engine** (no effect today) |
| `hands.left.enabled` / `hands.right.enabled` | `true` | Ignore a hand entirely |
| `gestures.<left\|right>.<gesture>` | see above | Gesture → action name |
| `gestures.two_hand.<event>` | `"none"` | Two-hand event → action name |

Example — right thumbs-up opens your own action:

```json
{ "gestures": { "right": { "thumbs_up": "open_dashboard" } } }
```

(register `open_dashboard` with `register_action`, see below).

## Runtime Modes

| Mode | Command | What runs |
|------|---------|-----------|
| Full (default) | `START_AIR_TOUCH.bat` / `bash START_AIR_TOUCH.sh` | Installer check → engine + camera window + console on `127.0.0.1:8765` (`airtouch.cli --ui`) |
| Engine only | `RUN_ENGINE_ONLY.bat` / `bash RUN_ENGINE_ONLY.sh` | Engine + camera window only (`airtouch.cli`). No installer check, no console. Requires a finished install. |
| Headless | `.venv/bin/python air_touch.py --ui --no-window` | Engine + console, no camera window |
| Doctor | `.venv/bin/python air_touch.py --doctor` | Verification only |
| List cameras | `.venv/bin/python air_touch.py --list-cameras` | Camera discovery only |

CLI flags: `--ui`, `--no-window`, `--config PATH`, `--doctor`, `--list-cameras`. In `--ui` mode, if the camera cannot be opened the console still starts and shows the error so you can fix it and press **Start**.

If desktop input is unavailable (headless/Wayland/no Tk), Air Touch says so at startup and runs events-only.

## Update

```bat
git pull
UPDATE_AIR_TOUCH.bat
```
```bash
git pull
bash UPDATE_AIR_TOUCH.sh
```

Upgrades packages inside the limits of `requirements.txt`, never touches the MediaPipe pin, then re-verifies. A plain `START_AIR_TOUCH` after `git pull` also repairs the environment if `requirements.txt` changed.

## Troubleshooting

Start with the doctor — it names the failing component:

```bash
.venv/bin/python air_touch.py --doctor         # Windows: .venv\Scripts\python air_touch.py --doctor
```

| Symptom | Fix |
|---------|-----|
| **"Compatible Python was not found"** | Windows: re-run and answer `Y`, or install Python 3.12 from python.org. Debian/Ubuntu: `sudo apt install python3.12 python3.12-venv`. macOS: `brew install python@3.12`. Check what you have: `py -0p` (Windows) / `python3 --version`. |
| **Unsupported Python** (3.9, 3.13, 32-bit) | Install 3.10–3.12 64-bit **alongside** it; the launcher picks the right one automatically. |
| **MediaPipe failure / `mp.solutions` missing** | Run `UPDATE_AIR_TOUCH`; or force it: delete `.venv` and run the launcher. Check `--doctor` for the installed version (must be 0.10.14). On Windows with a DLL error install the VC++ Redistributable (link above). |
| **Camera unavailable** | `--list-cameras`; close Teams/Zoom/browser tabs using the camera; set `camera.index`; see [Permissions](#permissions). |
| **Dependency installation failure** | The installer prints `Package:` and `Reason:`. Usually no internet/proxy, or unsupported CPU/Python. Retry; behind a proxy set `HTTPS_PROXY`. |
| **Virtual environment failure** | Linux: `sudo apt install python3-venv` (or `python3.12-venv`). Otherwise delete `.venv` and retry. |
| **PyAutoGUI failure on Linux** (`install tkinter…` / `DISPLAY`) | `sudo apt install python3-tk python3-dev`, and use an X11 session (not Wayland). |
| **Platform adapter reports "null"** | The message tells why (headless, Wayland, PyAutoGUI missing). Tracking still works; OS control is off. |
| **Cursor suddenly stops / Air Touch exits** | You hit the PyAutoGUI fail-safe (top-left corner). Start it again. |
| **Application startup failure** | Run the engine directly to see the error: `.venv/bin/python air_touch.py --no-window`. |
| **Port 8765 in use** | Another Air Touch is running; close it. |
| **Blank/old console** | Hard-refresh the browser (Ctrl+F5). |

## Clean Reinstallation

```bat
rmdir /s /q .venv
START_AIR_TOUCH.bat
```
```bash
rm -rf .venv
bash START_AIR_TOUCH.sh
```

Your `config.json` is untouched.

## Developer Integration

Install as a package (inside Python 3.10–3.12):

```bash
pip install -e .
```

Public API (`from airtouch import AirTouch, AirTouchConfig, GestureEvent`):

| Object | Members |
|--------|---------|
| `AirTouch(config=None, config_path='config.json', adapter=None)` | `start(show_window=True)`, `stop()`, `on_gesture(fn)`, `register_action(name, fn)`, `status()`, `recent_events()`, `.actions`, `.adapter`, `.config`, `.running`, `.error` |
| `GestureEvent` | `gesture`, `hand` (`left`/`right`/`two_hand`), `action`, `confidence`, `timestamp`, `data`, `to_dict()` |
| `AirTouchConfig` | `load(path)`, `get(*keys, default=)`, `update(dict)`, `save(path)`, `public()` |
| `airtouch.adapters` | `PlatformAdapter`, `PyAutoGUIAdapter`, `select_adapter()`, `register_adapter()` |
| `airtouch.platform_info` | `detect_platform()`, `detect_capabilities()` |
| `airtouch.camera` | `open_camera()`, `list_cameras()`, `CameraError` |

`start()` raises `CameraError` (no camera) or `RuntimeError` (MediaPipe Hands unavailable). Listener callbacks run on the engine thread.

```python
import time
from airtouch import AirTouch

air = AirTouch()                      # reads ./config.json, selects the platform adapter

def on_gesture(event):
    print(event.gesture, event.hand, event.action)

air.on_gesture(on_gesture)
air.register_action("open_dashboard", lambda **kwargs: print("Dashboard opened"))

air.start(show_window=False)          # tracking runs on a background thread
try:
    while air.running:
        time.sleep(0.2)
except KeyboardInterrupt:
    air.stop()
```

Action callables receive keyword arguments (`amount=` for `scroll`); accept `**kwargs`. Events-only use (no OS control): `AirTouch(adapter=PlatformAdapter())`.

Command line: `airtouch` (installed script) or `python air_touch.py` / `python -m airtouch.cli`, with the flags listed in [Runtime Modes](#runtime-modes).

**Adding or changing a gesture:** edit `classify()` in `src/airtouch/gestures.py` (it returns a gesture name), add the name to `config.json` under `gestures.left`/`gestures.right`, and map it to an action. Thresholds there (e.g. pinch `.055`) are the sensitivity knobs.

## Custom Platform Adapters

The core calls only these `PlatformAdapter` methods: `screen_size`, `move_cursor`, `click`, `double_click`, `scroll`, `mouse_down`, `mouse_up`, `key_press`. The base class implements all of them as safe no-ops; list what you implement in `supports` (`"mouse"`, `"keyboard"`, `"screen"`) — built-in actions are only registered for supported capabilities.

```python
from airtouch import AirTouch
from airtouch.adapters import PlatformAdapter, register_adapter

class MyAdapter(PlatformAdapter):
    name = "my-platform"
    supports = frozenset({"mouse", "screen"})
    def screen_size(self): return (1280, 720)
    def move_cursor(self, x, y): print("move", x, y)
    def click(self, button="left"): print("click", button)

register_adapter("android", lambda info: MyAdapter())   # used by select_adapter() on that OS
# or pass it directly:  AirTouch(adapter=MyAdapter())
```

`select_adapter()` never raises: if no adapter can be created it returns a no-op adapter whose `.reason` explains why.

## Project Structure

```text
Air-Touch/
├── bootstrap/
│   ├── find_python.bat        # Windows: locate/offer Python 3.10-3.12
│   ├── find_python.sh         # POSIX: locate Python
│   ├── install_python.ps1     # Windows: consented, signature-checked per-user Python install
│   ├── install_runtime.py     # Cross-platform installer / updater / verifier
│   └── pycheck.py             # Is this interpreter compatible?
├── docs/
│   └── ARCHITECTURE.md
├── src/airtouch/
│   ├── adapters/
│   │   ├── __init__.py        # select_adapter / register_adapter
│   │   ├── base.py            # PlatformAdapter (no-op base)
│   │   └── desktop.py         # PyAutoGUI adapter
│   ├── ui/index.html          # developer console
│   ├── __init__.py  __main__.py
│   ├── actions.py  camera.py  cli.py  config.py
│   ├── doctor.py  engine.py  events.py  gestures.py
│   ├── platform_info.py  web.py
├── tests/                     # pytest suite
├── .gitattributes  .gitignore
├── CHANGELOG.md
├── LICENSE
├── README.md
├── air_touch.py               # run from a checkout: python air_touch.py
├── config.json
├── pyproject.toml
├── requirements.txt
├── START_AIR_TOUCH.bat / .sh
├── INSTALL_AIR_TOUCH.bat
├── UPDATE_AIR_TOUCH.bat / .sh
└── RUN_ENGINE_ONLY.bat / .sh
```

## Development Setup

```bash
git clone https://github.com/yuvaofficial15301-gif/Air-Touch.git
cd Air-Touch
bash START_AIR_TOUCH.sh --install-only      # Windows: INSTALL_AIR_TOUCH.bat
source .venv/bin/activate                   # Windows: .venv\Scripts\activate
pip install -e ".[dev]"
python air_touch.py --no-window             # run / debug (add --ui for the console)
```

Updating dependencies: change the constraint in `requirements.txt` (keep `mediapipe==0.10.14` unless the engine is ported), run `UPDATE_AIR_TOUCH`, then the tests. If you change the MediaPipe pin also update `REQUIRED_MEDIAPIPE` in `src/airtouch/doctor.py` (a test checks they match).

Contributing: fork → branch → keep changes small → run `pytest` → open a pull request. Do not commit `.venv`, caches or personal paths.

## Testing

```bash
pytest -q
```

52 tests cover: gesture classification (synthetic landmarks), config merging, actions/adapters, platform detection, camera discovery/fallback, the engine loop with a fake camera (start/stop/camera-loss/debounce/cursor mapping), the console's host/origin protection, installer helpers, launcher-file presence and CRLF line endings, and the runtime doctor (real MediaPipe Hands inference).

Full installer behaviour is verified by running it (see below). The engine's behaviour with a **real webcam and real hands** cannot be covered by automated tests.

### Verification status

What was actually executed (Linux x64, Python 3.12.3, Ubuntu 24.04 container, no camera, Xvfb virtual display):

| Check | Result |
|-------|--------|
| Fresh install (create venv, install pinned deps, MediaPipe check, doctor) | Pass |
| Re-run on healthy env (no pip) | Pass |
| Repair: wrong MediaPipe (0.10.21) + conflicting `opencv-python` | Pass (downgraded to 0.10.14, OpenCV conflict removed) |
| Broken `.venv` auto-rebuilt | Pass |
| `--mode update` keeps MediaPipe 0.10.14 | Pass |
| No-network failure → exit 5 with package + reason, app not started | Pass |
| No compatible Python → exit 3 with guidance | Pass (simulated) |
| PyAutoGUI adapter moving the cursor on a real X server (Xvfb) | Pass |
| No camera → clean error, exit 3; console keeps running with `--ui` | Pass |
| Console rejects foreign Host / cross-origin POST (403) | Pass |
| `pip install -e .` + public API import | Pass |
| `pytest` | 52 passed |

**Not tested** (be aware before relying on them): Windows (`.bat` files, `find_python.bat`, `install_python.ps1` and the Python download were reviewed but **never executed**), macOS, Wayland, ARM, Python 3.10/3.11, real webcam hand tracking, real mouse control on a physical desktop.

## Security / Privacy

- Processing is **local**: Air Touch's own code makes no network requests and has no telemetry. Camera frames are processed in memory and are not saved or uploaded.
- Network is used only to download packages from PyPI during install/update and (Windows, with your consent) the Python installer from python.org. The installer checks the Python installer's publisher signature before running it.
- The developer console binds to `127.0.0.1` only and rejects requests with a non-local `Host` header or a cross-site `Origin`, so web pages cannot start mouse control through it. It has no authentication, so other **local** users/programs on the same machine can reach it.
- Air Touch can move the mouse and press keys. Keep the PyAutoGUI fail-safe in mind (top-left corner).
- No credentials, API keys or machine-specific paths are stored in the repository.
- Third-party libraries (MediaPipe, OpenCV, …) are not audited by this project.

## Permissions

| Platform | What to allow |
|----------|---------------|
| Windows | Settings → Privacy & security → **Camera** → allow desktop apps. |
| macOS | System Settings → Privacy & Security → **Camera** and **Accessibility** (mouse/keyboard control) for your terminal app; restart the terminal. |
| Linux | Read access to `/dev/video*` (usually the `video` group: `sudo usermod -aG video $USER`, then log out/in). X11 session for input control. |

## Platform Support Matrix

| Platform | Status | Camera | Hand Tracking | Input Control | Installer |
|----------|--------|--------|---------------|---------------|-----------|
| Windows | Stable | DirectShow / MSMF | MediaPipe 0.10.14 | PyAutoGUI adapter | `START_AIR_TOUCH.bat` (+ consented Python install) |
| Linux | Experimental | V4L2 | MediaPipe 0.10.14 (x64 verified) | PyAutoGUI on X11 only | `START_AIR_TOUCH.sh` (guided Python install) |
| macOS | Experimental (untested) | AVFoundation | MediaPipe 0.10.14 (not verified) | PyAutoGUI + Accessibility permission | `START_AIR_TOUCH.sh` (guided Python install) |
| Android | Planned | — | — | — (needs a mobile adapter) | Refuses with explanation |

## FAQ

**Do I need to install Python myself?** On Windows the launcher can do it for you (with your permission). On Linux/macOS it tells you the exact command.

**Can I use Python 3.13/3.14?** Not yet — MediaPipe 0.10.14 has no wheels for them. Keep 3.12 alongside; Air Touch finds it.

**Does it need internet?** Only to install/update. At run time it works offline.

**Why is the pointer slow?** PyAutoGUI inserts a short pause after every call; lower `tracking.model_complexity` to `0` and raise `cursor.smoothing` for snappier movement.

**Scrolling only goes up?** Yes, currently — `scroll` uses a fixed positive amount. Register your own action for downward scrolling.

**Can I use only the gestures in my own app?** Yes: see [Developer Integration](#developer-integration); use `AirTouch(adapter=PlatformAdapter())` for events only.

**Two cameras?** Use `--list-cameras` and set `camera.index`.

## License

MIT License — see [`LICENSE`](LICENSE). Copyright (c) 2026 Yuvaraj N. (Yuva).

You may use, modify, integrate and build products with Air Touch under the MIT terms, provided the copyright and license notice is kept. Integrating Air Touch does not transfer ownership of the original project.

## Credits

Air Touch was created and is maintained by **Yuvaraj N. (Yuva)**. Hand tracking by [MediaPipe](https://github.com/google-ai-edge/mediapipe) (Apache-2.0); also OpenCV, NumPy, PyAutoGUI, FastAPI and Uvicorn, each under its own license.
