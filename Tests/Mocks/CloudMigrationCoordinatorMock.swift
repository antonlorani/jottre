@testable import Jottre

@MainActor
final class CloudMigrationCoordinatorMock: CloudMigrationCoordinatorProtocol {

    var onEnd: (() -> Void)?

    private let shouldStartProvider: () -> Bool
    private let startProvider: () -> Void
    private let showInfoAlertProvider: (_ title: String, _ message: String) -> Void
    private let dismissProvider: () -> Void

    init(
        shouldStartProvider: @escaping () -> Bool = { false },
        startProvider: @escaping () -> Void = {},
        showInfoAlertProvider: @escaping (_ title: String, _ message: String) -> Void = { _, _ in },
        dismissProvider: @escaping () -> Void = {}
    ) {
        self.shouldStartProvider = shouldStartProvider
        self.startProvider = startProvider
        self.showInfoAlertProvider = showInfoAlertProvider
        self.dismissProvider = dismissProvider
    }

    func shouldStart() -> Bool {
        shouldStartProvider()
    }

    func start() {
        startProvider()
    }

    func showInfoAlert(title: String, message: String) {
        showInfoAlertProvider(title, message)
    }

    func dismiss() {
        dismissProvider()
    }
}
