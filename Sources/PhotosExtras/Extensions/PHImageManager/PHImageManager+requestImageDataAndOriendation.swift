import Photos

extension PHImageManager {
    
    public typealias ImageDataAndOrientation = (
        data: Data,
        dataUTI: String,
        orientation: CGImagePropertyOrientation
    )
    
    /// Requests the largest represented image as data bytes and EXIF orientation for the specified asset..
    /// - Parameters:
    ///   - asset: The photo asset to load the image data from.
    ///   - options: Configuration options for the request, such as delivery mode and progress handling.
    ///   - resultHandler: A closure that is called with a `Result` containing either a tuple with the image data (`Data`),
    ///     the Uniform Type Identifier (UTI) as a `String`, and the image orientation (`CGImagePropertyOrientation`) on success,
    ///     or an `Error` on failure.
    /// - Returns: The `PHImageRequestID` for the image data request, which can be used to track or cancel the request.
    public func requestImageDataAndOriendation(
        for asset: PHAsset,
        options: PHImageRequestOptions? = nil,
        resultHandler: @escaping (Result<ImageDataAndOrientation, Error>) -> Void
    ) -> PHImageRequestID {
        return requestImageDataAndOrientation(
            for: asset,
            options: options,
            resultHandler: { data, dataUTI, orientation, info in
                if let data, let dataUTI {
                    resultHandler(.success((data, dataUTI, orientation)))
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
