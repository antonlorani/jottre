import XCTest

@testable import Jottre

final class JotsRepositoryTests: XCTestCase {

    func test_getJotFiles_givenJotFileInfos_emitsThemSortedByModificationDateDescending() async throws {
        // Given
        let older = JotFile.Info(
            url: URL(staticString: "file:///tmp/older.jot"),
            name: "older",
            modificationDate: Date(timeIntervalSince1970: 1_000),
            ubiquitousInfo: nil
        )
        let newer = JotFile.Info(
            url: URL(staticString: "file:///tmp/newer.jot"),
            name: "newer",
            modificationDate: Date(timeIntervalSince1970: 2_000),
            ubiquitousInfo: nil
        )
        let undated = JotFile.Info(
            url: URL(staticString: "file:///tmp/undated.jot"),
            name: "undated",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let jotFileServiceMock = JotFileServiceMock(
            documentsDirectoryContentsProvider: {
                AsyncThrowingStream { continuation in
                    continuation.yield([older, newer, undated])
                    continuation.finish()
                }
            }
        )
        let repository = JotsRepository(
            ubiquitousFileService: FileServiceMock(),
            applicationService: await ApplicationServiceMock(),
            deviceService: await DeviceServiceMock(),
            jotFileService: jotFileServiceMock,
            jotFilePreviewImageService: JotFilePreviewImageServiceMock()
        )

        // When
        var iterator = repository.getJotFiles().makeAsyncIterator()
        let first = try await XCTUnwrapAsync(try await iterator.next())

        // Then
        XCTAssertEqual(first.map(\.name), ["newer", "older", "undated"])
    }

    func test_shouldShowEnableICloudButton_givenUbiquitousServiceDisabled_returnsTrue() async {
        // Given
        let repository = JotsRepository(
            ubiquitousFileService: FileServiceMock(isEnabledProvider: { false }),
            applicationService: await ApplicationServiceMock(),
            deviceService: await DeviceServiceMock(),
            jotFileService: JotFileServiceMock(),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock()
        )

        // Then
        XCTAssertTrue(repository.shouldShowEnableICloudButton())
    }

    func test_shouldShowEnableICloudButton_givenUbiquitousServiceEnabled_returnsFalse() async {
        // Given
        let repository = JotsRepository(
            ubiquitousFileService: FileServiceMock(isEnabledProvider: { true }),
            applicationService: await ApplicationServiceMock(),
            deviceService: await DeviceServiceMock(),
            jotFileService: JotFileServiceMock(),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock()
        )

        // Then
        XCTAssertFalse(repository.shouldShowEnableICloudButton())
    }

    func test_duplicate_forwardsToJotFileService() async throws {
        // Given
        let duplicateProviderExpectation = XCTestExpectation(
            description: "JotFileServiceMock.duplicateProvider is called."
        )
        let inputInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let expectedDuplicatedInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note-1.jot"),
            name: "note-1",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let jotFileServiceMock = JotFileServiceMock(
            duplicateProvider: { receivedInfo in
                // Then
                XCTAssertEqual(receivedInfo, inputInfo)
                duplicateProviderExpectation.fulfill()
                return expectedDuplicatedInfo
            }
        )
        let repository = JotsRepository(
            ubiquitousFileService: FileServiceMock(),
            applicationService: await ApplicationServiceMock(),
            deviceService: await DeviceServiceMock(),
            jotFileService: jotFileServiceMock,
            jotFilePreviewImageService: JotFilePreviewImageServiceMock()
        )

        // When
        let result = try repository.duplicate(jotFileInfo: inputInfo)

        // Then
        XCTAssertEqual(result, expectedDuplicatedInfo)
        await fulfillment(of: [duplicateProviderExpectation], timeout: 0.2)
    }

    func test_download_callsStartDownloadOnUbiquitousFileServiceWithJotFileURL() async throws {
        // Given
        let startDownloadProviderExpectation = XCTestExpectation(
            description: "Ubiquitous startDownloadProvider is called."
        )
        let expectedFileURL = URL(staticString: "file:///cloud/note.jot")
        let ubiquitousFileServiceMock = FileServiceMock(
            startDownloadProvider: { receivedFileURL in
                // Then
                XCTAssertEqual(receivedFileURL, expectedFileURL)
                startDownloadProviderExpectation.fulfill()
            }
        )
        let repository = JotsRepository(
            ubiquitousFileService: ubiquitousFileServiceMock,
            applicationService: await ApplicationServiceMock(),
            deviceService: await DeviceServiceMock(),
            jotFileService: JotFileServiceMock(),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock()
        )

        // When
        try repository.download(
            jotFileInfo: JotFile.Info(
                url: expectedFileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: UbiquitousInfo(downloadStatus: .notDownloaded, isDownloading: false)
            )
        )

        // Then
        await fulfillment(of: [startDownloadProviderExpectation], timeout: 0.2)
    }

    func test_getPreviewImage_givenServiceThrows_returnsNil() async throws {
        // Given
        let jotFilePreviewImageServiceMock = JotFilePreviewImageServiceMock(
            getPreviewImageDataProvider: { _, _, _ in
                throw NSError(domain: "test", code: 0)
            }
        )
        let repository = JotsRepository(
            ubiquitousFileService: FileServiceMock(),
            applicationService: await ApplicationServiceMock(),
            deviceService: await DeviceServiceMock(),
            jotFileService: JotFileServiceMock(),
            jotFilePreviewImageService: jotFilePreviewImageServiceMock
        )

        // When
        let image = await repository.getPreviewImage(
            jotFileInfo: JotFile.Info(
                url: URL(staticString: "file:///tmp/note.jot"),
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: nil
            ),
            userInterfaceStyle: .light,
            displayScale: 2.0
        )

        // Then
        XCTAssertNil(image)
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
