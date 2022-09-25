import Foundation
import Combine

/*
 What do we want to achive?
 - Synchronizing files-updates between the local- and remote-filesystem and the apps-frontend

 How will it be implemented?
 - Given directory
 - Timer to emit event every 0.5? seconds
 - List files inside this directory (Only files that contain a .jot extension)
 - Check if file is a remote file
    -> Yes: Use `remote-file-publisher`
    -> No: Use `local-file-publisher`

 ## `local-file-publisher` stack
 - PassthroughSubject that takes a single file-url as input
 - 'removeDuplicates' before added to array
 - Reads contents of file to produce image -> Removes unused data afterwards
 - Sends FileBusinessModel object to array (can be accessed from the outside) -> With debounce to limit number of publishing updates

 ## `remote-file-publisher` stack
 - PassthroughSubject that takes a single file-url as input
 - Subscription inside remote-file-stack start download of respective file
 - Array in which hashes of file-urls reside in that are currently downloaded -> Once download ended, remove corresponding element from array -> (Accessible from the outside)
 */

struct File: Equatable {
    let name: String
    let url: URL
    let modificationDate: Date?
}

final class FileSystem {

    static var shared: FileSystem = {
        let localFileDataSource = LocalFileDataSource(fileManager: .default)
        return FileSystem(
            defaults: Defaults.shared,
            localFileDataSource: localFileDataSource,
            remoteFileDataSource: RemoteFileDataSource(
                fileManager: .default,
                localFileDataSource: localFileDataSource
            )
        )
    }()

    private var storedTimerPublisher: AnyPublisher<Void, Never>?

    private let queue = DispatchQueue(label: "com.jottre.filesystem")

    private lazy var allFiles: AnyPublisher<[File], Never> = Timer.publish(every: 1, on: .main, in: .default)
        .autoconnect()
        .receive(on: queue)
        .combineLatest(
            defaults.publisher(UsingCloudEntry())
                .replaceNil(with: false)
                .compactMap { [weak self] isUsingCloud in
                    isUsingCloud ? self?.remoteFileDataSource.getDirectory() : self?.localFileDataSource.getDirectory()
                }
                .eraseToAnyPublisher()
        )
        .map { [weak self] _, directory -> [File] in
            guard let self = self else {
                return []
            }
            return self.localFileDataSource.getFiles(path:  directory.path)
                .filter { $0.contains(".jot") }
                .map { fileName in
                    let url = directory.appendingPathComponent(fileName)
                    let modificationDate = self.localFileDataSource.getModifiedDate(url: url)

                    return File(
                        name: fileName,
                        url: url,
                        modificationDate: modificationDate
                    )
                }
        }
        .share()
        .eraseToAnyPublisher()

    lazy var localFiles: AnyPublisher<[File], Never> = allFiles
        .map { [weak self] allFiles in
            guard let self = self else {
                return []
            }
            return allFiles.filter { self.remoteFileDataSource.isRemoteFile(url: $0.url) == false }
        }
        .removeDuplicates()
        .share()
        .eraseToAnyPublisher()

    lazy var remoteFiles: AnyPublisher<[File], Never> = allFiles
        .map { [weak self] allFiles -> [File] in
            guard let self = self else {
                return []
            }
            return allFiles.filter { self.remoteFileDataSource.isRemoteFile(url: $0.url) }
        }
        .map { [weak self] remoteFiles in
            guard let self = self else {
                return []
            }
            remoteFiles.forEach { self.remoteFileDataSource.downloadFile(url: $0.url) }
            return remoteFiles
        }
        .removeDuplicates()
        .share()
        .eraseToAnyPublisher()

    private let defaults: DefaultsProtocol
    private let localFileDataSource: LocalFileDataSource
    private let remoteFileDataSource: RemoteFileDataSource

    init(
        defaults: DefaultsProtocol,
        localFileDataSource: LocalFileDataSource,
        remoteFileDataSource: RemoteFileDataSource
    ) {
        self.defaults = defaults
        self.localFileDataSource = localFileDataSource
        self.remoteFileDataSource = remoteFileDataSource
    }
}
