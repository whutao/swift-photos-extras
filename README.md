<p>
    <img src="https://img.shields.io/badge/Swift-5.10-orange.svg" />
    <img src="https://img.shields.io/badge/platform-iOS-lightgrey.svg">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" />
</p>

# PhotosExtras

This package extends the functionality of the Photos framework by providing convenient async/await-based methods.

## Motivation

Consider the `PHImageManager` method `requestImage(for:targetSize:contentMode:options:resultHandler:)`. When using this method, developers must manually handle request cancellation by keeping track of the `PHImageRequestID` object. Additionally, they need to extract errors from the result handler callback using Photos-specific keys, such as:: 

```swift
let requestId = PHImageManager.default().image(
    for: phAsset,
    targetSize: previewImageSize,
    contentMode: .aspectFill,
    options: options,
    resultHandler: { [weak self] image, info in
        if let image {
            self?.previewImage = image
        } else if let error = info?[PHImageErrorKey] as? NSError {
            print(error)
        } else {
            ...
        }
    }
)

...

PHImageManager.default().cancelImageRequest(requestId)
```

This library allows to achieve the same result in much more elegant way:

```swift
Task {
    do {
        // No need to store and handle `PHImageRequestID`.
        previewImage = try await PHImageManager.default().image(
            for: phAsset,
            targetSize: previewImageSize,
            contentMode: .aspectFill,
            options: options
        )
    } catch {
        // Possible errors retrieved from
        // the `info` dictionary inside the resultHandler.
        print(error)
    }
}

// To cancel a fetch, simply cancel the launched task or its parent!
// There's no need to explicitly call cancelImageRequest(_:).
```

## Installation

You can add the library to an Xcode project by adding it as a package dependency.

> https://github.com/whutao/swift-photos-extras

If you want to use the library in a [SwiftPM](https://swift.org/package-manager/) project,
it's as simple as adding it to a `dependencies` clause in your `Package.swift`:

``` swift
dependencies: [
    .package(
        url: "https://github.com/whutao/swift-photos-extras", 
        from: Version(1, 0, 0)
    )
]
```

## License

This library is released under the MIT License. See the [LICENSE](LICENSE) file for more details.
