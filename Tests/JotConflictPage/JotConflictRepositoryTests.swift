/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

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
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(),
            logger: LoggerMock()
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
            jotFilePreviewImageService: jotFilePreviewImageServiceMock,
            logger: LoggerMock()
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
            jotFilePreviewImageService: jotFilePreviewImageServiceMock,
            logger: LoggerMock()
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

    func test_getPreviewImage_givenPreviewImageServiceThrows_returnsNilAndLogsError() async throws {
        // Given
        let errorExpectation = XCTestExpectation(description: "LoggerMock.errorProvider is called.")
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
            ),
            logger: LoggerMock(
                errorProvider: { message in
                    if message.contains("Failed to load conflict preview image") {
                        errorExpectation.fulfill()
                    }
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
        await fulfillment(of: [errorExpectation], timeout: 0.2)
    }
}
