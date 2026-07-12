//
//  ColorPaletteRow.swift
//  SymbolPicker
//
//  The horizontal color row shown above the symbol grid
//  Created on 13/07/2026.
//

import SwiftUI

/// The color swatches shown above the symbol grid. Selecting a swatch writes it to the bound color.
struct ColorPaletteRow: View {

    @Binding var selection: Color
    let palette: [Color]

    private let columns = Array(repeating: GridItem(.flexible(minimum: 20), spacing: 8), count: 10)
    private var selectedHex: String? { selection.toHex() }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(palette.enumerated()), id: \.offset) { _, color in
                Button {
                    selection = color
                } label: {
                    Circle()
                        .fill(color)
                        .frame(width: 22, height: 22)
                        .overlay {
                            if let selectedHex, color.toHex() == selectedHex {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .overlay(Circle().strokeBorder(.primary.opacity(0.08)))
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .help(color.toHex() ?? "")
            }
        }
    }
}
