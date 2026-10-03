// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppUpdateKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "AppUpdateKit",
            targets: ["AppUpdateKit"]
        )
    ],
    targets: [
        .target(
            name: "AppUpdateKit",
            path: "Sources/AppUpdateKit"
        ),
        .testTarget(
            name: "AppUpdateKitTests",
            dependencies: ["AppUpdateKit"],
            path: "Tests/AppUpdateKitTests"
        )
    ]
)
