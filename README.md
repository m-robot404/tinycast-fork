# Tinycast (Fork)

**A tiny, fully native macOS launcher. One hotkey, everything you reach for all day, under 100 MB of RAM (~27 MB idle).**

<p align="center">
  <a href="https://github.com/subhashhhhhh/tinycast-fork/releases/latest">
    <img alt="Latest release"
         src="https://img.shields.io/github/v/release/subhashhhhhh/tinycast-fork?sort=semver&style=flat&label=release&color=1F6FEB"></a>
  <img alt="Swift 6.0"
       src="https://img.shields.io/badge/Swift-6.0-F05138?style=flat&logo=swift&logoColor=white">
  <img alt="macOS 26 or later"
       src="https://img.shields.io/badge/macOS-26%2B-000000?style=flat&logo=apple&logoColor=white">
  <a href="LICENSE">
    <img alt="License: AGPL-3.0"
         src="https://img.shields.io/badge/License-AGPL--3.0-3DA639?style=flat"></a>
</p>

SwiftUI and AppKit, **zero third-party dependencies**, no Electron and no telemetry. It also **runs real Raycast extensions**, rendered as native SwiftUI. Free, open source, and community-driven.

<p align="center">
  <img src="docs/screenshot.png" alt="Tinycast command palette" width="720">
</p>

## Why This Fork?

This fork maintains the core strengths of Tinycast while prioritizing bug fixes, stability, and open community contributions:

- **Caps Lock / Hyper Key Latch Fix**: Resolves the bug where Caps Lock gets stuck in `⌃⌥⇧⌘` modifier mode. Features stuck-key watchdog recovery and automatic re-assertion across wake/sleep and device reconnects.
- **Enhanced File Search**: Two-phase deep search, syntax-highlighted code previews with line numbers, PDF & media preview surfaces, preview sizing, and action toggles.
- **Independent Updates & Homebrew Tap**: Completely unlinked from upstream feeds so updates never overwrite your custom build.
- **Lean Memory Footprint**: Strictly maintains low memory usage (~27 MB dirty RAM).

## Features

- **App launcher** — fuzzy-search and launch anything, pin favorites, see what's running, quit an app or every app at once.
- **Global hotkey** — one shortcut summons the palette from anywhere.
- **Per-app hotkeys** — bind a key to an app; press it to toggle (focus/hide).
- **Search Files** — fast shallow and deep search through Spotlight with syntax code previews, line numbers, PDF viewers, and media players.
- **Dictionary** — look a word up with the Define Word command, or define whatever you typed from the launcher's fallbacks.
- **Clipboard history** — text and images, searchable, pasted back into the app you were using.
- **Calculator** — do math, unit, live currency and crypto conversions inline, right in the palette.
- **Quicklinks** — turn a URL, search, file or deeplink into a command, with placeholders for typed input, the clipboard or the date.
- **Apple Shortcuts** — search and run the shortcuts you built in the Shortcuts app, with aliases and global hotkeys.
- **Snippets** — reusable Markdown templates with dynamic placeholders, arguments, nested references and optional keyword expansion.
- **Custom commands** — run named shell commands through fuzzy search or their own global hotkeys.
- **Window management** — 34 Rectangle-style actions: halves, quarters, thirds, sizing, nudging, display moves, fullscreen and Spaces.
- **System actions** — lock, sleep, restart, empty trash, toggle appearance, Bluetooth, mute, hidden files, and more.
- **Calendar and meetings** — your next meeting on the empty palette and in the menu bar, one key to join it, or let it join itself.
- **Notes** — an unlimited collection of plain Markdown files in one floating editor, searchable from the palette and rendered as you write.
- **Emoji picker** — a searchable emoji grid, one keystroke away.
- **AI chat** — use your own key or an installed AI account: ask Quick AI from the palette, or keep longer conversations in the AI Chat window.
- **Quick Actions** — fix grammar, rewrite, translate or summarize the selected text in any app.
- **Raycast extensions** — run the ones you already have natively, rendered as SwiftUI.
- **Backup and import** — export your settings to a file, or import your setup from Raycast.

## Install

### Via Homebrew (Recommended)

```sh
brew tap subhashhhhhh/tinycast
brew install --cask tinycast
```

Or in one command:

```sh
brew install --cask subhashhhhhh/tinycast/tinycast
```

Homebrew clears the macOS quarantine flag automatically on install and updates (`postflight`), so there is nothing else to run.

### Manual Download

Download `Tinycast-0.11.12.dmg` from **[Releases](https://github.com/subhashhhhhh/tinycast-fork/releases)**, open it, and drag `Tinycast.app` to `/Applications`.

Because Tinycast is signed with a local self-signed certificate, clear the quarantine attribute once:
```sh
xattr -dr com.apple.quarantine "/Applications/Tinycast.app"
```

## Permissions

**Accessibility** — needed when Tinycast pastes or expands text into another app, and the only permission snippet keyword expansion and Hyper Key need. Grant access in **System Settings → Privacy & Security → Accessibility**. Keystrokes are matched locally, never stored and never sent anywhere.

## Using it

1. Open **Settings → General** and record a global shortcut to summon Tinycast.
2. Press it anywhere → the palette floats in. Type to filter, **↵** to launch.
3. **Tab** switches between Apps and Clipboard; **↑/↓** move, **Esc** dismisses.
4. **Settings → Shortcuts** — search an app or custom command and record a global shortcut.
5. **Settings → Snippets** — enable the feature, then create templates with expansion keywords.

## Building from source

See **[docs/development.md](docs/development.md)** for the toolchain, build, packaging, and testing workflows. **[docs/](docs/README.md)** indexes everything else — architecture, engineering standards, and feature designs.

To build and run tests locally:
```sh
./Scripts/run-tests.sh
```

To build a signed Release DMG:
```sh
./Scripts/build-dmg.sh 0.11.12
```

## Contributing

Contributions and bug reports are welcome! If you find a bug, have an idea, or want to contribute a fix:

1. Open an issue or pull request directly on GitHub.
2. Ensure `./Scripts/run-tests.sh` passes and no AppKit/SwiftUI imports are introduced in `Features/*/Model/`.
3. Submit your PR — open and welcoming to community collaboration.

## License

[AGPL-3.0](LICENSE)
