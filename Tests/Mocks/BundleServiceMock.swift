@testable import Jottre

final class BundleServiceMock: BundleServiceProtocol {

    private let shortVersionStringProvider: @Sendable () -> String?

    init(shortVersionStringProvider: @Sendable @escaping () -> String? = { nil }) {
        self.shortVersionStringProvider = shortVersionStringProvider
    }

    func shortVersionString() -> String? { shortVersionStringProvider() }
}
