import UIKit
import XCTest

@testable import Jottre

@MainActor
final class JotConflictCellViewModelTests: XCTestCase {

    func test_init_storesNameAndInfoTextFromBusinessModel() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let businessModel = JotConflictBusinessModel(
            name: "note",
            jotFileInfo: jotFileInfo,
            jotFileVersion: JotFileVersion(localizedNameOfSavingComputer: "Mac", info: jotFileInfo)
        )

        // When
        let viewModel = JotConflictCellViewModel(
            jotConflict: businessModel,
            repository: JotConflictRepositoryMock()
        )

        // Then
        XCTAssertEqual(viewModel.name, "note")
        XCTAssertEqual(viewModel.infoText, "Mac")
    }

    func test_init_givenJotFileVersionWithoutSavingComputer_setsInfoTextToNa() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let businessModel = JotConflictBusinessModel(
            name: "note",
            jotFileInfo: jotFileInfo,
            jotFileVersion: JotFileVersion(localizedNameOfSavingComputer: nil, info: jotFileInfo)
        )

        // When
        let viewModel = JotConflictCellViewModel(
            jotConflict: businessModel,
            repository: JotConflictRepositoryMock()
        )

        // Then
        XCTAssertEqual(viewModel.infoText, "n/a")
    }

    func test_getPreviewImage_forwardsJotFileInfoAndVersionToRepository() async throws {
        // Given
        let getPreviewImageExpectation = XCTestExpectation(
            description: "JotConflictRepositoryMock.getPreviewImageProvider is called."
        )
        let expectedImage = UIImage()
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let jotFileVersion = JotFileVersion(localizedNameOfSavingComputer: "Mac", info: jotFileInfo)
        let businessModel = JotConflictBusinessModel(
            name: "note",
            jotFileInfo: jotFileInfo,
            jotFileVersion: jotFileVersion
        )
        let repositoryMock = JotConflictRepositoryMock(
            getPreviewImageProvider: { receivedInfo, receivedVersion, receivedStyle, receivedScale in
                // Then
                XCTAssertEqual(receivedInfo, jotFileInfo)
                XCTAssertEqual(receivedVersion, jotFileVersion)
                XCTAssertEqual(receivedStyle, .dark)
                XCTAssertEqual(receivedScale, 3.0)
                getPreviewImageExpectation.fulfill()
                return expectedImage
            }
        )
        let viewModel = JotConflictCellViewModel(
            jotConflict: businessModel,
            repository: repositoryMock
        )

        // When
        let image = await viewModel.getPreviewImage(userInterfaceStyle: .dark, displayScale: 3.0)

        // Then
        XCTAssertIdentical(image, expectedImage)
        await fulfillment(of: [getPreviewImageExpectation], timeout: 0.2)
    }

    func test_handleAction_givenTap_doesNothing() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let viewModel = JotConflictCellViewModel(
            jotConflict: JotConflictBusinessModel(
                name: "note",
                jotFileInfo: jotFileInfo,
                jotFileVersion: JotFileVersion(localizedNameOfSavingComputer: nil, info: jotFileInfo)
            ),
            repository: JotConflictRepositoryMock()
        )

        // When
        viewModel.handle(action: .tap)

        // Then
        XCTAssertEqual(viewModel.name, "note")
    }
}
