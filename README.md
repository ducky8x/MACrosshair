# MACrosshair

A lightweight macOS overlay app that draws a customizable crosshair at the center of your screen — useful for gaming, creative work, or any task where a precise center reference helps. The main use case of this app is in assisting in MCSR Oneshot, where finding and marking the exact center of your screen is an advantage.

## Features

- **Always-on-top overlay** — crosshair sits above all windows and ignores mouse events
- **Customizable appearance** — color, line length, line thickness, dot size, and opacity
- **Pixel-level offset** — shift the crosshair any number of pixels on the X and Y axes independently
- **Toggle visibility** — show/hide the crosshair via a configurable keyboard shortcut (default: `Y`)
- **Theme support** — Light, Dark, or Clear settings window
- **Persistent settings** — all settings are saved automatically and restored on next launch
- **Profile export / import** — save your settings to a `.json` file and load them on any Mac
- **Joins all spaces** — crosshair stays visible across Mission Control spaces and fullscreen apps

## Requirements

- macOS 11 or later
- Swift (comes pre-installed on macOS — no download needed)

## Installation

There is only one file: `MACrosshair.swift`. No Xcode, no build system, no installer.

**Step 1 — Download the file**

Click the green **Code** button on this page, then click **Download ZIP**. Unzip it and you'll have a folder called `MACrosshair-main` with `MACrosshair.swift` inside.

**Step 2 — Open Terminal**

Press `Command + Space`, type `Terminal`, and hit Enter.

**Step 3 — Navigate to the folder**

Drag the `MACrosshair-main` folder from Finder into the Terminal window after typing `cd ` (with a space):

```bash
cd /path/to/MACrosshair-main
```

**Step 4 — Run it**

```bash
swift MACrosshair.swift
```

That's it. The crosshair and settings window will appear immediately.

> **First launch:** macOS may ask for Accessibility permission. This is needed for the keyboard shortcut to work. Click **Open System Settings**, then toggle MACrosshair on under **Privacy & Security → Accessibility**. Run the command again after granting it.

### Want to run it without Terminal every time?

Compile it into a standalone app once:

```bash
swiftc MACrosshair.swift -o MACrosshair
```

This creates a file called `MACrosshair` in the same folder. Double-click it (or run `./MACrosshair` in Terminal) to launch it anytime without needing the `swift` command. You can even drag it into your Dock so you can open and close it even quicker.

## Usage

When the app launches, a settings panel appears where you can configure:

| Setting | Description |
|---|---|
| Color | Red, Green, White, Yellow, or Cyan |
| Line Length | 4–40 px |
| Line Thickness | 1–8 px |
| Show Center Dot | Toggle on/off |
| Dot Size | 2–12 px |
| Opacity | 10–100% |
| Offset X / Y | Shift crosshair from center in pixels (negative values supported) |
| Toggle Shortcut | Click to record a new key or key combo |
| Theme | Light, Dark, or Clear |

### Offset

The offset fields let you move the crosshair away from the true screen center. Positive X moves right, negative X moves left. Positive Y moves up, negative Y moves down (macOS coordinate system). Hit **Reset Offset** to return to center.

### Keyboard Shortcut

The default toggle key is `Y`. To change it, click the shortcut button in the settings panel and press any key or key combination. Modifier-only shortcuts (e.g. `Command + Shift + X`) use the system hotkey API; plain keys use an accessibility event tap.

### Persistent Settings

All settings — color, size, offset, theme, and keyboard shortcut — are saved automatically to your Mac every time you make a change. There is nothing to manually save. When you relaunch the app, everything will be exactly as you left it.

### Profiles (Export / Import)

At the bottom of the settings panel you'll find two buttons:

- **Export Profile** — saves all your current settings to a `.json` file anywhere you choose (iCloud Drive, Dropbox, a USB drive, etc.)
- **Import Profile** — loads a previously exported `.json` file and applies every setting instantly, including theme and keyboard shortcut

This is the recommended way to move your settings between Macs, back them up, or share a setup with someone else.

## Changelog

### v1.0.0
- Added **Export Profile** — save all settings to a `.json` file
- Added **Import Profile** — load a profile from a `.json` file, restoring all settings including theme and keyboard shortcut
- Settings now persist automatically between sessions (no manual save needed)

### v0.0.2
- Added **crosshair offset** — shift the crosshair from center by any number of pixels on X and Y axes independently
- Added **Reset Offset** button

### v0.0.1
- Added **persistent settings** via UserDefaults — theme, hotkey, and all crosshair values are remembered across launches
- Removed redundant comments

## License

Copyright © 2026 Joowon Shin. All rights reserved.

This project is licensed under the [Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/).

You are free to use, share, and modify this software for **personal and non-commercial purposes**, as long as you give appropriate credit. **You may not sell, sublicense, or use this software for commercial purposes.**
