import Foundation

@testable import Jottre

final class FileConflictServiceMock: FileConflictServiceProtocol {

    private let getConflictingVersionsProvider: @Sendable (_ fileURL: URL) -> [NSFileVersion]?
    private let resolveVersionConflictsProvider: @Sendable (_ fileURL: URL, _ resolvedVersions: [URL]) throws -> Void
    private let copyVersionToTemporaryProvider: @Sendable (_ fileURL: URL, _ versionURL: URL) throws -> URL?

    init(
        getConflictingVersionsProvider: @Sendable @escaping (_ fileURL: URL) -> [NSFileVersion]? = { _ in nil },
        resolveVersionConflictsProvider:
            @Sendable @escaping (_ fileURL: URL, _ resolvedVersions: [URL]) throws -> Void = { _, _ in },
        copyVersionToTemporaryProvider:
            @Sendable @escaping (_ fileURL: URL, _ versionURL: URL) throws -> URL? = { _, _ in nil }
    ) {
        self.getConflictingVersionsProvider = getConflictingVersionsProvider
        self.resolveVersionConflictsProvider = resolveVersionConflictsProvider
        self.copyVersionToTemporaryProvider = copyVersionToTemporaryProvider
    }

    func getConflictingVersions(fileURL: URL) -> [NSFileVersion]? {
        getConflictingVersionsProvider(fileURL)
    }

    func resolveVersionConflicts(fileURL: URL, resolvedVersions: [URL]) throws {
        try resolveVersionConflictsProvider(fileURL, resolvedVersions)
    }

    func copyVersionToTemporary(fileURL: URL, versionURL: URL) throws -> URL? {
        try copyVersionToTemporaryProvider(fileURL, versionURL)
    }
}
