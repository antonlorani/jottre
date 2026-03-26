import Foundation

protocol JotFileServiceProtocol: Sendable {
    func listContents(directory: URL) throws -> [JotFile.Info]

    func readJotFile(info: JotFile.Info) throws -> JotFile

    func write(jotFile: JotFile) throws

    func getUnresolvedConflicts(info: JotFile.Info) -> [JotFileVersion]?

    func resolveConflicts(
        info: JotFile.Info,
        resolvedVersion: JotFileVersion?
    ) throws
}

struct JotFileService: JotFileServiceProtocol {

    private enum Constants {

        static let fileProperties: [URLResourceKey] = [
            .contentModificationDateKey,
            .isWritableKey,
            .isReadableKey,
            .isRegularFileKey,
        ]
    }

    private let propertyListDecoder = PropertyListDecoder()
    private let propertyListEncoder = PropertyListEncoder()

    private let fileService: FileServiceProtocol

    init(fileService: FileServiceProtocol) {
        self.fileService = fileService
    }

    func listContents(directory: URL) throws -> [JotFile.Info] {
        let contents = try fileService.listContents(
            directory: directory,
            properties: Constants.fileProperties
        )

        return
            try contents
            .map { content in
                try (
                    content: content,
                    properties: content.resourceValues(forKeys: Set(Constants.fileProperties))
                )
            }
            .filter { (fileURL: URL, properties: URLResourceValues) in
                properties.isRegularFile == true
                    && properties.isReadable == true
                    && properties.isWritable == true
                    && fileURL.pathExtension == "jot"
            }
            .map { (fileURL: URL, properties: URLResourceValues) in
                JotFile.Info(
                    url: fileURL,
                    name: fileURL.deletingPathExtension().lastPathComponent,
                    modificationDate: properties.contentModificationDate
                )
            }
    }

    func readJotFile(info: JotFile.Info) throws -> JotFile {
        let data = try fileService.readFile(fileURL: info.url)
        let jot = try propertyListDecoder.decode(Jot.self, from: data)
        return JotFile(
            info: info,
            jot: jot
        )
    }

    func write(jotFile: JotFile) throws {
        let data = try propertyListEncoder.encode(jotFile.jot)
        try fileService.writeFile(
            fileURL: jotFile.info.url,
            data: data
        )
    }

    func getUnresolvedConflicts(info: JotFile.Info) -> [JotFileVersion]? {
        guard let fileVersions = fileService.getUnresolvedConflicts(fileURL: info.url) else {
            return nil
        }
        return
            fileVersions
            .map { fileVersion in
                JotFileVersion(
                    info: JotFile.Info(
                        url: fileVersion.url,
                        name: fileVersion.localizedName ?? fileVersion.url.deletingPathExtension().lastPathComponent,
                        modificationDate: fileVersion.modificationDate
                    )
                )
            }
    }

    func resolveConflicts(
        info: JotFile.Info,
        resolvedVersion: JotFileVersion?
    ) throws {
        try fileService.resolveConflicts(
            fileURL: info.url,
            resolvedVersion: resolvedVersion?.info.url
        )
    }
}
