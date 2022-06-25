import Combine

protocol PreferencesRepositoryProtocol {

    func getNavigationTitle() -> String
    func getText(_ identifier: String) -> String
    func getUserInterfaceStyleAppearance() -> CustomUserInterfaceStyle
    func getUserInterfaceStyleAppearancePublisher() -> AnyPublisher<CustomUserInterfaceStyle, Never>
    func getCanUseCloud() -> Bool
    func getShouldUseCloud() -> Bool
    func getIsReadOnly() -> Bool
<<<<<<< HEAD
    func setUsingCloud(state: Bool)
=======
>>>>>>> 6c59f0adac973792d37c8acc5b1e5df3722d571d
    func setUserInterfaceStyleAppearance(newUserInterfaceStyle: CustomUserInterfaceStyle)
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

<<<<<<< HEAD
    func setUsingCloud(state: Bool) {
        defaults.usingCloud = state
    }

=======
>>>>>>> 6c59f0adac973792d37c8acc5b1e5df3722d571d
    func getUserInterfaceStyleAppearance() -> CustomUserInterfaceStyle {
        environmentDataSource.getUserInterfaceStyleAppearance()
    }

    func setUserInterfaceStyleAppearance(newUserInterfaceStyle: CustomUserInterfaceStyle) {
        defaults.customUserInterfaceStyle = newUserInterfaceStyle.rawValue
    }

    func getUserInterfaceStyleAppearancePublisher() -> AnyPublisher<CustomUserInterfaceStyle, Never> {
        defaults
            .publisher(\.customUserInterfaceStyle)
            .compactMap(CustomUserInterfaceStyle.init)
            .eraseToAnyPublisher()
    }
}
