//
//  Color+Hex.swift
//  SymbolPicker
//
//  Hex <-> SwiftUI Color bridging so selections survive as strings
//  Created on 13/07/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension Color {

    /// Creates a color from a hex string such as `"#FF5733"`, `"FF5733"`, or 8-digit `"#FF5733CC"`.
    ///
    /// ## Example
    /// ```swift
    /// let tint = Color(hex: "#3498DB")   // opaque blue
    /// let faded = Color(hex: "3498DB80") // 50% alpha
    /// ```
    ///
    /// - Parameter hex: A 6- or 8-digit hex string, with or without a leading `#`.
    /// - Returns: The color, or `nil` if the string is malformed.
    init?(hex: String) {
        var string = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.hasPrefix("#") { string.removeFirst() }
        guard string.count == 6 || string.count == 8,
              let value = UInt64(string, radix: 16) else { return nil }

        let red, green, blue, alpha: Double
        if string.count == 8 {
            red = Double((value >> 24) & 0xFF) / 255
            green = Double((value >> 16) & 0xFF) / 255
            blue = Double((value >> 8) & 0xFF) / 255
            alpha = Double(value & 0xFF) / 255
        } else {
            red = Double((value >> 16) & 0xFF) / 255
            green = Double((value >> 8) & 0xFF) / 255
            blue = Double(value & 0xFF) / 255
            alpha = 1
        }
        self = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    /// The color as an uppercase 6-digit hex string such as `"#FF5733"`.
    ///
    /// Resolves the color in the sRGB space. Returns `nil` on platforms or colors that can't be resolved
    /// to concrete RGB components (e.g. certain dynamic system colors).
    func toHex() -> String? {
        #if canImport(AppKit)
        guard let rgb = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        let red = Int(round(rgb.redComponent * 255))
        let green = Int(round(rgb.greenComponent * 255))
        let blue = Int(round(rgb.blueComponent * 255))
        #elseif canImport(UIKit)
        var redComponent: CGFloat = 0, greenComponent: CGFloat = 0
        var blueComponent: CGFloat = 0, alphaComponent: CGFloat = 0
        guard UIColor(self).getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha: &alphaComponent)
        else { return nil }
        let red = Int(round(redComponent * 255))
        let green = Int(round(greenComponent * 255))
        let blue = Int(round(blueComponent * 255))
        #else
        return nil
        #endif
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
