import Photos

extension PHAsset {
    
    /// Requests asset information for beginning a content editing session..
    /// - Parameters:
    ///   - options: Options to configure the content editing input request, such as specifying
    ///     whether the asset can be downloaded from iCloud.
    ///   - completionHandler: A closure that gets called with a `Result` containing
    ///     either the `PHContentEditingInput` object (on success) or an `Error` (on failure).
    /// - Returns: The `PHContentEditingInputRequestID` for the content editing input request,
    ///   which can be used to track or cancel the request.
    public func requestContentEditingInput(
        options: PHContentEditingInputRequestOptions? = nil,
        completionHandler: @escaping (Result<PHContentEditingInput, Error>) -> Void
    ) -> PHContentEditingInputRequestID {
        return requestContentEditingInput(
            with: options,
            completionHandler: { contentEditingInput, info in
                if let contentEditingInput {
                    completionHandler(.success(contentEditingInput))
                } else if let nsError = info[PHContentEditingInputErrorKey] as? NSError {
                    completionHandler(.failure(nsError))
                } else if let isCancelled = info[PHContentEditingInputCancelledKey] as? Bool, isCancelled {
                    completionHandler(.failure(PHPhotosError(.userCancelled)))
                } else if let isInCloud = info[PHContentEditingInputResultIsInCloudKey] as? Bool, isInCloud {
                    completionHandler(.failure(PHPhotosError(.networkAccessRequired)))
                } else {
                    completionHandler(.failure(PHPhotosError(.internalError)))
                }
            }
        )
    }
}
