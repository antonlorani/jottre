protocol EnvironmentDataSourceProtocol {
    
    func getCanUseCloud() -> Bool
    func getShouldUseCloud() -> Bool
    func getUserInterfaceStyleAppearance() -> CustomUserInterfaceStyle
    func getIsReadOnly() -> Bool
}

struct EnvironmentDataSource: EnvironmentDataSourceProtocol {
    private let defaults: DefaultsProtocol
    private let cloudDataSource: CloudDataSourceProtocol
    private let deviceDataSource: DeviceDataSourceProtocol

    init(defaults: DefaultsProtocol, cloudDataSource: CloudDataSourceProtocol, deviceDataSource: DeviceDataSourceProtocol) {
        self.defaults = defaults
        self.cloudDataSource = cloudDataSource
        self.deviceDataSource = deviceDataSource
    }

    func getIsReadOnly() -> Bool {
        deviceDataSource.getIsReadOnly()
    }

    func getCanUseCloud() -> Bool {
        cloudDataSource.getIsEnabled()
    }

    func getShouldUseCloud() -> Bool {
        getCanUseCloud() && defaults.usingCloud == true || getIsReadOnly()
    }

    func getUserInterfaceStyleAppearance() -> CustomUserInterfaceStyle {
        guard let userInterfaceStyle = defaults.get(\.customUserInterfaceStyle, CustomUserInterfaceStyle.self) else {
            return .system
        }
        return userInterfaceStyle
    }
}
