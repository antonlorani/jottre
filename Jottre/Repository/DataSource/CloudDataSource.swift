import class Foundation.FileManager

protocol CloudDataSourceProtocol {

    func getIsEnabled() -> Bool
}

final class CloudDataSource: CloudDataSourceProtocol {

    private let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    func getIsEnabled() -> Bool {
        fileManager.url(forUbiquityContainerIdentifier: nil) != nil
    }
}
