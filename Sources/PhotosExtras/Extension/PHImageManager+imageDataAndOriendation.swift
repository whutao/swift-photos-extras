import CoreGraphics
import Photos

extension PHImageManager {
    
    /// Asynchronously retrieves the largest available image data and EXIF orientation for the specified `PHAsset`.
    /// - Parameters:
    ///   - asset: The photo asset to load the image data from.
    ///   - options: Configuration options for the request, such as delivery mode, and progress handling.
    /// - Throws: `NSError`: If an error occurs while retrieving the image data.
    /// - Throws: `CancellationError`: If the operation is cancelled before completion.
    /// - Throws: `PHPhotosError(.networkAccessRequired)`: If the image data is only available in iCloud and requires network access to download.
    /// - Throws: `PHPhotosError(.internalError)`: If an unspecified internal error occurs during the request.
    /// - Returns: A tuple containing the image data, the Uniform Type Identifier (UTI) for the data format, and the image orientation.
    public func imageDataAndOriendation(
        for asset: PHAsset,
        options: PHImageRequestOptions? = nil
    ) async throws -> (data: Data, dataUTI: String, orientation: CGImagePropertyOrientation) {
        nonisolated(unsafe) var request: PHImageRequestID?
        return try await withTaskCancellationHandler {
            try await withUnsafeThrowingContinuation { continuation in
                request = requestImageDataAndOrientation(
                    for: asset,
                    options: options,
                    resultHandler: { data, dataUTI, orientation, info in
                        if let data, let dataUTI {
                            continuation.resume(returning: (data, dataUTI, orientation))
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
