// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "swift-photos-extras",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "PhotosExtras", targets: ["PhotosExtras"]),
    ],
    targets: [
        .target(name: "PhotosExtras")
    ]
)
