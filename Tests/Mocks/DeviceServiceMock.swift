@testable import Jottre

@MainActor
final class DeviceServiceMock: DeviceServiceProtocol {

    private let isIPadOSProvider: @MainActor () -> Bool

    init(isIPadOSProvider: @MainActor @escaping () -> Bool = { false }) {
        self.isIPadOSProvider = isIPadOSProvider
    }

    func isIPadOS() -> Bool { isIPadOSProvider() }
}
