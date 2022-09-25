import Foundation
import Combine

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
