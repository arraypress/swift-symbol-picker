//
//  SymbolCatalog.swift
//  SymbolPicker
//
//  Symbol data for the picker: curated categories to browse, every symbol to search
//  Created on 13/07/2026.
//

import SwiftUI

/// Supplies SF Symbol data to ``SymbolPicker``, from two sources on purpose:
///
/// - **Browse** — a curated, categorised snapshot bundled with the package, for tidy grids.
/// - **Search** — on macOS, the operating system's *own* symbol list, read live from `CoreGlyphs`, so
///   symbols added by future OS releases become searchable with no package update. Everywhere else (and
///   if the read is blocked) it falls back to the bundled list.
///
/// The list loads once, off the main thread, and is cached on ``shared`` for the app's lifetime.
///
/// ## Example
/// ```swift
/// let catalog = SymbolCatalog.shared
/// catalog.loadIfNeeded()
/// let matches = catalog.search("bolt")
/// ```
@MainActor
public final class SymbolCatalog: ObservableObject {

    /// Shared, lazily-loaded instance used by ``SymbolPicker``.
    public static let shared = SymbolCatalog()

    /// A browsable group of symbols, e.g. *Weather* or *Devices*.
    public struct Category: Identifiable, Decodable, Hashable, Sendable {
        /// Stable category key (e.g. `"weather"`).
        public let key: String
        /// Human-readable title (e.g. `"Weather"`).
        public let label: String
        /// A representative symbol for the category header.
        public let icon: String
        /// The symbols shown in this category, in display order.
        public let symbols: [String]
        public var id: String { key }
    }

    /// Curated categories for the browse grid.
    @Published public private(set) var categories: [Category] = []
    /// The full set of symbols available to search.
    @Published public private(set) var allSymbols: [String] = []
    /// `true` once the first load has finished.
    @Published public private(set) var isLoaded = false

    public init() {}

    private struct Snapshot: Decodable, Sendable {
        let categories: [Category]
        let allSymbols: [String]
    }

    /// Starts the one-time load. Safe to call repeatedly. Browse data comes from the bundle; the search
    /// list prefers the live system set on macOS, falling back to the bundle otherwise.
    public func loadIfNeeded() {
        guard !isLoaded else { return }
        Task.detached(priority: .userInitiated) {
            let bundled = Self.bundledCatalog()
            let systemSymbols = Self.systemSymbols()
            let searchList = (systemSymbols?.isEmpty == false ? systemSymbols : nil) ?? bundled.symbols
            await MainActor.run {
                self.categories = bundled.categories
                self.allSymbols = searchList
                self.isLoaded = true
            }
        }
    }

    /// Symbols matching `query` (case-insensitive substring), ranked so prefix matches come first.
    ///
    /// - Parameters:
    ///   - query: The search text.
    ///   - limit: Maximum number of results to return. Defaults to 600.
    /// - Returns: Matching symbol names, best matches first.
    public func search(_ query: String, limit: Int = 600) -> [String] {
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !needle.isEmpty else { return [] }
        var prefix: [String] = []
        var contains: [String] = []
        for name in allSymbols {
            let lower = name.lowercased()
            if lower.hasPrefix(needle) {
                prefix.append(name)
            } else if lower.contains(needle) {
                contains.append(name)
            }
            if prefix.count >= limit { break }
        }
        return Array((prefix + contains).prefix(limit))
    }

    // MARK: - Sources

    /// Loads the bundled snapshot shipped inside the package. Also used as the search fallback.
    public nonisolated static func bundledCatalog() -> (categories: [Category], symbols: [String]) {
        guard let url = Bundle.module.url(forResource: "SymbolCatalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data)
        else { return ([], []) }
        return (snapshot.categories, snapshot.allSymbols)
    }

    /// The installed macOS's full SF Symbol list, minus restricted and localized/RTL variants. Returns
    /// `nil` off macOS, or when the `CoreGlyphs` resources can't be read (then the bundle is used).
    nonisolated static func systemSymbols() -> [String]? {
        #if os(macOS)
        let base = "/System/Library/CoreServices/CoreGlyphs.bundle/Contents/Resources"

        guard let orderData = try? Data(contentsOf: URL(fileURLWithPath: "\(base)/symbol_order.plist")),
              let order = try? PropertyListSerialization.propertyList(from: orderData, format: nil) as? [String],
              !order.isEmpty
        else { return nil }

        var restricted: Set<String> = []
        if let data = try? Data(contentsOf: URL(fileURLWithPath: "\(base)/symbol_restrictions.strings")),
           let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] {
            restricted = Set(dict.keys)
        }

        let localized = try? NSRegularExpression(
            pattern: #"\.(rtl|ar|hi|he|ja|ko|th|zh|ur|gu|kn|ml|mr|ta|te|pa|or|as|km|my|si|lo|bn)\b"#
        )
        return order.filter { name in
            guard !restricted.contains(name) else { return false }
            guard let localized else { return true }
            let range = NSRange(name.startIndex..., in: name)
            return localized.firstMatch(in: name, options: [], range: range) == nil
        }
        #else
        return nil
        #endif
    }
}
