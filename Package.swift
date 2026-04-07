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
    dependencies: [
        .package(url: "https://github.com/cucumberswift/CucumberSwift", from: "5.0.9")
    ],
    targets: [
        .target(
            name: "Libratta",
            path: "Sources/Libratta"
        ),
        .testTarget(
            name: "LibrattaTests",
            dependencies: [
                "Libratta",
                .product(name: "CucumberSwift", package: "CucumberSwift")
            ],
            path: "LibrattaTests",
            resources: [
                .copy("Features")
            ]
        )
    ]
)
