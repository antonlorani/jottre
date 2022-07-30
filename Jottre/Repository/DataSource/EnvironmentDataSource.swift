import UIKit

protocol EnvironmentDataSourceProtocol {
    
    func getCanUseCloud() -> Bool
    func getShouldUseCloud() -> Bool
    func getUserInterfaceStyle() -> UIUserInterfaceStyle
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
        getCanUseCloud() && defaults.get(UsingCloudEntry()) == true || getIsReadOnly()
    }

    func getUserInterfaceStyle() -> UIUserInterfaceStyle {
        guard let userInterfaceStyle = defaults.get(PreferredUserInterfaceStyleEntry(), UIUserInterfaceStyle.self) else {
            return .unspecified
        }
        return userInterfaceStyle
    }
}
