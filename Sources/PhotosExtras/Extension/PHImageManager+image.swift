import Photos
import UIKit

extension PHImageManager {
    
    /// Asynchronously retrieves a `UIImage` from the specified `PHAsset`.
    /// - Parameters:
    ///   - asset: The photo asset to load the image from.
    ///   - size: The desired image size. Defaults to `PHImageManagerMaximumSize`.
    ///   - contentMode: How to fit the image to the target size. Defaults to `.default`.
    ///   - options: Configuration options for the request, such as delivery mode, and progress handling.
    /// - Throws: `NSError`: If an error occurs while retrieving the image.
    /// - Throws: `CancellationError`: If the operation is cancelled before completion.
    /// - Throws: `PHPhotosError(.networkAccessRequired)`: If the image is only available in iCloud and network access is required to download it.
    /// - Throws: `PHPhotosError(.internalError)`: If an unspecified internal error occurs.
    /// - Returns: The retrieved `UIImage`.
    public func image(
        for asset: PHAsset,
        size: CGSize = PHImageManagerMaximumSize,
        contentMode: PHImageContentMode = .default,
        options: PHImageRequestOptions? = nil
    ) async throws -> UIImage {
        nonisolated(unsafe) var request: PHImageRequestID?
        return try await withTaskCancellationHandler {
            try await withUnsafeThrowingContinuation { continuation in
                request = requestImage(
                    for: asset,
                    targetSize: size,
                    contentMode: contentMode,
                    options: options,
                    resultHandler: { image, info in
                        if let image {
                            continuation.resume(returning: image)
                        } else if let nsError = info?[PHImageErrorKey] as? NSError {
                            continuation.resume(throwing: nsError)
                        } else if let isCancelled = info?[PHImageCancelledKey] as? Bool, isCancelled {
                            continuation.resume(throwing: CancellationError())
                        } else if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool, isInCloud {
                            continuation.resume(throwing: PHPhotosError(.networkAccessRequired))
                        } else if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, isDegraded {
                            // The handler will be called again for a non-degraded image.
                            return
                        } else {
                            continuation.resume(throwing: PHPhotosError(.internalError))
                        }
                    }
                )
            }
        } onCancel: {
            if let request {
                cancelImageRequest(request)
            }
        }
    }
}
