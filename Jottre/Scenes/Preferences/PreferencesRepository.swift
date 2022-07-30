import UIKit
import Combine

protocol PreferencesRepositoryProtocol {

    func getNavigationTitle() -> String
    func getText(_ identifier: String) -> String
    func getUserInterfaceStyle() -> UIUserInterfaceStyle
    func getUserInterfaceStylePublisher() -> AnyPublisher<UIUserInterfaceStyle, Never>
    func getCanUseCloud() -> Bool
    func getShouldUseCloud() -> Bool
    func getIsReadOnly() -> Bool
    func setUsingCloud(state: Bool)
    func setUserInterfaceStyle(newUserInterfaceStyle: UIUserInterfaceStyle)
}

final class PreferencesRepository: PreferencesRepositoryProtocol {

    private let defaults: DefaultsProtocol
    private let environmentDataSource: EnvironmentDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    init(
        defaults: DefaultsProtocol,
        environmentDataSource: EnvironmentDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    ) {
        self.defaults = defaults
        self.environmentDataSource = environmentDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func getNavigationTitle() -> String {
        localizableStringsDataSource.getText(identifier: "Scene.Preferences.navigationTitle")
    }

    func getText(_ identifier: String) -> String {
        localizableStringsDataSource.getText(identifier: identifier)
    }

    func getIsReadOnly() -> Bool {
        environmentDataSource.getIsReadOnly()
    }

    func getCanUseCloud() -> Bool {
        environmentDataSource.getCanUseCloud()
    }

    func getShouldUseCloud() -> Bool {
        environmentDataSource.getShouldUseCloud()
    }

    func setUsingCloud(state: Bool) {
        defaults.set(UsingCloudEntry(), state)
    }

    func getUserInterfaceStyle() -> UIUserInterfaceStyle {
        environmentDataSource.getUserInterfaceStyle()
    }

    func setUserInterfaceStyle(newUserInterfaceStyle: UIUserInterfaceStyle) {
        defaults.set(PreferredUserInterfaceStyleEntry(), newUserInterfaceStyle.rawValue)
    }

    func getUserInterfaceStylePublisher() -> AnyPublisher<UIUserInterfaceStyle, Never> {
        defaults
            .publisher(PreferredUserInterfaceStyleEntry())
            .replaceNil(with: UIUserInterfaceStyle.unspecified.rawValue)
            .compactMap(UIUserInterfaceStyle.init)
            .eraseToAnyPublisher()
    }
}
