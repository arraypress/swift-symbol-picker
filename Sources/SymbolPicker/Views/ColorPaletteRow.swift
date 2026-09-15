//
//  ColorPaletteRow.swift
//  SymbolPicker
//
//  The color swatch grid shown above the symbol grid, styled like Shortcuts
//  Created on 13/07/2026.
//

import SwiftUI

/// The color swatches shown above the symbol grid. Selecting a swatch writes it to the bound color, and
/// the swatch whose color matches shows a checkmark — mirroring Apple's Shortcuts picker.
///
/// The geometry is Shortcuts' own, measured off its picker at 2×: 17-point swatches, ten to a row,
/// 12 points apart both ways. Smaller and further apart than a first guess would draw them — that
/// air between the dots is most of what makes the row read as Apple's.
struct ColorPaletteRow: View {

    @Binding var selection: Color
    let palette: [Color]

    static let swatchSize: CGFloat = 17
    static let spacing: CGFloat = 12

    private let columns = Array(repeating: GridItem(.flexible(minimum: swatchSize), spacing: spacing), count: 10)
    private var selectedHex: String? { selection.toHex() }

    var body: some View {
        LazyVGrid(columns: columns, spacing: Self.spacing) {
            ForEach(Array(palette.enumerated()), id: \.offset) { _, color in
                Button {
                    selection = color
                } label: {
                    Circle()
                        .fill(color)
                        .frame(width: Self.swatchSize, height: Self.swatchSize)
                        .overlay {
                            if color.toHex() == selectedHex {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .help(color.toHex() ?? "")
            }
        }
    }
}
