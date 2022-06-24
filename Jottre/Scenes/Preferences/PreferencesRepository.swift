protocol PreferencesRepositoryProtocol {

    func getNavigationTitle() -> String
    func getIsReadOnly() -> Bool
    func getIsCloudEnabled() -> Bool
}

final class PreferencesRepository: PreferencesRepositoryProtocol {

    private let deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol
    private let cloudDataSource: CloudDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    init(
        deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol,
        cloudDataSource: CloudDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    ) {
        self.deviceEnvironmentDataSource = deviceEnvironmentDataSource
        self.cloudDataSource = cloudDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func getNavigationTitle() -> String {
        localizableStringsDataSource.getText(identifier: "Scene.Preferences.navigationTitle")
    }

    func getIsReadOnly() -> Bool {
        deviceEnvironmentDataSource.getIsReadOnly()
    }

    func getIsCloudEnabled() -> Bool {
        cloudDataSource.getIsEnabled()
    }
}
