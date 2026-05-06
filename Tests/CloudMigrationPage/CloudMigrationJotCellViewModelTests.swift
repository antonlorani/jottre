import UIKit
import XCTest

@testable import Jottre

@MainActor
final class CloudMigrationJotCellViewModelTests: XCTestCase {

    func test_init_storesNameInfoTextAndCloudFlagsFromBusinessModel() {
        // Given
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: date,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        )
        let businessModel = CloudMigrationJotBusinessModel(jotFileInfo: jotFileInfo)
        let expectedInfoText = DateFormatter.localizedString(
            from: date,
            dateStyle: .long,
            timeStyle: .short
        )

        // When
        let viewModel = CloudMigrationJotCellViewModel(
            cloudMigrationJot: businessModel,
            repository: CloudMigrationRepositoryMock(),
            onTap: {}
        )

        // Then
        XCTAssertEqual(viewModel.name, "note")
        XCTAssertEqual(viewModel.infoText, expectedInfoText)
        XCTAssertTrue(viewModel.isCloudCheckboxOn)
        XCTAssertFalse(viewModel.isDownloading)
    }

    func test_init_givenLocalJotFile_setsCloudCheckboxOff() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let viewModel = CloudMigrationJotCellViewModel(
            cloudMigrationJot: CloudMigrationJotBusinessModel(jotFileInfo: jotFileInfo),
            repository: CloudMigrationRepositoryMock(),
            onTap: {}
        )

        // Then
        XCTAssertFalse(viewModel.isCloudCheckboxOn)
        XCTAssertEqual(viewModel.infoText, "")
    }

    func test_handleAction_givenTap_invokesOnTap() async {
        // Given
        let onTapExpectation = XCTestExpectation(description: "onTap is called.")
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let viewModel = CloudMigrationJotCellViewModel(
            cloudMigrationJot: CloudMigrationJotBusinessModel(jotFileInfo: jotFileInfo),
            repository: CloudMigrationRepositoryMock(),
            onTap: { onTapExpectation.fulfill() }
        )

        // When
        viewModel.handle(action: .tap)

        // Then
        await fulfillment(of: [onTapExpectation], timeout: 0.2)
    }

    func test_getPreviewImage_forwardsJotFileInfoToRepository() async throws {
        // Given
        let getPreviewImageExpectation = XCTestExpectation(
            description: "CloudMigrationRepositoryMock.getPreviewImageProvider is called."
        )
        let expectedImage = UIImage()
        let expectedFileURL = URL(staticString: "file:///tmp/note.jot")
        let jotFileInfo = JotFile.Info(
            url: expectedFileURL,
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let repositoryMock = CloudMigrationRepositoryMock(
            getPreviewImageProvider: { receivedInfo, receivedStyle, receivedScale in
                // Then
                XCTAssertEqual(receivedInfo.url, expectedFileURL)
                XCTAssertEqual(receivedStyle, .light)
                XCTAssertEqual(receivedScale, 2.0)
                getPreviewImageExpectation.fulfill()
                return expectedImage
            }
        )
        let viewModel = CloudMigrationJotCellViewModel(
            cloudMigrationJot: CloudMigrationJotBusinessModel(jotFileInfo: jotFileInfo),
            repository: repositoryMock,
            onTap: {}
        )

        // When
        let image = await viewModel.getPreviewImage(userInterfaceStyle: .light, displayScale: 2.0)

        // Then
        XCTAssertIdentical(image, expectedImage)
        await fulfillment(of: [getPreviewImageExpectation], timeout: 0.2)
    }
}
