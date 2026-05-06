import XCTest

@testable import Jottre

final class JotFileConflictServiceTests: XCTestCase {

    func test_getConfictingVersions_givenNilFromUnderlyingService_returnsNil() {
        // Given
        let service = JotFileConflictService(
            fileConflictService: FileConflictServiceMock(
                getConflictingVersionsProvider: { _ in nil }
            )
        )

        // When
        let result = service.getConfictingVersions(jotFileInfo: makeJotFileInfo())

        // Then
        XCTAssertNil(result)
    }

    func test_getConfictingVersions_givenEmptyArrayFromUnderlyingService_returnsNil() {
        // Given
        let service = JotFileConflictService(
            fileConflictService: FileConflictServiceMock(
                getConflictingVersionsProvider: { _ in [] }
            )
        )

        // When
        let result = service.getConfictingVersions(jotFileInfo: makeJotFileInfo())

        // Then
        XCTAssertNil(result)
    }

    func test_resolveVersionConflicts_forwardsURLsToUnderlyingService() async throws {
        // Given
        let resolveVersionConflictsExpectation = XCTestExpectation(
            description: "FileConflictServiceMock.resolveVersionConflictsProvider is called."
        )
        let inputInfo = makeJotFileInfo()
        let versionURLA = URL(staticString: "file:///tmp/version-a.jot")
        let versionURLB = URL(staticString: "file:///tmp/version-b.jot")
        let versionInfos = [
            JotFileVersion(
                localizedNameOfSavingComputer: "A",
                info: JotFile.Info(url: versionURLA, name: "a", modificationDate: nil, ubiquitousInfo: nil)
            ),
            JotFileVersion(
                localizedNameOfSavingComputer: "B",
                info: JotFile.Info(url: versionURLB, name: "b", modificationDate: nil, ubiquitousInfo: nil)
            ),
        ]
        let fileConflictServiceMock = FileConflictServiceMock(
            resolveVersionConflictsProvider: { receivedFileURL, receivedResolvedVersions in
                // Then
                XCTAssertEqual(receivedFileURL, inputInfo.url)
                XCTAssertEqual(receivedResolvedVersions, [versionURLA, versionURLB])
                resolveVersionConflictsExpectation.fulfill()
            }
        )
        let service = JotFileConflictService(fileConflictService: fileConflictServiceMock)

        // When
        try service.resolveVersionConflicts(jotFileInfo: inputInfo, resolvedVersions: versionInfos)

        // Then
        await fulfillment(of: [resolveVersionConflictsExpectation], timeout: 0.2)
    }

    func test_copyVersionToTemporary_givenUnderlyingReturnsURL_returnsInfoWithTemporaryURLAndOriginalMetadata() throws {
        // Given
        let temporaryURL = URL(staticString: "file:///tmp/copy.jot")
        let fileConflictServiceMock = FileConflictServiceMock(
            copyVersionToTemporaryProvider: { _, _ in temporaryURL }
        )
        let service = JotFileConflictService(fileConflictService: fileConflictServiceMock)
        let modificationDate = Date(timeIntervalSince1970: 1_000)
        let versionInfo = JotFile.Info(
            url: URL(staticString: "file:///cloud/version.jot"),
            name: "version",
            modificationDate: modificationDate,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        )
        let jotFileVersion = JotFileVersion(localizedNameOfSavingComputer: "Mac", info: versionInfo)

        // When
        let result = try service.copyVersionToTemporary(
            jotFileInfo: makeJotFileInfo(),
            jotFileVersion: jotFileVersion
        )

        // Then
        let unwrapped = try XCTUnwrap(result)
        XCTAssertEqual(unwrapped.url, temporaryURL)
        XCTAssertEqual(unwrapped.name, versionInfo.name)
        XCTAssertEqual(unwrapped.modificationDate, modificationDate)
        XCTAssertEqual(unwrapped.ubiquitousInfo, versionInfo.ubiquitousInfo)
    }

    func test_copyVersionToTemporary_givenUnderlyingReturnsNil_returnsNil() throws {
        // Given
        let service = JotFileConflictService(
            fileConflictService: FileConflictServiceMock(copyVersionToTemporaryProvider: { _, _ in nil })
        )
        let jotFileVersion = JotFileVersion(
            localizedNameOfSavingComputer: nil,
            info: makeJotFileInfo()
        )

        // When
        let result = try service.copyVersionToTemporary(
            jotFileInfo: makeJotFileInfo(),
            jotFileVersion: jotFileVersion
        )

        // Then
        XCTAssertNil(result)
    }

    private func makeJotFileInfo() -> JotFile.Info {
        JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        )
    }
}
