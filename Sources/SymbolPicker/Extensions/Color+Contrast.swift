//
//  Color+Contrast.swift
//  SymbolPicker
//
//  How light a color is, and the version of it that reads against a background
//  Created on 15/09/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension Color {

    /// The color's relative luminance in sRGB, 0 for black to 1 for white, or `nil` for a
    /// color that has no fixed components (a dynamic system color, say).
    ///
    /// The WCAG formula, which weights green most and blue least because that is how eyes
    /// weigh them. It answers the only question a tile has to ask: is a white glyph going to
    /// show on this?
    var relativeLuminance: Double? {
        guard let (red, green, blue) = sRGBComponents else { return nil }
        func channel(_ value: Double) -> Double {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(red) + 0.7152 * channel(green) + 0.0722 * channel(blue)
    }

    /// This color moved toward white (positive) or black (negative) by a fraction of the way.
    ///
    /// `mixed(toward: 0.3)` on GitHub's near-black gives a charcoal a glyph can sit on;
    /// `mixed(toward: -0.2)` on a pale yellow gives one a white glyph can sit on.
    func mixed(toward amount: Double) -> Color {
        guard let (red, green, blue) = sRGBComponents else { return self }
        let target: Double = amount >= 0 ? 1 : 0
        let fraction = min(abs(amount), 1)
        func mix(_ value: Double) -> Double { value + (target - value) * fraction }
        return Color(.sRGB, red: mix(red), green: mix(green), blue: mix(blue), opacity: 1)
    }

    /// Red, green and blue in sRGB, or `nil` when the color cannot be resolved to them.
    private var sRGBComponents: (Double, Double, Double)? {
        #if canImport(AppKit)
        guard let rgb = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        return (Double(rgb.redComponent), Double(rgb.greenComponent), Double(rgb.blueComponent))
        #elseif canImport(UIKit)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return (Double(red), Double(green), Double(blue))
        #else
        return nil
        #endif
    }
}
