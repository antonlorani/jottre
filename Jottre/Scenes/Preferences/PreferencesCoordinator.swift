import UIKit

final class PreferencesCoordinator: Coordinator {
    var release: CoordinatorReleaseClosure?

    private let navigationController: UINavigationController
    private let deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol
    private let cloudDataSource: CloudDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    init(
        navigationController: UINavigationController,
        deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol,
        cloudDataSource: CloudDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    ) {
        self.navigationController = navigationController
        self.deviceEnvironmentDataSource = deviceEnvironmentDataSource
        self.cloudDataSource = cloudDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func start() {
        let preferencesNavigationController = PreferencesNavigationController()
        let preferencesViewController = PreferencesViewController(
            viewModel: PreferencesViewModel(
                repository: PreferencesRepository(
                    deviceEnvironmentDataSource: deviceEnvironmentDataSource,
                    cloudDataSource: cloudDataSource,
                    localizableStringsDataSource: localizableStringsDataSource
                ),
                coordinator: self
            )
        )
        preferencesNavigationController.modalPresentationStyle = .formSheet
        preferencesNavigationController.setViewControllers([preferencesViewController], animated: false)
        navigationController.present(preferencesNavigationController, animated: true)
    }

    func dismiss() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.release?()
        }
    }
}
