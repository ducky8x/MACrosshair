# MACrosshair

A lightweight macOS overlay that draws a customizable crosshair at the center of your screen. Originally built to assist with MCSR Oneshot, where marking the exact screen center is an advantage.

> **This project is archived and no longer maintained.**

## Features

- Always-on-top overlay that ignores mouse events
- Customizable color, line length, thickness, dot size, and opacity
- Pixel-level X/Y offset to shift the crosshair from center
- Toggle visibility with a configurable keyboard shortcut (default: `Y`)
- Light, Dark, or Clear theme for the settings window
- Settings save automatically and restore on next launch
- Export/import profiles as `.json` files
- Stays visible across Mission Control spaces and fullscreen apps

## Requirements

- macOS 11 or later

## Installation

There is only one file: `MACrosshair.swift`. No Xcode, no build system, no installer.

1. Click the green **Code** button, then **Download ZIP** and unzip it.
2. Open Terminal and navigate to the folder:
```bash
cd /path/to/MACrosshair-main
```
3. Run it:
```bash
swift MACrosshair.swift
```

> **First launch:** macOS may ask for Accessibility permission for the keyboard shortcut to work. Go to **Privacy & Security → Accessibility** and toggle MACrosshair on, then run the command again.

### Compile to a standalone app

```bash
swiftc MACrosshair.swift -o MACrosshair
```

This creates a standalone `MACrosshair` file you can double-click or drag into your Dock.

## Settings

| Setting | Description |
|---|---|
| Color | Red, Green, White, Yellow, or Cyan |
| Line Length | 4–40 px |
| Line Thickness | 1–8 px |
| Show Center Dot | Toggle on/off |
| Dot Size | 2–12 px |
| Opacity | 10–100% |
| Offset X / Y | Shift crosshair from center (negative values supported) |
| Toggle Shortcut | Click to record a new key or combo |
| Theme | Light, Dark, or Clear |

Positive X moves right, negative left. Positive Y moves up, negative down. Hit **Reset Offset** to return to center.

## Profiles

Use **Export Profile** to save your settings to a `.json` file, and **Import Profile** to load them on any Mac. Useful for backups, switching machines, or sharing a setup.

## Changelog

### v1.0.0
- Added Export/Import Profile

### v0.0.2
- Added crosshair offset and Reset Offset button

### v0.0.1
- Added persistent settings via UserDefaults
- Removed redundant comments

## License

Copyright © 2026 ducky8x.

This project is licensed under the GNU GPL v3.0. You're free to use, modify, and distribute this code, but any project that uses it must also be open source and released under the same license. See the [LICENSE](./LICENSE) file for details.
