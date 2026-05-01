import XCTest

@testable import Jottre

final class JotFileTests: XCTestCase {

    func test_infoInit_givenURLWithJotExtension_succeedsAndDerivesNameFromURL() throws {
        // Given
        let url = URL(staticString: "file:///tmp/note.jot")

        // When
        let info = try XCTUnwrap(
            JotFile.Info(
                url: url,
                modificationDate: nil,
                ubiquitousInfo: nil
            )
        )

        // Then
        XCTAssertEqual(info.name, "note")
        XCTAssertEqual(info.url, url)
    }

    func test_infoInit_givenURLWithNonJotExtension_returnsNil() {
        // Given
        let url = URL(staticString: "file:///tmp/note.txt")

        // When
        let info = JotFile.Info(
            url: url,
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // Then
        XCTAssertNil(info)
    }

    func test_makeEmptyJot_returnsVersionThreeWithDefaultWidth() {
        // When
        let jot = Jot.makeEmpty()

        // Then
        XCTAssertEqual(jot.version, 3)
        XCTAssertEqual(jot.width, 1200)
        XCTAssertFalse(jot.drawing.isEmpty)
    }
}
