//
//  SymbolPickerPalette.swift
//  SymbolPicker
//
//  Curated color palettes for the picker's color row
//  Created on 13/07/2026.
//

import SwiftUI

/// Ready-made color palettes for the picker's color row.
///
/// Pass one to ``SymbolPicker`` or supply your own `[Color]`.
///
/// ## Example
/// ```swift
/// SymbolPicker(symbol: $icon, color: $tint, palette: SymbolPickerPalette.shortcuts)
/// ```
public enum SymbolPickerPalette {

    /// The accent colors used by Apple's Shortcuts symbol picker, in order.
    public static let shortcuts: [Color] = [
        "#FB5A55", "#F2864B", "#F6A73E", "#F5C43F", "#88C540", "#38B7A4",
        "#5AC8E8", "#3B82F6", "#4F63D2", "#7A5CD0", "#A45DD6", "#E85AAE",
        "#8E8E93", "#A7B39A", "#B49B7E"
    ].compactMap(Color.init(hex:))
}
