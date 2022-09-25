import UIKit
import Combine

final class RootViewModel {

    struct Item {
        let title: String
        let image: UIImage
        let onSelect: () -> Void
    }

    enum Info {
        case largeText(text: String),
             loading(title: String)
    }

    lazy var remoteFilesCountText: AnyPublisher<String?, Never> = repository
        .getRemoteFilesText()
        .eraseToAnyPublisher()

    private lazy var infoText: AnyPublisher<String?, Never> = items
        .map(\.isEmpty)
        .prepend(false)
        .map { [weak self] shouldShowInfoText in
            guard let self = self, shouldShowInfoText else {
                return nil
            }
            return self.repository.getInfoText()
        }
        .share()
        .eraseToAnyPublisher()

    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(true)

    lazy var info = infoText
        .removeDuplicates()
        .combineLatest(
            isLoadingSubject
                .removeDuplicates()
                .eraseToAnyPublisher()
        )
        .map { [weak self] infoText, isLoading -> Info? in
            guard let self = self else {
                return nil
            }
            if isLoading {
                return Info.loading(title: self.repository.getLoadingTitle())
            }
            
            if let infoText = infoText {
                return Info.largeText(text: infoText)
            } else {
                return nil
            }
        }
        .eraseToAnyPublisher()

    lazy var items: AnyPublisher<[Item], Never> = repository
        .getFiles(preferredThumbnailSize: Just(CGSize(width: 200, height: 200)).eraseToAnyPublisher())
        .map { fileBusinessModels in
            fileBusinessModels
                .sorted(by: { lhs, rhs in
                    guard let modificationDateLhs = lhs.modificationDate, let modificationDateRhs = rhs.modificationDate else {
                        return false
                    }
                    return modificationDateLhs.compare(modificationDateRhs) == .orderedAscending
                })
                .map { fileBusinessModel in
                    Item(
                        title: fileBusinessModel.name,
                        image: fileBusinessModel.thumbnailImage,
                        onSelect: {}
                    )
                }
        }
        .handleEvents(receiveOutput: { [weak self] _ in
            self?.isLoadingSubject.send(false)
        })
        .share()
        .eraseToAnyPublisher()

    let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    private let repository: RootRepositoryProtocol
    private weak var coordinator: RootCoordinator?

    init(
        coordinator: RootCoordinator,
        repository: RootRepositoryProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    ) {
        self.coordinator = coordinator
        self.repository = repository
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func getNavigationTitle() -> String {
        repository.getNavigationTitle()
    }

    func getAddNoteButtonTitle() -> String? {
        repository.getAddNoteButtonTitle()
    }

    func addNoteButtonDidTap() {
        coordinator?.showAddNoteAlert()
    }

    func openPreferencesButtonDidTap() {
        coordinator?.openPreferences()
    }
}
