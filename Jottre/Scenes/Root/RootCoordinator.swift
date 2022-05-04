import UIKit

final class RootCoordinator: Coordinator {

    var release: CoordinatorReleaseClosure?

    private var retainedPreferencesCoordinator: PreferencesCoordinator?

    private let deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol
    private let cloudDataSource: CloudDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    private let repository: RootCoordinatorRepositoryProtocol
    private let navigationController: UINavigationController

    init(
        navigationController: UINavigationController,
        repository: RootCoordinatorRepositoryProtocol,
        deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol,
        cloudDataSource: CloudDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    ) {
        self.navigationController = navigationController
        self.repository = repository
        self.deviceEnvironmentDataSource = deviceEnvironmentDataSource
        self.cloudDataSource = cloudDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func start() {
        let rootViewController = RootViewController(
            viewModel: RootViewModel(
                coordinator: self,
                repository: RootRepository(
                    deviceEnvironmentDataSource: deviceEnvironmentDataSource,
                    localizableStringsDataSource: localizableStringsDataSource
                ),
                deviceEnvironmentDataSource: deviceEnvironmentDataSource,
                cloudDataSource: cloudDataSource,
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
        let preferencesCoordinator = PreferencesCoordinator(navigationController: navigationController)
        retainedPreferencesCoordinator = preferencesCoordinator
        preferencesCoordinator.start()
        preferencesCoordinator.release = { [weak self] in
            self?.retainedPreferencesCoordinator = nil
        }
    }
}
