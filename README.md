# Swift Symbol Picker

A Shortcuts-style SF Symbol picker for SwiftUI — an optional color row above a searchable, categorised grid of symbols. Browse tidy curated categories, or type to search **every** symbol the installed OS knows about, including symbols added by future OS releases, with no package update.

## Features

- 🎨 **Icon + color in one** — a color row (Apple Shortcuts palette) above the symbol grid, both bound
- 🗂 **Categorised browse** — curated sections (Weather, Devices, Maps, Objects & Tools, …) straight from the system's own symbol categories
- 🔍 **Search everything** — filters the full symbol set, ranked so prefix matches come first
- 🔄 **Future-proof** — on macOS the search list is read live from `CoreGlyphs`, so new OS symbols appear automatically
- 📦 **Bundled fallback** — ships a snapshot so browse and search work even when the live read is unavailable (iOS, or a sandbox that blocks it)
- ⚡️ **Performant** — loads once, off the main thread, cached for the session; search is debounced
- 🧩 **Drop-in** — a single `SymbolPicker` view; present it in a sheet, popover, or inline
- 🎯 **Symbol-only mode** — omit the color binding to hide the color row
- 🧵 **Hex bridging** — `Color(hex:)` / `Color.toHex()` for storing selections as strings
- 🟦 **`SymbolTile`** — draws a chosen symbol on its chosen color so it reads in light and dark mode, whatever the color is

## Requirements

- macOS 14.0+ / iOS 17.0+
- Swift 6.0+
- Xcode 16.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-symbol-picker.git", from: "1.0.0")
]
```

## Usage

### Icon + Color

```swift
import SwiftUI
import SymbolPicker

struct IconEditor: View {
    @State private var icon = "star.fill"
    @State private var tint = Color.blue

    var body: some View {
        SymbolPicker(symbol: $icon, color: $tint)
            .frame(width: 360, height: 440)
    }
}
```

### Symbol Only

```swift
SymbolPicker(symbol: $icon)
```

### Custom Color Palette

```swift
SymbolPicker(symbol: $icon, color: $tint, palette: [.red, .orange, .green, .blue])
```

### Storing Selections as Hex

```swift
// SwiftUI Color <-> hex string, for models that persist strings
let tint = Color(hex: "#3498DB")     // Color?
let stored = Color.blue.toHex()      // "#007AFF"
```

### Showing What Was Picked

```swift
// A symbol on a filled tile of its color — a list row, a card, a widget
SymbolTile(symbol: endpoint.icon, color: tint, size: 32)
SymbolTile(symbol: "cloud.sun.fill", color: .blue, size: 40, shape: .rounded)
```

A brand color is chosen for a logo on white. `SymbolTile` fills the tile with it, lifts a
near-black one on a dark window (and drops a near-white one on a light window) just far enough
to be a shape, and paints the glyph white or near-black by the tile's own luminance — the rule
Shortcuts uses for its icons. `Color.relativeLuminance` and `Color.mixed(toward:)` are public
if you want the rule without the view.

### Querying the Catalog Directly

```swift
let catalog = SymbolCatalog.shared
catalog.loadIfNeeded()
let matches = catalog.search("bolt")   // ["bolt", "bolt.fill", "bolt.circle", …]
```

## How It Works

The picker draws on two sources:

- **Browse** — a curated, categorised snapshot bundled with the package, extracted from the system's SF Symbols categories, for tidy grids.
- **Search** — on macOS, the operating system's own symbol list, read live from `CoreGlyphs` at runtime, so symbols added by future OS releases are searchable without updating the package. Off macOS — or if the read is blocked — it falls back to the bundled snapshot.

The list loads once, lazily, on a background task and is cached on `SymbolCatalog.shared`. Search is debounced and results are capped for a snappy grid.

## Testing

```bash
swift test
```

The test suite covers HEX ↔ Color round-tripping, malformed-input handling, the bundled palette, and decoding of the bundled symbol catalog.

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
