import class UIKit.UIDevice

protocol DeviceEnvironmentDataSourceProtocol {

    func getIsReadOnly() -> Bool
}

final class DeviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol {

    private let device: UIDevice

    init(device: UIDevice) {
        self.device = device
    }

    func getIsReadOnly() -> Bool {
        return false
        #if targetEnvironment(macCatalyst)
            return true
        #else
            return (device.userInterfaceIdiom == .pad) == false
        #endif
    }
}
