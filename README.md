# 🍅 Tomato — macOS Menubar Pomodoro Timer

A minimal, distraction-free Pomodoro timer that lives in your macOS menu bar.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## How It Works

Tomato sits quietly in your menu bar as a small dot:

- **● Black dot** — Focus session in progress
- **🟠 Orange dot** — Time to take a break!
- **● Gray dot** — Timer is paused

When the orange dot appears, open the menu and click `Break Done` to acknowledge your break or `Skip` to dismiss it. You can also use `Done + Reset` or `Skip + Reset` to record the break and immediately restart the work timer. If the break timer expires first, it's recorded as a missed break. If you pause during a break, that is tracked as a separate paused outcome. Your tracked, missed, skipped, and paused breaks are visualized in the menu.

**No notifications. No pop-ups. Just a dot.**

## Features

- 🎯 **Menubar-only** — No dock icon, no windows stealing focus
- ▶️ **Always-on timer** — Starts immediately on launch and keeps state across relaunches
- ⚙️ **Configurable** — Work duration, short/long break, sessions before long break
- 📊 **Break tracking** — Visual charts of tracked, missed, skipped, and paused breaks
- 😴 **Sleep-safe timing** — Uses wall-clock time so sessions stay accurate across sleep/wake
- 💾 **Persistent stats** — Break history saved locally as JSON

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 16.0+ (to build)

## Build & Run

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/tomato.git
cd tomato

# Install xcodegen (if not already installed)
brew install xcodegen

# Generate the Xcode project
xcodegen generate

# Build from the command line
xcodebuild -project Tomato.xcodeproj -scheme Tomato -configuration Release build

# Or open in Xcode
open Tomato.xcodeproj
```

The built app will be in `DerivedData/`. You can also just open `Tomato.xcodeproj` in Xcode and hit ⌘R.

## Configuration

Click the gear icon at the top-right of the dropdown menu to configure:

| Setting | Default | Description |
|---------|---------|-------------|
| Work Duration | 25 min | Length of each focus session |
| Short Break | 5 min | Break after a regular session |
| Long Break | 15 min | Break after N sessions |
| Long break every | 4 sessions | Sessions before a long break |
## Data Storage

- **Settings** → `UserDefaults` (standard macOS preferences)
- **Break history** → `~/Library/Application Support/Tomato/sessions.json`
- **Active timer state** → `UserDefaults` (restored on relaunch)

## License

MIT — see [LICENSE](LICENSE) for details.
