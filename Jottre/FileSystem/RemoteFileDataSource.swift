import Foundation
import Combine

struct RemoteFileDataSource {

    private let fileManager: FileManager
    private let localFileDataSource: LocalFileDataSource

    init(
        fileManager: FileManager,
        localFileDataSource: LocalFileDataSource
    ) {
        self.fileManager = fileManager
        self.localFileDataSource = localFileDataSource
    }

    func isRemoteFile(url: URL) -> Bool {
        guard let attributes = try? url.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey]),
              let status = attributes.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus
        else {
            return false
        }
        return status == .notDownloaded
    }

    func downloadFile(url: URL) {
        try? fileManager.startDownloadingUbiquitousItem(at: url)
    }
    
    func getDirectory() -> URL? {
        guard let url = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            return nil
        }

        if localFileDataSource.getFileExists(path: url.path, isDirectory: true) {
            return url
        }

        guard ((try? fileManager.createDirectory(at: url, withIntermediateDirectories: false)) != nil) else {
            return nil
        }

        return url
    }
}
