final class RootViewModel {

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
