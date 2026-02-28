// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarketRate",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "MarketRate", targets: ["MarketRate"])
    ],
    targets: [
        .target(name: "MarketRate", path: "Sources"),
        .testTarget(name: "MarketRateTests", dependencies: ["MarketRate"], path: "Tests")
    ]
)
