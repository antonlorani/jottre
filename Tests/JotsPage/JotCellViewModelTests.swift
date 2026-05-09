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

@MainActor
final class JotCellViewModelTests: XCTestCase {

    func test_init_givenIsDownloadingTrue_setsPreviewToLoadingIndicator() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .notDownloaded, isDownloading: true)
        )
        let businessModel = JotBusinessModel(jotFileInfo: jotFileInfo)

        // When
        let viewModel = JotCellViewModel(
            jot: businessModel,
            jotMenuConfigurations: makeEmptyJotMenuConfigurations(),
            repository: JotsRepositoryMock(),
            onAction: {}
        )

        // Then
        XCTAssertEqual(viewModel.preview, .loadingIndicator)
        XCTAssertEqual(viewModel.name, "note")
    }

    func test_init_givenDownloadedAndNotDownloading_setsPreviewToThumbnail() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        )

        // When
        let viewModel = JotCellViewModel(
            jot: JotBusinessModel(jotFileInfo: jotFileInfo),
            jotMenuConfigurations: makeEmptyJotMenuConfigurations(),
            repository: JotsRepositoryMock(),
            onAction: {}
        )

        // Then
        XCTAssertEqual(viewModel.preview, .thumbnail)
    }

    func test_init_givenNotDownloadedAndNotDownloading_setsPreviewToCloudImage() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .notDownloaded, isDownloading: false)
        )

        // When
        let viewModel = JotCellViewModel(
            jot: JotBusinessModel(jotFileInfo: jotFileInfo),
            jotMenuConfigurations: makeEmptyJotMenuConfigurations(),
            repository: JotsRepositoryMock(),
            onAction: {}
        )

        // Then
        XCTAssertEqual(viewModel.preview, .cloudImage)
    }

    func test_handleAction_givenTap_invokesOnAction() async {
        // Given
        let onActionExpectation = XCTestExpectation(description: "onAction is called.")
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let viewModel = JotCellViewModel(
            jot: JotBusinessModel(jotFileInfo: jotFileInfo),
            jotMenuConfigurations: makeEmptyJotMenuConfigurations(),
            repository: JotsRepositoryMock(),
            onAction: { onActionExpectation.fulfill() }
        )

        // When
        viewModel.handle(action: .tap)

        // Then
        await fulfillment(of: [onActionExpectation], timeout: 0.2)
    }

    func test_getPreviewImage_forwardsToRepositoryWithJotFileInfo() async throws {
        // Given
        let getPreviewImageProviderExpectation = XCTestExpectation(
            description: "JotsRepositoryMock.getPreviewImageProvider is called."
        )
        let expectedImage = UIImage()
        let expectedFileURL = URL(staticString: "file:///tmp/note.jot")
        let jotFileInfo = JotFile.Info(
            url: expectedFileURL,
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let repositoryMock = JotsRepositoryMock(
            getPreviewImageProvider: { receivedInfo, receivedStyle, receivedScale in
                // Then
                XCTAssertEqual(receivedInfo.url, expectedFileURL)
                XCTAssertEqual(receivedStyle, .dark)
                XCTAssertEqual(receivedScale, 3.0)
                getPreviewImageProviderExpectation.fulfill()
                return expectedImage
            }
        )
        let viewModel = JotCellViewModel(
            jot: JotBusinessModel(jotFileInfo: jotFileInfo),
            jotMenuConfigurations: makeEmptyJotMenuConfigurations(),
            repository: repositoryMock,
            onAction: {}
        )

        // When
        let image = await viewModel.getPreviewImage(userInterfaceStyle: .dark, displayScale: 3.0)

        // Then
        XCTAssertIdentical(image, expectedImage)
        await fulfillment(of: [getPreviewImageProviderExpectation], timeout: 0.2)
    }

    private func makeEmptyJotMenuConfigurations() -> JotMenuConfigurations {
        JotMenuConfigurations { _ in [] }
    }
}
