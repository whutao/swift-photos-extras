import Photos
import UIKit

extension PHAsset {

    /// Asynchronously retrieves a content editing input for the specified asset, which provides access to the original image or video data.
    /// - Parameters:
    ///   - options: Options to configure the content editing input request, such as specifying whether the asset can be downloaded from iCloud.
    /// - Throws: `NSError`: If an error occurs while retrieving the content editing input.
    /// - Throws: `CancellationError`: If the request is cancelled before it completes.
    /// - Throws: `PHPhotosError(.networkAccessRequired)`: If the asset is only available in iCloud and requires network access for download.
    /// - Throws: `PHPhotosError(.internalError)`: If an unspecified internal error occurs during the request.
    /// - Returns: The `PHContentEditingInput` object, which provides access to the original asset data and adjustment data for editing.
    public func contentEditingInput(
        options: PHContentEditingInputRequestOptions? = nil
    ) async throws -> PHContentEditingInput {
        nonisolated(unsafe) var request: PHContentEditingInputRequestID?
        return try await withTaskCancellationHandler {
            try await withUnsafeThrowingContinuation { continuation in
                request = requestContentEditingInput(
                    with: options,
                    completionHandler: { contentEditingInput, info in
                        if let contentEditingInput {
                            continuation.resume(returning: contentEditingInput)
                        } else if let nsError = info[PHContentEditingInputErrorKey] as? NSError {
                            continuation.resume(throwing: nsError)
                        } else if let isCancelled = info[PHContentEditingInputCancelledKey] as? Bool, isCancelled {
                            continuation.resume(throwing: CancellationError())
                        } else if let isInCloud = info[PHContentEditingInputResultIsInCloudKey] as? Bool, isInCloud {
                            continuation.resume(throwing: PHPhotosError(.networkAccessRequired))
                        } else {
                            continuation.resume(throwing: PHPhotosError(.internalError))
                        }
                    }
                )
            }
        } onCancel: {
            if let request {
                cancelContentEditingInputRequest(request)
            }
        }
    }
}
