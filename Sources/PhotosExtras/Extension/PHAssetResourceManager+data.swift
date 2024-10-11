import Photos

extension PHAssetResourceManager {
    
    /// Asynchronously retrieves the data for the specified asset resource.
    /// - Parameters:
    ///   - resource: The asset resource from which to request the data, such as an image or video file associated with a `PHAsset`.
    ///   - options: Configuration options for the request, such as network policy and progress handlers.
    /// - Throws: `NSError`: If an error occurs while retrieving the data.
    /// - Throws: `PHPhotosError(.internalError)`: If an unspecified internal error occurs during the request.
    /// - Returns: The raw data for the requested asset resource.
    public func data(
        for resource: PHAssetResource,
        options: PHAssetResourceRequestOptions? = nil
    ) async throws -> Data {
        nonisolated(unsafe) var request: PHAssetResourceDataRequestID?
        return try await withTaskCancellationHandler {
            try await withUnsafeThrowingContinuation { continuation in
                request = requestData(
                    for: resource,
                    options: options,
                    dataReceivedHandler: { data in
                        continuation.resume(returning: data)
                    },
                    completionHandler: { error in
                        if let nsError = error as? NSError {
                            continuation.resume(throwing: nsError)
                        } else {
                            continuation.resume(throwing: PHPhotosError(.internalError))
                        }
                    }
                )
            }
        } onCancel: {
            if let request {
                cancelDataRequest(request)
            }
        }
    }
}
