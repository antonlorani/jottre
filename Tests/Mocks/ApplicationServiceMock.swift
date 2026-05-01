import Foundation

@testable import Jottre

@MainActor
final class ApplicationServiceMock: ApplicationServiceProtocol {

    private let supportsMultipleScenesProvider: @MainActor () -> Bool
    private let openProvider: @MainActor (_ url: URL) -> Void
    private let canOpenProvider: @MainActor (_ url: URL) -> Bool

    init(
        supportsMultipleScenesProvider: @MainActor @escaping () -> Bool = { false },
        openProvider: @MainActor @escaping (_ url: URL) -> Void = { _ in },
        canOpenProvider: @MainActor @escaping (_ url: URL) -> Bool = { _ in true }
    ) {
        self.supportsMultipleScenesProvider = supportsMultipleScenesProvider
        self.openProvider = openProvider
        self.canOpenProvider = canOpenProvider
    }

    func supportsMultipleScenes() -> Bool { supportsMultipleScenesProvider() }
    func open(url: URL) { openProvider(url) }
    func canOpen(url: URL) -> Bool { canOpenProvider(url) }
}
