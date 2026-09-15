//
//  SymbolTile.swift
//  SymbolPicker
//
//  A symbol on a colored tile, the way Shortcuts and System Settings draw one
//  Created on 15/09/2026.
//

import SwiftUI

/// An SF Symbol on a filled tile of a color, drawn so it reads whatever the color is.
///
/// A brand color is chosen for a logo on white. On a dark window a near-black tile with a
/// near-black glyph is a hole, and a tile painted at 18% opacity is a smudge; both were what
/// a metric's icon looked like once its color came from the service. This fills the tile
/// with the color, lifts a very dark one on a dark background (and drops a very light one on
/// a light background) just far enough to be a shape, and puts the glyph in white or near-black
/// by the tile's own luminance — the rule Shortcuts uses for its own icons.
///
/// ## Example
/// ```swift
/// SymbolTile(symbol: "star.fill", color: Color(hex: "#24292E")!, size: 32)
/// SymbolTile(symbol: "cloud.sun.fill", color: .blue, size: 40, shape: .rounded)
/// ```
public struct SymbolTile: View {

    /// The tile's outline.
    public enum Shape: Sendable {
        /// A circle — a list row, a card corner.
        case circle
        /// A continuous rounded square — an app-icon shape, for larger sizes.
        case rounded
    }

    private let symbol: String
    private let color: Color
    private let size: CGFloat
    private let shape: Shape

    @Environment(\.colorScheme) private var colorScheme

    /// - Parameters:
    ///   - symbol: The SF Symbol name.
    ///   - color: The tile's color, as chosen — the view decides how to show it.
    ///   - size: The tile's width and height in points.
    ///   - shape: Circle or rounded square.
    public init(symbol: String, color: Color, size: CGFloat = 32, shape: Shape = .circle) {
        self.symbol = symbol
        self.color = color
        self.size = size
        self.shape = shape
    }

    public var body: some View {
        ZStack {
            tileShape
                .fill(LinearGradient(colors: [fill.mixed(toward: 0.12), fill],
                                     startPoint: .top, endPoint: .bottom))
            tileShape
                .strokeBorder(Color.white.opacity(0.14), lineWidth: max(size / 40, 0.5))
            Image(systemName: symbol)
                .font(.system(size: size * 0.46, weight: .semibold))
                .foregroundStyle(glyph)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var tileShape: AnyInsettableShape {
        switch shape {
        case .circle: AnyInsettableShape(Circle())
        case .rounded: AnyInsettableShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        }
    }

    /// The color as shown: lifted when it would vanish into a dark window, dropped when it
    /// would vanish into a light one. Anything in the middle is left exactly as chosen.
    private var fill: Color { color.legible(in: colorScheme) }

    /// White on anything darker than mid-grey, near-black on anything lighter
    private var glyph: Color {
        guard let luminance = fill.relativeLuminance else { return .white }
        return luminance > 0.55 ? Color.black.opacity(0.82) : .white
    }
}

/// A type-erased insettable shape, so one `ZStack` can fill and stroke whichever outline
/// was asked for without two copies of the body.
private struct AnyInsettableShape: InsettableShape {
    private let pathBuilder: @Sendable (CGRect) -> Path
    private let insetBuilder: @Sendable (CGFloat) -> AnyInsettableShape

    init<S: InsettableShape>(_ shape: S) {
        pathBuilder = { shape.path(in: $0) }
        insetBuilder = { AnyInsettableShape(shape.inset(by: $0)) }
    }

    func path(in rect: CGRect) -> Path { pathBuilder(rect) }
    func inset(by amount: CGFloat) -> AnyInsettableShape { insetBuilder(amount) }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 12) {
        SymbolTile(symbol: "octagon.fill", color: Color(hex: "#24292E")!, size: 40)
        SymbolTile(symbol: "cloud.sun.fill", color: .blue, size: 40)
        SymbolTile(symbol: "sun.max.fill", color: Color(hex: "#FFD60A")!, size: 40, shape: .rounded)
        SymbolTile(symbol: "bitcoinsign.circle.fill", color: Color(hex: "#F7931A")!, size: 24)
    }
    .padding()
}
