import Foundation
import Combine
import UIKit
import PencilKit

struct FileBusinessModel {
    let name: String
    let url: URL
    let modificationDate: Date?
    let thumbnailImage: UIImage

    init(file: File, thumbnailImage: UIImage) {
        name = file.name
        url = file.url
        modificationDate = file.modificationDate
        self.thumbnailImage = thumbnailImage
    }
}

final class FileRepository {

    private let queue = DispatchQueue(label: "com.jottre.thumbnail")

    private let defaults: DefaultsProtocol
    private let localFileDataSource: LocalFileDataSource
    private let fileSystem: FileSystem

    init(
        defaults: DefaultsProtocol,
        localFileDataSource: LocalFileDataSource,
        fileSystem: FileSystem
    ) {
        self.defaults = defaults
        self.localFileDataSource = localFileDataSource
        self.fileSystem = fileSystem
    }

    func getLocalFiles(
        preferredThumbnailSize: AnyPublisher<CGSize, Never>
    ) -> AnyPublisher<[FileBusinessModel], Never> {
        fileSystem
            .localFiles
            .combineLatest(
                defaults.publisher(PreferredUserInterfaceStyleEntry())
                    .removeDuplicates()
                    .replaceNil(with: UIUserInterfaceStyle.unspecified.rawValue)
                    .compactMap(UIUserInterfaceStyle.init)
                    .eraseToAnyPublisher(),
                preferredThumbnailSize
                    .removeDuplicates()
                    .eraseToAnyPublisher()
            )
            .receive(on: queue)
            .map { [weak self] localFiles, userInterfaceStyle, preferredThumbnailSize in
                guard let self = self else {
                    return []
                }
                return localFiles
                    .compactMap { file -> FileBusinessModel? in
                        self.localFileDataSource.getFileData(url: file.url)
                            .map { data in
                                try? PropertyListDecoder().decode(Note.self, from: data)
                            }
                            .map { note -> UIImage in
                                note
                                    .map { note in
                                        self.makeThumbnailImage(
                                            drawing: note.drawing,
                                            preferredThumbnailSize: preferredThumbnailSize,
                                            userInterfaceStyle: userInterfaceStyle
                                        )
                                    } ?? UIImage()
                            }
                            .map { thumbnailImage in
                                FileBusinessModel(
                                    file: file,
                                    thumbnailImage: thumbnailImage
                                )
                            }
                    }
            }
            .eraseToAnyPublisher()
    }

    func getRemoteFileCount() -> AnyPublisher<Int, Never> {
        fileSystem
            .remoteFiles
            .map { $0.count }
            .eraseToAnyPublisher()
    }

    private func makeThumbnailImage(
        drawing: PKDrawing,
        preferredThumbnailSize: CGSize,
        userInterfaceStyle: UIUserInterfaceStyle
    ) -> UIImage {

        let aspectRatio = preferredThumbnailSize.width / preferredThumbnailSize.height
        let rect = CGRect(origin: .zero, size: CGSize(width: 1200, height: 1200 / aspectRatio))
        let scale = UIScreen.main.scale * preferredThumbnailSize.width / 1200

        var image: UIImage?
        UITraitCollection(userInterfaceStyle: userInterfaceStyle).performAsCurrent {
            image = drawing.image(from: rect, scale: scale)
        }
        return image ?? UIImage()
    }
}
