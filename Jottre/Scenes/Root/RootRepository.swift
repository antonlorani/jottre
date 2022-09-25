import Combine
import Foundation

protocol RootRepositoryProtocol {

    func getInfoText() -> String
    func getLoadingTitle() -> String
    func getNavigationTitle() -> String
    func getAddNoteButtonTitle() -> String?
    func getFiles(preferredThumbnailSize: AnyPublisher<CGSize, Never>) -> AnyPublisher<[FileBusinessModel], Never>
    func getRemoteFilesText() -> AnyPublisher<String?, Never>
}

struct RootRepository: RootRepositoryProtocol {

    private let deviceDataSource: DeviceDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    private let infoTextRepository: InfoTextViewRepositoryProtocol
    private let fileRepository: FileRepository

    init(
        deviceDataSource: DeviceDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol,
        infoTextRepository: InfoTextViewRepositoryProtocol,
        fileRepository: FileRepository
    ) {
        self.deviceDataSource = deviceDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
        self.infoTextRepository = infoTextRepository
        self.fileRepository = fileRepository
    }

    func getInfoText() -> String {
        infoTextRepository.getText()
    }

    func getNavigationTitle() -> String {
        localizableStringsDataSource.getText(identifier: "Scene.Root.navigationTitle")
    }

    func getAddNoteButtonTitle() -> String? {
        guard deviceDataSource.getIsReadOnly() == false else {
            return nil
        }

        return localizableStringsDataSource.getText(identifier: "Scene.Root.BarButton.AddNote.title")
    }

    func getLoadingTitle() -> String {
        localizableStringsDataSource.getText(identifier: "Scene.Root.Loading.title")
    }

    func getFiles(preferredThumbnailSize: AnyPublisher<CGSize, Never>) -> AnyPublisher<[FileBusinessModel], Never> {
        fileRepository
            .getLocalFiles(
                preferredThumbnailSize: preferredThumbnailSize
            )
            .eraseToAnyPublisher()
    }

    func getRemoteFilesCount() -> AnyPublisher<Int, Never> {
        fileRepository
            .getRemoteFileCount()
            .eraseToAnyPublisher()
    }

    func getRemoteFilesText() -> AnyPublisher<String?, Never> {
        fileRepository
            .getRemoteFileCount()
            .map { count -> String? in
                guard count != .zero else {
                    return nil
                }
                return String(
                    format: localizableStringsDataSource.getText(identifier: "Scene.Root.BackgroundLoading.title"),
                    count
                )
            }
            .eraseToAnyPublisher()
    }
}
