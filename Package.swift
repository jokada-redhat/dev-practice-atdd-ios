// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Libratta",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Libratta",
            targets: ["Libratta"]
        )
    ],
    targets: [
        .target(
            name: "Libratta",
            path: "Sources/Libratta"
        ),
        .testTarget(
            name: "LibrattaTests",
            dependencies: ["Libratta"],
            path: "LibrattaTests",
            resources: [
                .copy("Features")
            ]
        )
    ]
)
