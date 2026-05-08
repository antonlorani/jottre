import UIKit

@testable import Jottre

final class SettingsRepositoryMock: SettingsRepositoryProtocol {

    private let shouldShowEnableICloudButtonProvider: @Sendable () -> Bool
    private let appVersionProvider: @Sendable () -> String
    private let userInterfaceStyleProvider: @Sendable () -> AsyncStream<UIUserInterfaceStyle>
    private let updateUserInterfaceStyleProvider: @Sendable (_ style: UIUserInterfaceStyle) -> Void

    init(
        shouldShowEnableICloudButtonProvider: @Sendable @escaping () -> Bool = { false },
        appVersionProvider: @Sendable @escaping () -> String = { "" },
        userInterfaceStyleProvider: @Sendable @escaping () -> AsyncStream<UIUserInterfaceStyle> = {
            AsyncStream { $0.finish() }
        },
        updateUserInterfaceStyleProvider: @Sendable @escaping (_ style: UIUserInterfaceStyle) -> Void = { _ in }
    ) {
        self.shouldShowEnableICloudButtonProvider = shouldShowEnableICloudButtonProvider
        self.appVersionProvider = appVersionProvider
        self.userInterfaceStyleProvider = userInterfaceStyleProvider
        self.updateUserInterfaceStyleProvider = updateUserInterfaceStyleProvider
    }

    func shouldShowEnableICloudButton() -> Bool {
        shouldShowEnableICloudButtonProvider()
    }

    func appVersion() -> String {
        appVersionProvider()
    }

    func userInterfaceStyle() -> AsyncStream<UIUserInterfaceStyle> {
        userInterfaceStyleProvider()
    }

    func updateUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        updateUserInterfaceStyleProvider(style)
    }
}
