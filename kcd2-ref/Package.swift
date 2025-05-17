// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "kcd2_gear_picker",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "kcd2_gear_picker",
            dependencies: [
                .product(name: "Atomics", package: "swift-atomics")
            ],
            path: "Sources/kcd2_gear_picker_executable"
        )
    ]
)

