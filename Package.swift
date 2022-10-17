// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swizzlean",
    products: [
        .library(
            name: "Swizzlean",
            targets: ["Swizzlean"])
    ],
    targets: [
        .target(
            name: "Swizzlean"),
        .testTarget(
            name: "SwizzleanTests",
            dependencies: ["Swizzlean"])
    ]
)
