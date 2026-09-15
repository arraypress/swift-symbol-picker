//
//  SymbolPicker.swift
//  SymbolPicker
//
//  A Shortcuts-style icon + color picker for SF Symbols
//  Created on 13/07/2026.
//

import SwiftUI

/// A Shortcuts-style icon picker: an optional color row above a searchable, categorised grid of SF Symbols.
///
/// Browse curated categories, or type to search *every* symbol the installed OS knows about — including
/// symbols added by future OS releases (on macOS, read live from the system), with no package update.
///
/// ## Example
/// ```swift
/// @State private var icon = "star.fill"
/// @State private var tint = Color.blue
///
/// SymbolPicker(symbol: $icon, color: $tint)
///     .frame(width: SymbolPicker.shortcutsSize.width, height: SymbolPicker.shortcutsSize.height)
/// ```
///
/// Hide the color row with the symbol-only initializer:
/// ```swift
/// SymbolPicker(symbol: $icon)
/// ```
public struct SymbolPicker: View {

    @Binding private var symbol: String
    private let colorSelection: Binding<Color>?
    private let palette: [Color]

    @ObservedObject private var catalog = SymbolCatalog.shared
    @State private var query: String = ""
    @State private var debounced: String = ""
    @State private var results: [String] = []
    @FocusState private var searchFocused: Bool

    /// The size of the Shortcuts picker's popover, for a frame that matches it exactly.
    public static let shortcutsSize = CGSize(width: 310, height: 428)

    /// Shortcuts' grid, measured at 2×: eight cells across with no gap between them, rows 8 points
    /// apart, the block inset 8 points at the sides and 10 above and below each category.
    private let rowSpacing: Double = 8
    private let gridInsets = EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
    private let columnCount = 8

    /// Creates a picker with a color row above the symbol grid.
    ///
    /// - Parameters:
    ///   - symbol: The selected SF Symbol name.
    ///   - color: The selected color.
    ///   - palette: The swatches shown in the color row. Defaults to ``SymbolPickerPalette/shortcuts``.
    public init(
        symbol: Binding<String>,
        color: Binding<Color>,
        palette: [Color] = SymbolPickerPalette.shortcuts
    ) {
        _symbol = symbol
        colorSelection = color
        self.palette = palette
    }

    /// Creates a symbol-only picker, without the color row.
    ///
    /// - Parameter symbol: The selected SF Symbol name.
    public init(symbol: Binding<String>) {
        _symbol = symbol
        colorSelection = nil
        palette = []
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let colorSelection {
                ColorPaletteRow(selection: colorSelection, palette: palette)
                    .padding(.horizontal, 16)
                    .padding(.top, 13)
                    .padding(.bottom, 16)
                Divider()
            }
            searchField
                .padding(.horizontal, 14)
                .padding(.top, 8)
                .padding(.bottom, 5)

            content
        }
        .task { catalog.loadIfNeeded() }
        .task(id: query) {
            /// Debounce so a burst of keystrokes filters once, when the user pauses
            try? await Task.sleep(nanoseconds: 120_000_000)
            guard !Task.isCancelled else { return }
            debounced = query.trimmingCharacters(in: .whitespaces)
            results = debounced.isEmpty ? [] : catalog.search(debounced)
        }
    }

    // MARK: - Search field
    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search Symbols", text: $query)
                .textFieldStyle(.plain)
                .focused($searchFocused)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 9))
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .strokeBorder(searchFocused ? Color.accentColor : .clear, lineWidth: 2)
        )
    }

    // MARK: - Content
    @ViewBuilder private var content: some View {
        if !catalog.isLoaded {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if debounced.isEmpty {
            browse
        } else {
            searchResults
        }
    }

    private var browse: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(catalog.categories) { category in
                    sectionHeader(category.label)
                    grid(category.symbols)
                        .padding(gridInsets)
                }
            }
        }
    }

    /// The full-width uppercase header bar, matching Shortcuts' category dividers: 21 points tall,
    /// the label 20 points in, on the window's own background so it sits a shade below the
    /// popover in both appearances rather than a shade above it.
    private func sectionHeader(_ label: String) -> some View {
        Text(label.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .frame(maxWidth: .infinity, minHeight: 21, alignment: .leading)
            .padding(.horizontal, 20)
            .background(headerBackground)
    }

    private var headerBackground: Color {
        #if canImport(AppKit)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.primary.opacity(0.06)
        #endif
    }

    private var searchResults: some View {
        Group {
            if results.isEmpty {
                emptyState
            } else {
                ScrollView {
                    grid(results).padding(gridInsets)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 4) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("No Symbols Found")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Grid
    private func grid(_ symbols: [String]) -> some View {
        LazyVGrid(columns: columns, spacing: rowSpacing) {
            ForEach(symbols, id: \.self) { name in
                item(name)
            }
        }
    }

    private func item(_ name: String) -> some View {
        Button {
            symbol = name
        } label: {
            let isSelected = name == symbol
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(isSelected ? Color.accentColor : .clear)
                    .opacity(0.2)
                /// At a point size, not stretched to a box: a bicycle is wider than a watch in
                /// Shortcuts too, and 16 medium is what its glyphs measure
                Image(systemName: name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isSelected ? Color.accentColor : .primary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(name)
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 0), count: columnCount)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var symbol = "star.fill"
    @Previewable @State var color = Color.blue
    SymbolPicker(symbol: $symbol, color: $color)
        .frame(width: SymbolPicker.shortcutsSize.width, height: SymbolPicker.shortcutsSize.height)
}
