import UIKit
import Combine

final class RootViewModel {

    enum Item {
        case note(title: String, image: UIImage, onSelect: () -> Void)

        var onSelect: () -> Void {
            switch self {
            case let .note(_, _, onSelect):
                return onSelect
            }
        }
    }

    lazy var infoTextString: AnyPublisher<String?, Never> = items
        .map(\.isEmpty)
        .prepend(true)
        .map { [weak self] shouldShowInfoText in
            guard let self = self, shouldShowInfoText else {
                return nil
            }
            return self.repository.getInfoText()
        }
        .share()
        .eraseToAnyPublisher()

    lazy var isInfoTextViewHidden: AnyPublisher<Bool, Never> = infoTextString
        .map { $0 == nil }
        .eraseToAnyPublisher()

    lazy var items: AnyPublisher<[Item], Never> = Just(
        [
            Item.note(
                title: "Calculator Pro+ 540985 43850 34589 458",
                image: UIImage(systemName: "photo.fill.on.rectangle.fill")!,
                onSelect: {}
            ),
            .note(
                title: "Calculator Pro+",
                image: UIImage(systemName: "text.below.photo.fill")!,
                onSelect: {}
            ),
            .note(
                title: "Calculator Pro+ 540985 43850 34589 458",
                image: UIImage(systemName: "photo.fill.on.rectangle.fill")!,
                onSelect: {}
            ),
            .note(
                title: "Calculator Pro+",
                image: UIImage(systemName: "text.below.photo.fill")!,
                onSelect: {}
            ),
            .note(
                title: "Calculator Pro+ 540985 43850 34589 458",
                image: UIImage(systemName: "photo.fill.on.rectangle.fill")!,
                onSelect: {}
            ),
            .note(
                title: "Calculator Pro+",
                image: UIImage(systemName: "text.below.photo.fill")!,
                onSelect: {}
            )
        ]
    )
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
