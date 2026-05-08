@testable import Jottre

@MainActor
final class CoordinatorMock: Coordinator {

    var onEnd: (() -> Void)?

    private let startProvider: () -> Void

    init(
        startProvider: @escaping () -> Void = {}
    ) {
        self.startProvider = startProvider
    }

    func start() {
        startProvider()
    }
}
