# 🍅 Tomato — macOS Menubar Pomodoro Timer

A minimal, distraction-free Pomodoro timer that lives in your macOS menu bar.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## How It Works

Tomato sits quietly in your menu bar as a small dot:

- **● Black dot** — Focus session in progress
- **🟠 Orange dot** — Time to take a break!
- **● Gray dot** — Timer is idle

When the orange dot appears, click it to acknowledge your break. If you miss it (the break timer expires without a click), it's recorded as a missed break. Your tracked vs missed breaks are visualized in day/week/month charts right in the dropdown menu.

**No notifications. No pop-ups. Just a dot.**

## Features

- 🎯 **Menubar-only** — No dock icon, no windows stealing focus
- ⚙️ **Configurable** — Work duration, short/long break, sessions before long break
- 📊 **Break tracking** — Visual charts of tracked vs missed breaks (day/week/month)
- 🔄 **Auto-cycle** — Optionally auto-starts next work session after a break
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

Click the gear icon in the dropdown menu to configure:

| Setting | Default | Description |
|---------|---------|-------------|
| Work Duration | 25 min | Length of each focus session |
| Short Break | 5 min | Break after a regular session |
| Long Break | 15 min | Break after N sessions |
| Long break every | 4 sessions | Sessions before a long break |
| Auto-start work | On | Auto-start next session after break |

## Data Storage

- **Settings** → `UserDefaults` (standard macOS preferences)
- **Break history** → `~/Library/Application Support/Tomato/sessions.json`

## License

MIT — see [LICENSE](LICENSE) for details.
