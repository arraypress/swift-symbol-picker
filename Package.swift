// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SymbolPicker",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SymbolPicker",
            targets: ["SymbolPicker"]),
    ],
    targets: [
        .target(
            name: "SymbolPicker",
            resources: [
                .process("Resources/SymbolCatalog.json")
            ]),
        .testTarget(
            name: "SymbolPickerTests",
            dependencies: ["SymbolPicker"]),
    ]
)
