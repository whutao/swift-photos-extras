import Photos
import UIKit

extension PHImageManager {
    
    /// Asynchronously retrieves the `URL` of a video asset from its `AVURLAsset` representation.
    /// - Parameters:
    ///   - asset: The video asset for which the `URL` is to be obtained.
    ///   - options: Configuration options for the request, such as network policy and delivery mode.
    /// - Throws: `PHPhotosError(.invalidResource)`: If the retrieved asset is not a valid `AVURLAsset`.
    /// - Throws: `NSError`: If an error occurs while fetching the video asset.
    /// - Throws: `CancellationError`: If the request is cancelled before completion.
    /// - Throws: `PHPhotosError(.networkAccessRequired)`: If the video is only available in iCloud and requires network access to download.
    /// - Throws: `PHPhotosError(.internalError)`: If an unspecified internal error occurs during the request.
    /// - Returns: The `URL` of the requested video asset.
    public func url(
        forVideo asset: PHAsset,
        options: PHVideoRequestOptions? = nil
    ) async throws -> URL {
        let (avAsset, _) = try await avAssetAndAudioMix(forVideo: asset, options: options)
        guard let avURLAsset = avAsset as? AVURLAsset else {
            throw PHPhotosError(.invalidResource)
        }
        return avURLAsset.url
    }
}
