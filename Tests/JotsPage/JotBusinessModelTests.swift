import XCTest

@testable import Jottre

final class JotBusinessModelTests: XCTestCase {

    func test_init_givenLocalJotFileInfo_isDownloadedTrueAndIsDownloadingFalse() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let model = JotBusinessModel(jotFileInfo: jotFileInfo)

        // Then
        XCTAssertEqual(model.name, "note")
        XCTAssertTrue(model.isDownloaded)
        XCTAssertFalse(model.isDownloading)
    }

    func test_init_givenUbiquitousInfoWithNotDownloaded_isDownloadedFalse() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .notDownloaded, isDownloading: true)
        )

        // When
        let model = JotBusinessModel(jotFileInfo: jotFileInfo)

        // Then
        XCTAssertFalse(model.isDownloaded)
        XCTAssertTrue(model.isDownloading)
    }

    func test_init_givenUbiquitousInfoWithDownloaded_isDownloadedTrue() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .downloaded, isDownloading: false)
        )

        // When
        let model = JotBusinessModel(jotFileInfo: jotFileInfo)

        // Then
        XCTAssertTrue(model.isDownloaded)
        XCTAssertFalse(model.isDownloading)
    }

    func test_toJotFileInfo_returnsOriginalInfo() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let model = JotBusinessModel(jotFileInfo: jotFileInfo)

        // When
        let result = model.toJotFileInfo()

        // Then
        XCTAssertEqual(result, jotFileInfo)
    }
}
