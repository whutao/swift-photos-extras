import Photos
import UIKit

extension PHImageManager {
    
    /// Asynchronously retrieves a video asset’s content as an `AVAsset` and optional `AVAudioMix`.
    /// - Parameters:
    ///   - phAsset: The video asset to load the `AVAsset` and audio mix from.
    ///   - options: Configuration options for the request, such as network policy and delivery mode.
    /// - Throws: `NSError`: If an error occurs while retrieving the video asset.
    /// - Throws: `CancellationError`: If the request is cancelled before it completes.
    /// - Throws: `PHPhotosError(.networkAccessRequired)`: If the video asset is only available in iCloud and needs network access to download.
    /// - Throws: `PHPhotosError(.internalError)`: If an unspecified internal error occurs during the request.
    /// - Returns: A tuple containing the video asset (`AVAsset`) and an optional audio mix (`AVAudioMix`), if available.
    public func avAssetAndAudioMix(
        forVideo phAsset: PHAsset,
        options: PHVideoRequestOptions? = nil
    ) async throws -> (avAsset: AVAsset, avAudioMix: AVAudioMix?) {
        nonisolated(unsafe) var request: PHImageRequestID?
        return try await withTaskCancellationHandler {
            try await withUnsafeThrowingContinuation { continuation in
                request = requestAVAsset(
                    forVideo: phAsset,
                    options: options,
                    resultHandler: { avAsset, avAudioMix, info in
                        if let avAsset {
                            continuation.resume(returning: (avAsset, avAudioMix ))
                        } else if let nsError = info?[PHImageErrorKey] as? NSError {
                            continuation.resume(throwing: nsError)
                        } else if let isCancelled = info?[PHImageCancelledKey] as? Bool, isCancelled {
                            continuation.resume(throwing: CancellationError())
                        } else if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool, isInCloud {
                            continuation.resume(throwing: PHPhotosError(.networkAccessRequired))
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
