import XCTest

@testable import Jottre

final class RevealFileURLTests: XCTestCase {

    func test_init_givenJotFileInfo_extractsPathFromInfoURL() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/dir/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let revealFileURL = RevealFileURL(jotFileInfo: info)

        // Then
        XCTAssertEqual(revealFileURL.scheme, "shareddocuments")
        XCTAssertEqual(revealFileURL.host, "")
        XCTAssertEqual(revealFileURL.path, "/tmp/dir/note.jot")
    }

    func test_toURL_producesSharedDocumentsURL() throws {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/dir/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let result = RevealFileURL(jotFileInfo: info).toURL()

        // Then
        XCTAssertEqual(result.scheme, "shareddocuments")
        XCTAssertEqual(result.path, "/tmp/dir/note.jot")
    }
}
