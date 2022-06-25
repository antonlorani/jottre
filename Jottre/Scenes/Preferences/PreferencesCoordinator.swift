import UIKit

final class PreferencesCoordinator: Coordinator {
    var release: CoordinatorReleaseClosure?

    private let navigationController: UINavigationController
    private let defaults: DefaultsProtocol
    private let deviceDataSource: DeviceDataSourceProtocol
    private let cloudDataSource: CloudDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    private let openURLProvider: (URL) -> Void

    init(
        navigationController: UINavigationController,
        defaults: DefaultsProtocol,
        deviceDataSource: DeviceDataSourceProtocol,
        cloudDataSource: CloudDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol,
        openURLProvider: @escaping (URL) -> Void
    ) {
        self.navigationController = navigationController
        self.defaults = defaults
        self.deviceDataSource = deviceDataSource
        self.cloudDataSource = cloudDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
        self.openURLProvider = openURLProvider
    }

    func start() {
        let preferencesNavigationController = PreferencesNavigationController()
        let preferencesViewController = PreferencesViewController(
            viewModel: PreferencesViewModel(
                repository: PreferencesRepository(
                    defaults: defaults,
                    environmentDataSource: EnvironmentDataSource(
                        defaults: defaults,
                        cloudDataSource: cloudDataSource,
                        deviceDataSource: deviceDataSource
                    ),
                    localizableStringsDataSource: localizableStringsDataSource
                ),
                coordinator: self,
                openURLProvider: openURLProvider
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
