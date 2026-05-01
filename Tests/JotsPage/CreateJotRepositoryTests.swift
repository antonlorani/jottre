import XCTest

@testable import Jottre

final class CreateJotRepositoryTests: XCTestCase {

    func test_createJot_givenUbiquitousDocumentsDirectoryAvailable_writesToUbiquitousService() async throws {
        // Given
        let writeProviderExpectation = XCTestExpectation(description: "JotFileServiceMock.writeProvider is called.")
        let ubiquitousDocumentsDirectory = URL(staticString: "file:///cloud/Documents/")
        let jotFileServiceMock = JotFileServiceMock(
            writeProvider: { jotFile in
                // Then
                XCTAssertEqual(jotFile.info.name, "note")
                XCTAssertNotNil(jotFile.info.ubiquitousInfo)
                XCTAssertEqual(
                    jotFile.info.url,
                    ubiquitousDocumentsDirectory.appendingPathComponent("note", isDirectory: false)
                        .appendingPathExtension("jot")
                )
                writeProviderExpectation.fulfill()
            }
        )
        let repository = CreateJotRepository(
            localFileService: FileServiceMock(
                documentsDirectoryProvider: {
                    XCTFail("Local file service should not be used when ubiquitous is available.")
                    return nil
                }
            ),
            ubiquitousFileService: FileServiceMock(
                documentsDirectoryProvider: { ubiquitousDocumentsDirectory }
            ),
            jotFileService: jotFileServiceMock
        )

        // When
        let info = try await repository.createJot(name: "note")

        // Then
        XCTAssertNotNil(info.ubiquitousInfo)
        await fulfillment(of: [writeProviderExpectation], timeout: 0.2)
    }

    func test_createJot_givenOnlyLocalDocumentsDirectoryAvailable_writesToLocalService() async throws {
        // Given
        let writeProviderExpectation = XCTestExpectation(description: "JotFileServiceMock.writeProvider is called.")
        let localDocumentsDirectory = URL(staticString: "file:///local/Documents/")
        let jotFileServiceMock = JotFileServiceMock(
            writeProvider: { jotFile in
                // Then
                XCTAssertNil(jotFile.info.ubiquitousInfo)
                XCTAssertEqual(
                    jotFile.info.url,
                    localDocumentsDirectory.appendingPathComponent("note", isDirectory: false).appendingPathExtension(
                        "jot"
                    )
                )
                writeProviderExpectation.fulfill()
            }
        )
        let repository = CreateJotRepository(
            localFileService: FileServiceMock(
                documentsDirectoryProvider: { localDocumentsDirectory }
            ),
            ubiquitousFileService: FileServiceMock(
                documentsDirectoryProvider: { nil }
            ),
            jotFileService: jotFileServiceMock
        )

        // When
        let info = try await repository.createJot(name: "note")

        // Then
        XCTAssertNil(info.ubiquitousInfo)
        await fulfillment(of: [writeProviderExpectation], timeout: 0.2)
    }

    func test_createJot_givenNoDocumentsDirectoryAvailable_throwsCouldNotCreateFile() async {
        // Given
        let repository = CreateJotRepository(
            localFileService: FileServiceMock(documentsDirectoryProvider: { nil }),
            ubiquitousFileService: FileServiceMock(documentsDirectoryProvider: { nil }),
            jotFileService: JotFileServiceMock()
        )

        // When / Then
        do {
            _ = try await repository.createJot(name: "note")
            XCTFail("Expected CreateJotRepository.Failure.couldNotCreateFile.")
        } catch CreateJotRepository.Failure.couldNotCreateFile {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_createJot_givenFileAlreadyExists_throwsFileExists() async {
        // Given
        let repository = CreateJotRepository(
            localFileService: FileServiceMock(documentsDirectoryProvider: { nil }),
            ubiquitousFileService: FileServiceMock(
                documentsDirectoryProvider: { URL(staticString: "file:///cloud/Documents/") },
                fileExistsProvider: { _ in true }
            ),
            jotFileService: JotFileServiceMock(
                writeProvider: { _ in
                    XCTFail("Should not write when file already exists.")
                }
            )
        )

        // When / Then
        do {
            _ = try await repository.createJot(name: "note")
            XCTFail("Expected CreateJotRepository.Failure.fileExists.")
        } catch CreateJotRepository.Failure.fileExists {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
