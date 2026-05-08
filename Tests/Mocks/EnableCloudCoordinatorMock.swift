@testable import Jottre

@MainActor
final class EnableCloudCoordinatorMock: EnableCloudCoordinatorProtocol {

    var onEnd: (() -> Void)?

    private let startProvider: () -> Void
    private let openLearnHowToEnableProvider: () -> Void
    private let dismissProvider: () -> Void

    init(
        startProvider: @escaping () -> Void = {},
        openLearnHowToEnableProvider: @escaping () -> Void = {},
        dismissProvider: @escaping () -> Void = {}
    ) {
        self.startProvider = startProvider
        self.openLearnHowToEnableProvider = openLearnHowToEnableProvider
        self.dismissProvider = dismissProvider
    }

    func start() {
        startProvider()
    }

    func openLearnHowToEnable() {
        openLearnHowToEnableProvider()
    }

    func dismiss() {
        dismissProvider()
    }
}
