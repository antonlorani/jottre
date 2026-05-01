@testable import Jottre

final class JotFileConflictServiceMock: JotFileConflictServiceProtocol {

    private let getConfictingVersionsProvider: @Sendable (_ jotFileInfo: JotFile.Info) -> [JotFileVersion]?
    private let resolveVersionConflictsProvider:
        @Sendable (_ jotFileInfo: JotFile.Info, _ resolvedVersions: [JotFileVersion]) throws -> Void
    private let copyVersionToTemporaryProvider:
        @Sendable (_ jotFileInfo: JotFile.Info, _ jotFileVersion: JotFileVersion) throws -> JotFile.Info?

    init(
        getConfictingVersionsProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) -> [JotFileVersion]? = { _ in
            nil
        },
        resolveVersionConflictsProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ resolvedVersions: [JotFileVersion]) throws -> Void = {
                _,
                _ in
            },
        copyVersionToTemporaryProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ jotFileVersion: JotFileVersion) throws -> JotFile.Info? =
            { _, _ in nil }
    ) {
        self.getConfictingVersionsProvider = getConfictingVersionsProvider
        self.resolveVersionConflictsProvider = resolveVersionConflictsProvider
        self.copyVersionToTemporaryProvider = copyVersionToTemporaryProvider
    }

    func getConfictingVersions(jotFileInfo: JotFile.Info) -> [JotFileVersion]? {
        getConfictingVersionsProvider(jotFileInfo)
    }
    func resolveVersionConflicts(jotFileInfo: JotFile.Info, resolvedVersions: [JotFileVersion]) throws {
        try resolveVersionConflictsProvider(jotFileInfo, resolvedVersions)
    }
    func copyVersionToTemporary(jotFileInfo: JotFile.Info, jotFileVersion: JotFileVersion) throws -> JotFile.Info? {
        try copyVersionToTemporaryProvider(jotFileInfo, jotFileVersion)
    }
}
