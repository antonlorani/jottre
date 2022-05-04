final class RootViewModel {

    let deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol
    let cloudDataSource: CloudDataSourceProtocol
    let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    private let repository: RootRepositoryProtocol
    private weak var coordinator: RootCoordinator?

    init(
        coordinator: RootCoordinator,
        repository: RootRepositoryProtocol,
        deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol,
        cloudDataSource: CloudDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    ) {
        self.coordinator = coordinator
        self.repository = repository
        self.deviceEnvironmentDataSource = deviceEnvironmentDataSource
        self.cloudDataSource = cloudDataSource
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
                print(text)
            }
        )
    }

    func openPreferencesButtonDidTap() {
        coordinator?.openPreferences()
    }
}
