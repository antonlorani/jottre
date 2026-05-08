import Foundation

@testable import Jottre

@MainActor
final class SettingsCoordinatorMock: SettingsCoordinatorProtocol {

    var onEnd: (() -> Void)?

    private let startProvider: () -> Void
    private let openExternalLinkProvider: (_ url: URL) -> Void
    private let dismissProvider: () -> Void

    init(
        startProvider: @escaping () -> Void = {},
        openExternalLinkProvider: @escaping (_ url: URL) -> Void = { _ in },
        dismissProvider: @escaping () -> Void = {}
    ) {
        self.startProvider = startProvider
        self.openExternalLinkProvider = openExternalLinkProvider
        self.dismissProvider = dismissProvider
    }

    func start() {
        startProvider()
    }

    func openExternalLink(url: URL) {
        openExternalLinkProvider(url)
    }

    func dismiss() {
        dismissProvider()
    }
}
