//
//  SymbolPickerTests.swift
//  SymbolPicker
//
//  Created on 13/07/2026.
//

import XCTest
import SwiftUI
@testable import SymbolPicker

final class SymbolPickerTests: XCTestCase {

    // MARK: - Color + Hex

    func testHexRoundTrip() throws {
        let color = try XCTUnwrap(Color(hex: "#FF5733"))
        XCTAssertEqual(color.toHex(), "#FF5733")
    }

    func testHexWithoutHashSign() throws {
        let color = try XCTUnwrap(Color(hex: "3498DB"))
        XCTAssertEqual(color.toHex(), "#3498DB")
    }

    func testHexRejectsMalformedInput() {
        XCTAssertNil(Color(hex: "nope"))
        XCTAssertNil(Color(hex: "#12"))
        XCTAssertNil(Color(hex: ""))
    }

    // MARK: - Palette

    func testShortcutsPaletteIsComplete() {
        XCTAssertEqual(SymbolPickerPalette.shortcuts.count, 15)
    }

    // MARK: - Bundled catalog

    func testBundledCatalogDecodes() {
        let bundled = SymbolCatalog.bundledCatalog()
        XCTAssertFalse(bundled.categories.isEmpty, "bundled categories should decode")
        XCTAssertFalse(bundled.symbols.isEmpty, "bundled search list should decode")
    }

    func testBundledCatalogHasExpectedContent() {
        let bundled = SymbolCatalog.bundledCatalog()
        XCTAssertTrue(bundled.categories.contains { $0.key == "weather" })
        XCTAssertTrue(bundled.symbols.contains("star"))
    }
}
