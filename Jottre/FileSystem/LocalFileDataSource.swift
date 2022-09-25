import Foundation
import Combine

struct LocalFileDataSource {

    static var shared = LocalFileDataSource(fileManager: .default)

    private let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    func getModifiedDate(url: URL) -> Date? {
        guard let attributes = try? fileManager.attributesOfItem(atPath: url.path) else {
            return nil
        }
        return attributes[FileAttributeKey.modificationDate] as? Date
    }

    func getFileData(url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    func getFiles(path: String) -> [String] {
        (try? fileManager.contentsOfDirectory(atPath: path)) ?? []
    }

    func getDirectory() -> URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    func getFileExists(path: String, isDirectory: Bool) -> Bool {
        var isDirectory = ObjCBool(isDirectory)
        return fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
    }
}
