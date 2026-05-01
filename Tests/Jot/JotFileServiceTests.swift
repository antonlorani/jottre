import XCTest

@testable import Jottre

final class JotFileServiceTests: XCTestCase {

    func test_write_givenLocalJotFile_writesEncodedDataToLocalFileService() async throws {
        // Given
        let writeFileProviderExpectation = XCTestExpectation(
            description: "FileServiceMock.writeFileProvider is called."
        )
        let expectedFileURL = URL(staticString: "file:///tmp/note.jot")
        let jot = Jot.makeEmpty()
        let jotFile = JotFile(
            info: JotFile.Info(
                url: expectedFileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: nil
            ),
            jot: jot
        )
        let expectedData = try PropertyListEncoder().encode(jot)
        let localFileServiceMock = FileServiceMock(
            writeFileProvider: { receivedFileURL, receivedData in
                // Then
                XCTAssertEqual(receivedFileURL, expectedFileURL)
                XCTAssertEqual(receivedData, expectedData)
                writeFileProviderExpectation.fulfill()
            }
        )
        let ubiquitousFileServiceMock = FileServiceMock(
            writeFileProvider: { _, _ in
                XCTFail("Ubiquitous file service should not be used for local jot files.")
            }
        )
        let jotFileService = JotFileService(
            localFileService: localFileServiceMock,
            ubiquitousFileService: ubiquitousFileServiceMock
        )

        // When
        try jotFileService.write(jotFile: jotFile)

        // Then
        await fulfillment(of: [writeFileProviderExpectation], timeout: 0.2)
    }

    func test_write_givenUbiquitousJotFile_writesEncodedDataToUbiquitousFileService() async throws {
        // Given
        let writeFileProviderExpectation = XCTestExpectation(description: "Ubiquitous writeFileProvider is called.")
        let expectedFileURL = URL(staticString: "file:///cloud/note.jot")
        let jot = Jot.makeEmpty()
        let jotFile = JotFile(
            info: JotFile.Info(
                url: expectedFileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: UbiquitousInfo(
                    downloadStatus: .current,
                    isDownloading: false
                )
            ),
            jot: jot
        )
        let localFileServiceMock = FileServiceMock(
            writeFileProvider: { _, _ in
                XCTFail("Local file service should not be used for ubiquitous jot files.")
            }
        )
        let ubiquitousFileServiceMock = FileServiceMock(
            writeFileProvider: { receivedFileURL, _ in
                // Then
                XCTAssertEqual(receivedFileURL, expectedFileURL)
                writeFileProviderExpectation.fulfill()
            }
        )
        let jotFileService = JotFileService(
            localFileService: localFileServiceMock,
            ubiquitousFileService: ubiquitousFileServiceMock
        )

        // When
        try jotFileService.write(jotFile: jotFile)

        // Then
        await fulfillment(of: [writeFileProviderExpectation], timeout: 0.2)
    }

    func test_readJotFile_givenLocalJotFileInfo_decodesDataFromLocalFileService() async throws {
        // Given
        let readFileProviderExpectation = XCTestExpectation(description: "Local readFileProvider is called.")
        let expectedFileURL = URL(staticString: "file:///tmp/note.jot")
        let expectedJot = Jot.makeEmpty()
        let encodedData = try PropertyListEncoder().encode(expectedJot)
        let localFileServiceMock = FileServiceMock(
            readFileProvider: { receivedFileURL in
                // Then
                XCTAssertEqual(receivedFileURL, expectedFileURL)
                readFileProviderExpectation.fulfill()
                return encodedData
            }
        )
        let jotFileService = JotFileService(
            localFileService: localFileServiceMock,
            ubiquitousFileService: FileServiceMock()
        )

        // When
        let jotFile = try jotFileService.readJotFile(
            jotFileInfo: JotFile.Info(
                url: expectedFileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: nil
            )
        )

        // Then
        XCTAssertEqual(jotFile.jot.drawing, expectedJot.drawing)
        XCTAssertEqual(jotFile.jot.width, expectedJot.width)
        XCTAssertEqual(jotFile.jot.version, expectedJot.version)
        await fulfillment(of: [readFileProviderExpectation], timeout: 0.2)
    }

    func test_remove_givenLocalJotFileInfo_callsRemoveOnLocalFileService() async throws {
        // Given
        let removeFileProviderExpectation = XCTestExpectation(description: "Local removeFileProvider is called.")
        let expectedFileURL = URL(staticString: "file:///tmp/note.jot")
        let localFileServiceMock = FileServiceMock(
            removeFileProvider: { receivedFileURL in
                // Then
                XCTAssertEqual(receivedFileURL, expectedFileURL)
                removeFileProviderExpectation.fulfill()
            }
        )
        let jotFileService = JotFileService(
            localFileService: localFileServiceMock,
            ubiquitousFileService: FileServiceMock()
        )

        // When
        try jotFileService.remove(
            jotFileInfo: JotFile.Info(
                url: expectedFileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: nil
            )
        )

        // Then
        await fulfillment(of: [removeFileProviderExpectation], timeout: 0.2)
    }

    func test_rename_givenLocalJotFileInfo_movesToNewURLAndReturnsUpdatedInfo() async throws {
        // Given
        let moveFileProviderExpectation = XCTestExpectation(description: "Local moveFileProvider is called.")
        let originalFileURL = URL(staticString: "file:///tmp/old.jot")
        let expectedNewFileURL = URL(staticString: "file:///tmp/new.jot")
        let localFileServiceMock = FileServiceMock(
            moveFileProvider: { receivedFileURL, receivedNewFileURL in
                // Then
                XCTAssertEqual(receivedFileURL, originalFileURL)
                XCTAssertEqual(receivedNewFileURL, expectedNewFileURL)
                moveFileProviderExpectation.fulfill()
            }
        )
        let jotFileService = JotFileService(
            localFileService: localFileServiceMock,
            ubiquitousFileService: FileServiceMock()
        )

        // When
        let renamed = try jotFileService.rename(
            jotFileInfo: JotFile.Info(
                url: originalFileURL,
                name: "old",
                modificationDate: nil,
                ubiquitousInfo: nil
            ),
            newName: "new"
        )

        // Then
        XCTAssertEqual(renamed.url, expectedNewFileURL)
        XCTAssertEqual(renamed.name, "new")
        await fulfillment(of: [moveFileProviderExpectation], timeout: 0.2)
    }

    func test_duplicate_givenLocalJotFileInfo_returnsDuplicatedInfo() async throws {
        // Given
        let duplicateFileProviderExpectation = XCTestExpectation(description: "Local duplicateFileProvider is called.")
        let originalFileURL = URL(staticString: "file:///tmp/note.jot")
        let duplicatedFileURL = URL(staticString: "file:///tmp/note-1.jot")
        let localFileServiceMock = FileServiceMock(
            duplicateFileProvider: { receivedFileURL in
                // Then
                XCTAssertEqual(receivedFileURL, originalFileURL)
                duplicateFileProviderExpectation.fulfill()
                return duplicatedFileURL
            }
        )
        let jotFileService = JotFileService(
            localFileService: localFileServiceMock,
            ubiquitousFileService: FileServiceMock()
        )

        // When
        let duplicated = try jotFileService.duplicate(
            jotFileInfo: JotFile.Info(
                url: originalFileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: nil
            )
        )

        // Then
        XCTAssertEqual(duplicated.url, duplicatedFileURL)
        XCTAssertEqual(duplicated.name, "note-1")
        await fulfillment(of: [duplicateFileProviderExpectation], timeout: 0.2)
    }

    func test_move_givenShouldBecomeUbiquitous_movesIntoUbiquitousDocumentsDirectory() async throws {
        // Given
        let moveFileProviderExpectation = XCTestExpectation(description: "Ubiquitous moveFileProvider is called.")
        let originalFileURL = URL(staticString: "file:///tmp/note.jot")
        let ubiquitousDocumentsDirectory = URL(staticString: "file:///cloud/Documents/")
        let expectedNewFileURL = ubiquitousDocumentsDirectory.appendingPathComponent("note.jot", isDirectory: false)
        let ubiquitousFileServiceMock = FileServiceMock(
            documentsDirectoryProvider: { ubiquitousDocumentsDirectory },
            moveFileProvider: { receivedFileURL, receivedNewFileURL in
                // Then
                XCTAssertEqual(receivedFileURL, originalFileURL)
                XCTAssertEqual(receivedNewFileURL, expectedNewFileURL)
                moveFileProviderExpectation.fulfill()
            }
        )
        let jotFileService = JotFileService(
            localFileService: FileServiceMock(),
            ubiquitousFileService: ubiquitousFileServiceMock
        )

        // When
        try await jotFileService.move(
            jotFileInfo: JotFile.Info(
                url: originalFileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: nil
            ),
            shouldBecomeUbiquitous: true
        )

        // Then
        await fulfillment(of: [moveFileProviderExpectation], timeout: 0.2)
    }

    func test_readJotFile_givenUbiquitousJotFileInfo_decodesDataFromUbiquitousFileService() async throws {
        // Given
        let readFileProviderExpectation = XCTestExpectation(description: "Ubiquitous readFileProvider is called.")
        let expectedFileURL = URL(staticString: "file:///cloud/note.jot")
        let expectedJot = Jot.makeEmpty()
        let encodedData = try PropertyListEncoder().encode(expectedJot)
        let ubiquitousFileServiceMock = FileServiceMock(
            readFileProvider: { receivedFileURL in
                // Then
                XCTAssertEqual(receivedFileURL, expectedFileURL)
                readFileProviderExpectation.fulfill()
                return encodedData
            }
        )
        let jotFileService = JotFileService(
            localFileService: FileServiceMock(
                readFileProvider: { _ in
                    XCTFail("Local file service should not be used for ubiquitous jot files.")
                    return Data()
                }
            ),
            ubiquitousFileService: ubiquitousFileServiceMock
        )

        // When
        _ = try jotFileService.readJotFile(
            jotFileInfo: JotFile.Info(
                url: expectedFileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: UbiquitousInfo(downloadStatus: .current, isDownloading: false)
            )
        )

        // Then
        await fulfillment(of: [readFileProviderExpectation], timeout: 0.2)
    }

    func test_remove_givenUbiquitousJotFileInfo_callsRemoveOnUbiquitousFileService() async throws {
        // Given
        let removeFileProviderExpectation = XCTestExpectation(description: "Ubiquitous removeFileProvider is called.")
        let expectedFileURL = URL(staticString: "file:///cloud/note.jot")
        let ubiquitousFileServiceMock = FileServiceMock(
            removeFileProvider: { receivedFileURL in
                // Then
                XCTAssertEqual(receivedFileURL, expectedFileURL)
                removeFileProviderExpectation.fulfill()
            }
        )
        let jotFileService = JotFileService(
            localFileService: FileServiceMock(
                removeFileProvider: { _ in
                    XCTFail("Local file service should not be used for ubiquitous jot files.")
                }
            ),
            ubiquitousFileService: ubiquitousFileServiceMock
        )

        // When
        try jotFileService.remove(
            jotFileInfo: JotFile.Info(
                url: expectedFileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: UbiquitousInfo(downloadStatus: .current, isDownloading: false)
            )
        )

        // Then
        await fulfillment(of: [removeFileProviderExpectation], timeout: 0.2)
    }

    func test_move_givenDocumentsDirectoryUnresolved_throwsCouldNotResolveFailure() async {
        // Given
        let localFileServiceMock = FileServiceMock(
            documentsDirectoryProvider: { nil }
        )
        let jotFileService = JotFileService(
            localFileService: localFileServiceMock,
            ubiquitousFileService: FileServiceMock()
        )

        // When / Then
        do {
            try await jotFileService.move(
                jotFileInfo: JotFile.Info(
                    url: URL(staticString: "file:///tmp/note.jot"),
                    name: "note",
                    modificationDate: nil,
                    ubiquitousInfo: nil
                ),
                shouldBecomeUbiquitous: false
            )
            XCTFail("Expected JotFileService.Failure.couldNotResolveDocumentsDirectory.")
        } catch JotFileService.Failure.couldNotResolveDocumentsDirectory {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
