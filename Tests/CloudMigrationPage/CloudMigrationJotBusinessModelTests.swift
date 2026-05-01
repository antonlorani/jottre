import XCTest

@testable import Jottre

final class CloudMigrationJotBusinessModelTests: XCTestCase {

    func test_init_givenLocalInfo_isUbiquitousFalseAndIsDownloadedTrue() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let model = CloudMigrationJotBusinessModel(jotFileInfo: info)

        // Then
        XCTAssertEqual(model.name, "note")
        XCTAssertFalse(model.isUbiquitous)
        XCTAssertTrue(model.isDownloaded)
        XCTAssertFalse(model.isDownloading)
        XCTAssertEqual(model.lastModifiedText, "")
    }

    func test_init_givenUbiquitousInfoNotDownloaded_isUbiquitousTrueAndIsDownloadedFalse() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .notDownloaded, isDownloading: true)
        )

        // When
        let model = CloudMigrationJotBusinessModel(jotFileInfo: info)

        // Then
        XCTAssertTrue(model.isUbiquitous)
        XCTAssertFalse(model.isDownloaded)
        XCTAssertTrue(model.isDownloading)
    }

    func test_init_givenModificationDate_formatsLastModifiedText() {
        // Given
        let date = Date(timeIntervalSince1970: 0)
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: date,
            ubiquitousInfo: nil
        )

        // When
        let model = CloudMigrationJotBusinessModel(jotFileInfo: info)

        // Then
        XCTAssertFalse(model.lastModifiedText.isEmpty)
        XCTAssertEqual(
            model.lastModifiedText,
            DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .short)
        )
    }

    func test_toJotFileInfo_returnsOriginalInfo() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let model = CloudMigrationJotBusinessModel(jotFileInfo: info)

        // Then
        XCTAssertEqual(model.toJotFileInfo(), info)
    }
}
