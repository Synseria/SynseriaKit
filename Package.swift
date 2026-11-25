// swift-tools-version: 6.4
// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit

import PackageDescription

let package = Package(
    name: "SynseriaKit",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "SynseriaDesign", targets: ["SynseriaDesign"]),
        .library(name: "Telemetrie", targets: ["Telemetrie"]),
        .library(name: "MiseAJour", targets: ["MiseAJour", "Versions"]),
    ],
    targets: [
        .target(name: "SynseriaDesign", path: "Sources/SynseriaDesign"),
        .target(name: "Versions", path: "Sources/Versions"),
        .target(name: "Telemetrie", dependencies: ["Versions"], path: "Sources/Telemetrie"),
        .target(name: "MiseAJour", dependencies: ["Versions"], path: "Sources/MiseAJour"),
    ],
    swiftLanguageModes: [.v6]
)
