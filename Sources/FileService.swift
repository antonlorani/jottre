import Foundation

protocol FileServiceProtocol: Sendable {

    func localDocumentsDirectory() throws -> URL?

    func cloudDocumentsDirectory() throws -> URL?

    func listContents(
        directory: URL,
        properties: [URLResourceKey]
    ) throws -> [URL]

    func directoryChanges(directory: URL) -> AsyncStream<Void>

    func readFile(fileURL: URL) throws -> Data

    func writeFile(fileURL: URL, data: Data) throws

    func getUnresolvedConflicts(fileURL: URL) -> [NSFileVersion]?

    func resolveConflicts(
        fileURL: URL,
        resolvedVersion: URL?
    ) throws
}

struct FileService: FileServiceProtocol {

    nonisolated(unsafe) private let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    func localDocumentsDirectory() throws -> URL? {
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        var isDirectory = ObjCBool(true)
        if !fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    func cloudDocumentsDirectory() throws -> URL? {
        guard let directory = fileManager.url(forUbiquityContainerIdentifier: nil) else {
            return nil
        }

        var isDirectory = ObjCBool(true)
        if !fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    func listContents(
        directory: URL,
        properties: [URLResourceKey]
    ) throws -> [URL] {
        try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: properties
        )
    }

    func directoryChanges(directory: URL) -> AsyncStream<Void> {
        AsyncStream { continuation in
            continuation.yield()

            let fd = open(directory.path, O_EVTONLY)
            guard fd >= 0 else {
                continuation.finish()
                return
            }

            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fd,
                eventMask: [.write, .rename, .delete, .extend],
                queue: .global()
            )

            source.setEventHandler {
                continuation.yield()
            }

            source.setCancelHandler {
                close(fd)
            }

            continuation.onTermination = { _ in
                source.cancel()
            }

            source.resume()
        }
    }

    func readFile(fileURL: URL) throws -> Data {
        try Data(contentsOf: fileURL)
    }

    func writeFile(fileURL: URL, data: Data) throws {
        try data.write(to: fileURL, options: .atomic)
    }

    func getUnresolvedConflicts(fileURL: URL) -> [NSFileVersion]? {
        NSFileVersion.unresolvedConflictVersionsOfItem(at: fileURL)
    }

    func resolveConflicts(
        fileURL: URL,
        resolvedVersion: URL?
    ) throws {
        guard let unresolvedConflicts = getUnresolvedConflicts(fileURL: fileURL) else {
            return
        }

        if let resolvedVersion {
            _ = try fileManager.replaceItemAt(
                fileURL,
                withItemAt: resolvedVersion
            )
        }

        for conflictingVersion in unresolvedConflicts {
            conflictingVersion.isResolved = true
        }

        try NSFileVersion.removeOtherVersionsOfItem(at: fileURL)
    }
}
