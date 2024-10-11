import Photos

extension PHAssetResourceManager {
    
    /// Requests the underlying data for the specified asset resource, to be delivered asynchronously..
    /// - Parameters:
    ///   - resource: The asset resource to load the data from.
    ///   - options: Configuration options for the request, such as network access and progress handling. Defaults to `nil`.
    ///   - data: A closure called incrementally with chunks of `Data` as they are received.
    ///   - completion: A closure called upon completion with a `Result` indicating success or failure with an NSError.
    /// - Returns: The `PHAssetResourceDataRequestID` for the data request, which can be used to track or cancel the request.
    public func requestData(
        for resource: PHAssetResource,
        options: PHAssetResourceRequestOptions? = nil,
        data: @escaping (Data) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> PHAssetResourceDataRequestID {
        return requestData(
            for: resource,
            options: options,
            dataReceivedHandler: data,
            completionHandler: { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        )
    }
}
