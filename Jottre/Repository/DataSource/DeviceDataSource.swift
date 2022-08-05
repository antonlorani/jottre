import class UIKit.UIDevice

protocol DeviceDataSourceProtocol {

    func getIsReadOnly() -> Bool
}

final class DeviceDataSource: DeviceDataSourceProtocol {

    static let shared = DeviceDataSource(device: .current)

    private let device: UIDevice

    init(device: UIDevice) {
        self.device = device
    }

    func getIsReadOnly() -> Bool {
        #if targetEnvironment(macCatalyst)
            return true
        #else
            return (device.userInterfaceIdiom == .pad) == false
        #endif
    }
}
