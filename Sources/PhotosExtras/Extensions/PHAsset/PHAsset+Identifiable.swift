import Photos

extension PHAsset: @retroactive Identifiable {
    
    public var id: String {
        return localIdentifier
    }
}
