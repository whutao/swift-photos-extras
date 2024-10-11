// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "swift-photos-extras",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "PhotosExtras", targets: ["PhotosExtras"]),
    ],
    targets: [
        .target(name: "PhotosExtras")
    ]
)
