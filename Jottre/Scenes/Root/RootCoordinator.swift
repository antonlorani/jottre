import UIKit

final class RootCoordinator: Coordinator {

    var release: CoordinatorReleaseClosure?

    private var retainedPreferencesCoordinator: PreferencesCoordinator?
    private var retainedNoteCoordinator: NoteCoordinator?

    private let navigationController: UINavigationController
    private let defaults: DefaultsProtocol
    private let repository: RootCoordinatorRepositoryProtocol
    private let deviceDataSource: DeviceDataSourceProtocol
    private let cloudDataSource: CloudDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    private let openURLProvider: (URL) -> Void

    init(
        navigationController: UINavigationController,
        defaults: DefaultsProtocol,
        repository: RootCoordinatorRepositoryProtocol,
        deviceDataSource: DeviceDataSourceProtocol,
        cloudDataSource: CloudDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol,
        openURLProvider: @escaping (URL) -> Void
    ) {
        self.navigationController = navigationController
        self.defaults = defaults
        self.repository = repository
        self.deviceDataSource = deviceDataSource
        self.cloudDataSource = cloudDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
        self.openURLProvider = openURLProvider
    }

    func start() {
        let rootViewController = RootViewController(
            viewModel: RootViewModel(
                coordinator: self,
                repository: RootRepository(
                    deviceDataSource: deviceDataSource,
                    localizableStringsDataSource: localizableStringsDataSource,
                    infoTextRepository: InfoTextViewRepository(
                        environmentDataSource: EnvironmentDataSource(
                            defaults: defaults,
                            cloudDataSource: cloudDataSource,
                            deviceDataSource: deviceDataSource
                        ),
                        localizableStringsDataSource: localizableStringsDataSource
                    )
                ),
                localizableStringsDataSource: localizableStringsDataSource
            )
        )
        navigationController.pushViewController(rootViewController, animated: false)
    }

    func showAddNoteAlert(onSubmit: @escaping (String) -> Void) {
        let alertController = UIAlertController.makeAddNoteAlert(
            content: repository.getAddNoteAlert(),
            onSubmit: onSubmit
        )
        navigationController.present(alertController, animated: true, completion: nil)
    }

    func openPreferences() {
        let preferencesCoordinator = PreferencesCoordinator(
            navigationController: navigationController,
            defaults: defaults,
            deviceDataSource: deviceDataSource,
            cloudDataSource: cloudDataSource,
            localizableStringsDataSource: localizableStringsDataSource,
            openURLProvider: openURLProvider
        )
        retainedPreferencesCoordinator = preferencesCoordinator
        preferencesCoordinator.start()
        preferencesCoordinator.release = { [weak self] in
            self?.retainedPreferencesCoordinator = nil
        }
    }

    func openNote() {
        let noteCoordinator = NoteCoordinator(navigationController: navigationController)
        retainedNoteCoordinator = noteCoordinator
        noteCoordinator.start()
        noteCoordinator.release = { [weak self] in
            self?.retainedNoteCoordinator = nil
        }
    }
}
