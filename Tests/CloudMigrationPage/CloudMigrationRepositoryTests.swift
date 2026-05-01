import XCTest

@testable import Jottre

final class CloudMigrationRepositoryTests: XCTestCase {

    private static let localInfo = JotFile.Info(
        url: URL(staticString: "file:///tmp/local.jot"),
        name: "local",
        modificationDate: Date(timeIntervalSince1970: 1_000),
        ubiquitousInfo: nil
    )
    private static let ubiquitousNewer = JotFile.Info(
        url: URL(staticString: "file:///cloud/newer.jot"),
        name: "newer",
        modificationDate: Date(timeIntervalSince1970: 3_000),
        ubiquitousInfo: UbiquitousInfo(downloadStatus: .current, isDownloading: false)
    )
    private static let ubiquitousOlder = JotFile.Info(
        url: URL(staticString: "file:///cloud/older.jot"),
        name: "older",
        modificationDate: Date(timeIntervalSince1970: 2_000),
        ubiquitousInfo: UbiquitousInfo(downloadStatus: .current, isDownloading: false)
    )

    func test_getJotFiles_yieldsLocalsBeforeUbiquitousAndUbiquitousSortedNewestFirst() async throws {
        // Given
        let jotFileServiceMock = JotFileServiceMock(
            documentsDirectoryContentsProvider: {
                AsyncThrowingStream { continuation in
                    continuation.yield([Self.ubiquitousNewer, Self.localInfo, Self.ubiquitousOlder])
                    continuation.finish()
                }
            }
        )
        let repository = CloudMigrationRepository(
            ubiquitousFileService: FileServiceMock(),
            jotFileService: jotFileServiceMock,
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(),
            defaultsService: DefaultsServiceMock()
        )

        // When
        var iterator = repository.getJotFiles().makeAsyncIterator()
        let first = try await XCTUnwrapAsync(try await iterator.next())

        // Then
        XCTAssertEqual(first.map(\.name), ["local", "newer", "older"])
    }

    func test_moveJotFile_forwardsToJotFileService() async throws {
        // Given
        let moveProviderExpectation = XCTestExpectation(description: "moveProvider is called.")
        let jotFileServiceMock = JotFileServiceMock(
            moveProvider: { receivedInfo, receivedShouldBecomeUbiquitous in
                // Then
                XCTAssertEqual(receivedInfo, Self.localInfo)
                XCTAssertTrue(receivedShouldBecomeUbiquitous)
                moveProviderExpectation.fulfill()
            }
        )
        let repository = CloudMigrationRepository(
            ubiquitousFileService: FileServiceMock(),
            jotFileService: jotFileServiceMock,
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(),
            defaultsService: DefaultsServiceMock()
        )

        // When
        try await repository.moveJotFile(jotFileInfo: Self.localInfo, shouldBecomeUbiquitous: true)

        // Then
        await fulfillment(of: [moveProviderExpectation], timeout: 0.2)
    }

    func test_getShouldShowCloudMigration_givenAlreadyDone_returnsFalse() {
        // Given
        let defaultsServiceMock = DefaultsServiceMock(
            initialValues: [DefaultsKey<Bool>.hasDoneCloudMigration.description: true]
        )
        let repository = CloudMigrationRepository(
            ubiquitousFileService: FileServiceMock(isEnabledProvider: { false }),
            jotFileService: JotFileServiceMock(),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(),
            defaultsService: defaultsServiceMock
        )

        // Then
        XCTAssertFalse(repository.getShouldShowCloudMigration())
    }

    func test_getShouldShowCloudMigration_givenStoredFlagDiffersFromCurrentUbiquitousState_returnsTrue() {
        // Given
        let defaultsServiceMock = DefaultsServiceMock(
            initialValues: [DefaultsKey<Bool>.isICloudEnabled.description: false]
        )
        let repository = CloudMigrationRepository(
            ubiquitousFileService: FileServiceMock(isEnabledProvider: { true }),
            jotFileService: JotFileServiceMock(),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(),
            defaultsService: defaultsServiceMock
        )

        // Then
        XCTAssertTrue(repository.getShouldShowCloudMigration())
    }

    func test_getShouldShowCloudMigration_givenStoredFlagMatchesCurrentUbiquitousState_returnsFalse() {
        // Given
        let defaultsServiceMock = DefaultsServiceMock(
            initialValues: [DefaultsKey<Bool>.isICloudEnabled.description: true]
        )
        let repository = CloudMigrationRepository(
            ubiquitousFileService: FileServiceMock(isEnabledProvider: { true }),
            jotFileService: JotFileServiceMock(),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(),
            defaultsService: defaultsServiceMock
        )

        // Then
        XCTAssertFalse(repository.getShouldShowCloudMigration())
    }

    func test_getShouldShowCloudMigration_givenNoStoredFlagAndUbiquitousDisabled_persistsFalseAndReturnsFalse() {
        // Given
        let defaultsServiceMock = DefaultsServiceMock()
        let repository = CloudMigrationRepository(
            ubiquitousFileService: FileServiceMock(isEnabledProvider: { false }),
            jotFileService: JotFileServiceMock(),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(),
            defaultsService: defaultsServiceMock
        )

        // When
        let result = repository.getShouldShowCloudMigration()

        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(defaultsServiceMock.getValue(.isICloudEnabled), false)
    }

    func test_markCloudMigrationPageDone_setsHasDoneCloudMigrationToTrue() {
        // Given
        let defaultsServiceMock = DefaultsServiceMock()
        let repository = CloudMigrationRepository(
            ubiquitousFileService: FileServiceMock(),
            jotFileService: JotFileServiceMock(),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(),
            defaultsService: defaultsServiceMock
        )

        // When
        repository.markCloudMigrationPageDone()

        // Then
        XCTAssertEqual(defaultsServiceMock.getValue(.hasDoneCloudMigration), true)
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
