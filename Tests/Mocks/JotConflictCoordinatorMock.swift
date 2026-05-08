@testable import Jottre

@MainActor
final class JotConflictCoordinatorMock: JotConflictCoordinatorProtocol {

    var onEnd: (() -> Void)?

    private let startProvider: () -> Void
    private let showInfoAlertProvider: (_ title: String, _ message: String) -> Void
    private let dismissProvider: (_ completion: @Sendable () -> Void) -> Void

    init(
        startProvider: @escaping () -> Void = {},
        showInfoAlertProvider: @escaping (_ title: String, _ message: String) -> Void = { _, _ in },
        dismissProvider: @escaping (_ completion: @Sendable () -> Void) -> Void = { _ in }
    ) {
        self.startProvider = startProvider
        self.showInfoAlertProvider = showInfoAlertProvider
        self.dismissProvider = dismissProvider
    }

    func start() {
        startProvider()
    }

    func showInfoAlert(title: String, message: String) {
        showInfoAlertProvider(title, message)
    }

    func dismiss(completion: @Sendable @escaping () -> Void) {
        dismissProvider(completion)
    }
}
