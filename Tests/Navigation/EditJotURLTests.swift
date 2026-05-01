import XCTest

@testable import Jottre

final class EditJotURLTests: XCTestCase {

    func test_init_givenJotFileInfo_setsFileURLFromInfo() {
        // Given
        let fileURL = URL(staticString: "file:///tmp/note.jot")
        let info = JotFile.Info(
            url: fileURL,
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let editJotURL = EditJotURL(jotFileInfo: info)

        // Then
        XCTAssertEqual(editJotURL.fileURL, fileURL)
        XCTAssertEqual(editJotURL.path, "/jots/edit")
    }

    func test_initFromURL_givenMatchingPathAndQueryItem_succeeds() throws {
        // Given
        let url = URL(staticString: "scheme:///jots/edit?fileURL=file:///tmp/note.jot")

        // When
        let editJotURL = try XCTUnwrap(EditJotURL(url: url))

        // Then
        XCTAssertEqual(editJotURL.fileURL, URL(staticString: "file:///tmp/note.jot"))
    }

    func test_initFromURL_givenWrongPath_returnsNil() {
        // Given
        let url = URL(staticString: "scheme:///not/the/right/path?fileURL=file:///tmp/note.jot")

        // When
        let editJotURL = EditJotURL(url: url)

        // Then
        XCTAssertNil(editJotURL)
    }

    func test_initFromURL_givenMissingFileURLQueryItem_returnsNil() {
        // Given
        let url = URL(staticString: "scheme:///jots/edit")

        // When
        let editJotURL = EditJotURL(url: url)

        // Then
        XCTAssertNil(editJotURL)
    }

    func test_toURL_roundTripsFileURL() throws {
        // Given
        let fileURL = URL(staticString: "file:///tmp/note.jot")
        let original = EditJotURL(
            jotFileInfo: JotFile.Info(
                url: fileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: nil
            )
        )

        // When
        let roundTripped = try XCTUnwrap(EditJotURL(url: original.toURL()))

        // Then
        XCTAssertEqual(roundTripped.fileURL, fileURL)
    }
}
