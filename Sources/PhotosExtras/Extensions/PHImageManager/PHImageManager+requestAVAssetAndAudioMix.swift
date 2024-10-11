#if canImport(Photos)
import Photos

extension PHImageManager {
    
    public typealias AVAssetAndAudioMix = (
        asset: AVAsset,
        audioMix: AVAudioMix?
    )
    
    /// Requests` AVFoundation` objects representing the video asset’s content and state, to be loaded asynchronously..
    /// - Parameters:
    ///   - asset: The video asset to load the `AVAsset` and audio mix from.
    ///   - options: Configuration options for the request, such as network policy and delivery mode.
    ///   - resultHandler: A closure that gets called with a `Result` containing either
    ///     a tuple with the `AVAsset` and an optional `AVAudioMix` (on success) or an `Error` (on failure).
    /// - Returns: The `PHImageRequestID` for the AV asset request, which can be used to track or cancel the request.
    public func requestAVAssetAndAudioMix(
        forVideo asset: PHAsset,
        options: PHVideoRequestOptions? = nil,
        resultHandler: @escaping (Result<AVAssetAndAudioMix, Error>) -> Void
    ) -> PHImageRequestID {
        return requestAVAsset(
            forVideo: asset,
            options: options,
            resultHandler: { avAsset, avAudioMix, info in
                if let avAsset {
                    resultHandler(.success((avAsset, avAudioMix)))
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
