#if (canImport(AppKit) || canImport(UIKit))
import Photos

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension PHImageManager {
    
    #if canImport(AppKit)
    public typealias PlatformImage = NSImage
    #elseif canImport(UIKit)
    public typealias PlatformImage = UIImage
    #endif
    
    /// Requests an image representation for the specified asset.
    /// - Parameters:
    ///   - asset: The photo asset to load the image from.
    ///   - targetSize: The desired image size. Defaults to `PHImageManagerMaximumSize`.
    ///   - contentMode: How to fit the image to the target size. Defaults to `.default`.
    ///   - options: Configuration options for the request, such as delivery mode and progress handling.
    ///   - resultHandler: A closure that is called with a `Result` containing either the image object
    ///     and a boolean indicating if the image is degraded (on success) or an `Error` (on failure).
    /// - Returns: The `PHImageRequestID` for the image request, which can be used to track or cancel the request.
    public func requestImage(
        for asset: PHAsset,
        targetSize: CGSize = PHImageManagerMaximumSize,
        contentMode: PHImageContentMode = .default,
        options: PHImageRequestOptions? = nil,
        resultHandler: @escaping (Result<(image: PlatformImage, isDegraded: Bool), Error>) -> Void
    ) -> PHImageRequestID {
        return requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: contentMode,
            options: options,
            resultHandler: { image, info in
                if let image {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                    resultHandler(.success((image, isDegraded)))
                } else if let nsError = info?[PHImageErrorKey] as? NSError {
                    resultHandler(.failure(nsError))
                } else if let isCancelled = info?[PHImageCancelledKey] as? Bool, isCancelled {
                    resultHandler(.failure(PHPhotosError(.userCancelled)))
                } else if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool, isInCloud {
                    resultHandler(.failure(PHPhotosError(.networkAccessRequired)))
                } else {
                    resultHandler(.failure(PHPhotosError(.internalError)))
                }
            }
        )
    }
}
#endif
