import XCTest

@testable import Jottre

final class JotConflictBusinessModelTests: XCTestCase {

    func test_init_givenSavingComputerName_usesAsLastEditedDateString() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let version = JotFileVersion(
            localizedNameOfSavingComputer: "Anton's Mac",
            info: info
        )

        // When
        let model = JotConflictBusinessModel(
            name: "label",
            jotFileInfo: info,
            jotFileVersion: version
        )

        // Then
        XCTAssertEqual(model.name, "label")
        XCTAssertEqual(model.lastEditedDateString, "Anton's Mac")
        XCTAssertEqual(model.jotFileInfo, info)
    }

    func test_init_givenNilSavingComputerName_returnsNotApplicableString() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let version = JotFileVersion(
            localizedNameOfSavingComputer: nil,
            info: info
        )

        // When
        let model = JotConflictBusinessModel(
            name: "label",
            jotFileInfo: info,
            jotFileVersion: version
        )

        // Then
        XCTAssertEqual(model.lastEditedDateString, "n/a")
    }

    func test_toJotFileVersion_returnsOriginalVersion() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let version = JotFileVersion(localizedNameOfSavingComputer: nil, info: info)

        // When
        let model = JotConflictBusinessModel(
            name: "label",
            jotFileInfo: info,
            jotFileVersion: version
        )

        // Then
        XCTAssertEqual(model.toJotFileVersion(), version)
    }
}
