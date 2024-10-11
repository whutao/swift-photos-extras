import Photos

extension PHCollection: @retroactive Identifiable {
    
    public var id: String {
        return localIdentifier
    }
}
