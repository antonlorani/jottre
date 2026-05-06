import UIKit
import XCTest

@testable import Jottre

final class JotConflictRepositoryTests: XCTestCase {

    func test_resolveVersionConflicts_forwardsToJotFileConflictService() async throws {
        // Given
        let resolveVersionConflictsExpectation = XCTestExpectation(
            description: "JotFileConflictServiceMock.resolveVersionConflictsProvider is called."
        )
        let inputInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let inputVersions = [
            JotFileVersion(localizedNameOfSavingComputer: "Mac", info: inputInfo),
            JotFileVersion(localizedNameOfSavingComputer: "iPad", info: inputInfo),
        ]
        let jotFileConflictServiceMock = JotFileConflictServiceMock(
            resolveVersionConflictsProvider: { receivedInfo, receivedVersions in
                // Then
                XCTAssertEqual(receivedInfo, inputInfo)
                XCTAssertEqual(receivedVersions, inputVersions)
                resolveVersionConflictsExpectation.fulfill()
            }
        )
        let repository = JotConflictRepository(
            jotFileConflictService: jotFileConflictServiceMock,
            jotFilePreviewImageService: JotFilePreviewImageServiceMock()
        )

        // When
        try repository.resolveVersionConflicts(jotFileInfo: inputInfo, resolvedVersions: inputVersions)

        // Then
        await fulfillment(of: [resolveVersionConflictsExpectation], timeout: 0.2)
    }

    func test_getPreviewImage_givenCopyVersionToTemporaryReturnsNil_usesOriginalInfo() async throws {
        // Given
        let getPreviewImageDataExpectation = XCTestExpectation(
            description: "JotFilePreviewImageServiceMock.getPreviewImageDataProvider is called with original info."
        )
        let originalInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let imageData = try XCTUnwrap(UIImage(systemName: "doc")?.pngData())
        let jotFileConflictServiceMock = JotFileConflictServiceMock(
            copyVersionToTemporaryProvider: { _, _ in nil }
        )
        let jotFilePreviewImageServiceMock = JotFilePreviewImageServiceMock(
            getPreviewImageDataProvider: { receivedInfo, receivedStyle, receivedScale in
                // Then
                XCTAssertEqual(receivedInfo, originalInfo)
                XCTAssertEqual(receivedStyle, .light)
                XCTAssertEqual(receivedScale, 2.0)
                getPreviewImageDataExpectation.fulfill()
                return imageData
            }
        )
        let repository = JotConflictRepository(
            jotFileConflictService: jotFileConflictServiceMock,
            jotFilePreviewImageService: jotFilePreviewImageServiceMock
        )

        // When
        let image = await repository.getPreviewImage(
            jotFileInfo: originalInfo,
            jotFileVersion: JotFileVersion(localizedNameOfSavingComputer: "Mac", info: originalInfo),
            userInterfaceStyle: .light,
            displayScale: 2.0
        )

        // Then
        XCTAssertNotNil(image)
        await fulfillment(of: [getPreviewImageDataExpectation], timeout: 0.2)
    }

    func test_getPreviewImage_givenCopyVersionToTemporaryReturnsInfo_usesTemporaryInfoAndCleansUp() async throws {
        // Given
        let getPreviewImageDataExpectation = XCTestExpectation(
            description: "JotFilePreviewImageServiceMock.getPreviewImageDataProvider is called with temporary info."
        )
        let originalInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jot")
        try Data().write(to: temporaryURL)
        let temporaryInfo = JotFile.Info(
            url: temporaryURL,
            name: "tmp",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let imageData = try XCTUnwrap(UIImage(systemName: "doc")?.pngData())
        let jotFileConflictServiceMock = JotFileConflictServiceMock(
            copyVersionToTemporaryProvider: { _, _ in temporaryInfo }
        )
        let jotFilePreviewImageServiceMock = JotFilePreviewImageServiceMock(
            getPreviewImageDataProvider: { receivedInfo, _, _ in
                // Then
                XCTAssertEqual(receivedInfo, temporaryInfo)
                getPreviewImageDataExpectation.fulfill()
                return imageData
            }
        )
        let repository = JotConflictRepository(
            jotFileConflictService: jotFileConflictServiceMock,
            jotFilePreviewImageService: jotFilePreviewImageServiceMock
        )

        // When
        let image = await repository.getPreviewImage(
            jotFileInfo: originalInfo,
            jotFileVersion: JotFileVersion(localizedNameOfSavingComputer: "Mac", info: originalInfo),
            userInterfaceStyle: .light,
            displayScale: 2.0
        )

        // Then
        XCTAssertNotNil(image)
        XCTAssertFalse(FileManager.default.fileExists(atPath: temporaryURL.path))
        await fulfillment(of: [getPreviewImageDataExpectation], timeout: 0.2)
    }

    func test_getPreviewImage_givenPreviewImageServiceThrows_returnsNil() async throws {
        // Given
        let originalInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let repository = JotConflictRepository(
            jotFileConflictService: JotFileConflictServiceMock(),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(
                getPreviewImageDataProvider: { _, _, _ in
                    throw NSError(domain: "test", code: 0)
                }
            )
        )

        // When
        let image = await repository.getPreviewImage(
            jotFileInfo: originalInfo,
            jotFileVersion: JotFileVersion(localizedNameOfSavingComputer: "Mac", info: originalInfo),
            userInterfaceStyle: .light,
            displayScale: 2.0
        )

        // Then
        XCTAssertNil(image)
    }
}
