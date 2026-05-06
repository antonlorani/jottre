import Foundation
import XCTest

@testable import Jottre

final class JotFileServiceDocumentsDirectoryContentsTests: XCTestCase {

    private var localDocumentsDirectory: URL!
    private var ubiquitousDocumentsDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        localDocumentsDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        ubiquitousDocumentsDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: localDocumentsDirectory,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: ubiquitousDocumentsDirectory,
            withIntermediateDirectories: true
        )
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: localDocumentsDirectory)
        try? FileManager.default.removeItem(at: ubiquitousDocumentsDirectory)
        localDocumentsDirectory = nil
        ubiquitousDocumentsDirectory = nil
        try super.tearDownWithError()
    }

    func test_documentsDirectoryContents_givenLocalAndUbiquitousJotFiles_yieldsCombinedContents() async throws {
        // Given
        let localFileURL = localDocumentsDirectory.appendingPathComponent("local.jot")
        let ubiquitousFileURL = ubiquitousDocumentsDirectory.appendingPathComponent("cloud.jot")
        try Data().write(to: localFileURL)
        try Data().write(to: ubiquitousFileURL)

        let jotFileService = makeJotFileService()

        // When
        var iterator = jotFileService.documentsDirectoryContents().makeAsyncIterator()
        let infos = try await XCTUnwrapAsync(try await iterator.next())

        // Then
        let names = Set(infos.map(\.name))
        XCTAssertEqual(names, ["local", "cloud"])
        let cloudInfo = try XCTUnwrap(infos.first(where: { $0.name == "cloud" }))
        XCTAssertNotNil(cloudInfo.ubiquitousInfo)
        let localInfo = try XCTUnwrap(infos.first(where: { $0.name == "local" }))
        XCTAssertNil(localInfo.ubiquitousInfo)
    }

    func test_documentsDirectoryContents_givenNonJotFileInDirectory_filtersItOut() async throws {
        // Given
        let jotFileURL = localDocumentsDirectory.appendingPathComponent("real.jot")
        let textFileURL = localDocumentsDirectory.appendingPathComponent("ignored.txt")
        try Data().write(to: jotFileURL)
        try Data().write(to: textFileURL)

        let jotFileService = makeJotFileService(includeUbiquitous: false)

        // When
        var iterator = jotFileService.documentsDirectoryContents().makeAsyncIterator()
        let infos = try await XCTUnwrapAsync(try await iterator.next())

        // Then
        XCTAssertEqual(infos.map(\.name), ["real"])
    }

    func test_documentsDirectoryContents_givenLocalDirectoryUnavailable_yieldsOnlyUbiquitousContents() async throws {
        // Given
        let ubiquitousFileURL = ubiquitousDocumentsDirectory.appendingPathComponent("cloud.jot")
        try Data().write(to: ubiquitousFileURL)

        let localFileServiceMock = FileServiceMock(
            documentsDirectoryProvider: { nil },
            listContentsProvider: { _, _ in [] }
        )
        let ubiquitousFileServiceMock = FileServiceMock(
            documentsDirectoryProvider: { [ubiquitousDocumentsDirectory] in ubiquitousDocumentsDirectory },
            listContentsProvider: { directory, _ in
                try FileManager.default.contentsOfDirectory(
                    at: directory,
                    includingPropertiesForKeys: nil
                )
            },
            directoryChangesProvider: { _ in
                AsyncStream { continuation in
                    continuation.yield(())
                    continuation.finish()
                }
            }
        )
        let jotFileService = JotFileService(
            localFileService: localFileServiceMock,
            ubiquitousFileService: ubiquitousFileServiceMock
        )

        // When
        var iterator = jotFileService.documentsDirectoryContents().makeAsyncIterator()
        let infos = try await XCTUnwrapAsync(try await iterator.next())

        // Then
        XCTAssertEqual(infos.map(\.name), ["cloud"])
    }

    private func makeJotFileService(includeUbiquitous: Bool = true) -> JotFileService {
        let localFileServiceMock = FileServiceMock(
            documentsDirectoryProvider: { [localDocumentsDirectory] in localDocumentsDirectory },
            listContentsProvider: { directory, _ in
                try FileManager.default.contentsOfDirectory(
                    at: directory,
                    includingPropertiesForKeys: nil
                )
            },
            directoryChangesProvider: { _ in
                AsyncStream { continuation in
                    continuation.yield(())
                    continuation.finish()
                }
            }
        )
        let ubiquitousFileServiceMock: FileServiceMock
        if includeUbiquitous {
            ubiquitousFileServiceMock = FileServiceMock(
                documentsDirectoryProvider: { [ubiquitousDocumentsDirectory] in ubiquitousDocumentsDirectory },
                listContentsProvider: { directory, _ in
                    try FileManager.default.contentsOfDirectory(
                        at: directory,
                        includingPropertiesForKeys: nil
                    )
                },
                directoryChangesProvider: { _ in
                    AsyncStream { continuation in
                        continuation.yield(())
                        continuation.finish()
                    }
                }
            )
        } else {
            ubiquitousFileServiceMock = FileServiceMock(
                documentsDirectoryProvider: { nil },
                listContentsProvider: { _, _ in [] }
            )
        }
        return JotFileService(
            localFileService: localFileServiceMock,
            ubiquitousFileService: ubiquitousFileServiceMock
        )
    }
}

private func XCTUnwrapAsync<T>(
    _ expression: @autoclosure () async throws -> T?,
    file: StaticString = #filePath,
    line: UInt = #line
) async throws -> T {
    let value = try await expression()
    return try XCTUnwrap(value, file: file, line: line)
}
