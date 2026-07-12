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
struct ColorPaletteRow: View {

    @Binding var selection: Color
    let palette: [Color]

    private let columns = Array(repeating: GridItem(.flexible(minimum: 24), spacing: 10), count: 10)
    private var selectedHex: String? { selection.toHex() }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(palette.enumerated()), id: \.offset) { _, color in
                Button {
                    selection = color
                } label: {
                    Circle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                        .overlay {
                            if color.toHex() == selectedHex {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
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
