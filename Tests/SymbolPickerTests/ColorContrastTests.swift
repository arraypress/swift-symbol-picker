import XCTest
import SwiftUI
@testable import SymbolPicker

/// How light a color is, and the version of it a glyph can sit on.
final class ColorContrastTests: XCTestCase {

    func testLuminanceRunsFromBlackToWhite() throws {
        XCTAssertEqual(try XCTUnwrap(Color.black.relativeLuminance), 0, accuracy: 0.001)
        XCTAssertEqual(try XCTUnwrap(Color.white.relativeLuminance), 1, accuracy: 0.001)
        let github = try XCTUnwrap(Color(hex: "#24292E")?.relativeLuminance)
        XCTAssertLessThan(github, 0.05, "GitHub's near-black is the case a dark window swallows")
        let yellow = try XCTUnwrap(Color(hex: "#FFD60A")?.relativeLuminance)
        XCTAssertGreaterThan(yellow, 0.6, "and a warm yellow is the case a white glyph vanishes on")
    }

    func testMixingMovesTowardTheEndsAndStopsThere() throws {
        let lifted = Color(hex: "#000000")!.mixed(toward: 0.4)
        XCTAssertEqual(try XCTUnwrap(lifted.toHex()), "#666666", "0.4 of the way from black to white, off the half-step where sRGB rounding wobbles")
        let dropped = Color(hex: "#FFFFFF")!.mixed(toward: -0.2)
        XCTAssertEqual(try XCTUnwrap(dropped.toHex()), "#CCCCCC")
        XCTAssertEqual(Color(hex: "#123456")!.mixed(toward: 0).toHex(), "#123456", "nothing asked, nothing moved")
        XCTAssertEqual(Color(hex: "#123456")!.mixed(toward: 5).toHex(), "#FFFFFF", "clamped to all the way")
    }

    func testALegibleColorIsLiftedOnDarkDroppedOnLightAndOtherwiseLeftAlone() throws {
        let black = Color(hex: "#000000")!
        XCTAssertEqual(black.legible(in: .dark).toHex(), black.mixed(toward: 0.30).toHex(), "a hole on a dark window becomes a shape")
        XCTAssertGreaterThan(try XCTUnwrap(black.legible(in: .dark).relativeLuminance), 0.05)
        XCTAssertEqual(black.legible(in: .light).toHex(), "#000000", "and stays black on white, where black is a color")
        let white = Color(hex: "#FFFFFF")!
        XCTAssertEqual(white.legible(in: .light).toHex(), "#C7C7C7")
        XCTAssertEqual(white.legible(in: .dark).toHex(), "#FFFFFF")
        let brand = Color(hex: "#635BFF")!
        XCTAssertEqual(brand.legible(in: .dark).toHex(), "#635BFF", "Stripe's purple is left exactly as chosen")
        XCTAssertEqual(brand.legible(in: .light).toHex(), "#635BFF")
    }
}
