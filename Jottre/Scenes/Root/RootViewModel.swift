import UIKit

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

    lazy var items = [
        Item.note(
            title: "Calculator Pro+ 540985 43850 34589 458",
            image: UIImage(systemName: "photo.fill.on.rectangle.fill")!,
            onSelect: {}
        ),
        Item.note(
            title: "Calculator Pro+",
            image: UIImage(systemName: "text.below.photo.fill")!,
            onSelect: {}
        ),
        Item.note(
            title: "Calculator Pro+ 540985 43850 34589 458",
            image: UIImage(systemName: "photo.fill.on.rectangle.fill")!,
            onSelect: {}
        ),
        Item.note(
            title: "Calculator Pro+",
            image: UIImage(systemName: "text.below.photo.fill")!,
            onSelect: {}
        ),
        Item.note(
            title: "Calculator Pro+ 540985 43850 34589 458",
            image: UIImage(systemName: "photo.fill.on.rectangle.fill")!,
            onSelect: {}
        ),
        Item.note(
            title: "Calculator Pro+",
            image: UIImage(systemName: "text.below.photo.fill")!,
            onSelect: {}
        )
    ]

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
        coordinator?.showAddNoteAlert(
            onSubmit: { [weak self] text in
                self?.coordinator?.openNote()
            }
        )
    }

    func openPreferencesButtonDidTap() {
        coordinator?.openPreferences()
    }
}
