// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShrinkItArchive",
    platforms: [.macOS(.v13),.visionOS(.v1),.iOS(.v16),.tvOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ShrinkItArchive",
            targets: ["ShrinkItArchive"]),
        .executable(
          name: "NufxScan",
          targets: ["NufxScan"])
    ],
    dependencies: [
      .package(
        url: "https://github.com/bastie/JavApi4Swift.git",
        .upToNextMajor(from: "0.12.2")
      )
    ],
    targets: [
      // Targets are the basic building blocks of a package, defining a module or a test suite.
      // Targets can depend on other targets in this package and products from dependencies.
      .target(
          name: "ShrinkItArchive",
          dependencies: [
            .product(name: "JavApi", package: "JavApi4Swift"),
          ]
      ),
      .executableTarget(
        name: "NufxScan",
        dependencies: [
          .product(name: "JavApi", package: "JavApi4Swift"),
          .targetItem(name: "ShrinkItArchive", condition: nil)
        ],
        swiftSettings: [
          .enableExperimentalFeature("StrictConcurrency")
        ]
      ),
      .testTarget(
          name: "ShrinkItArchiveTests",
          dependencies: ["ShrinkItArchive"]),
   ]
)
