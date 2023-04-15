// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "OpenAI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "OpenAI",
            targets: ["OpenAI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.5.0"))
    ],
    targets: [
        .target(
            name: "OpenAI",
            dependencies: ["Alamofire"]),
        .testTarget(
            name: "OpenAITests",
            dependencies: ["OpenAI"]),
    ]
)
