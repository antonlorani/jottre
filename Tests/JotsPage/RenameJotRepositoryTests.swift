import XCTest

@testable import Jottre

final class RenameJotRepositoryTests: XCTestCase {

    func test_rename_forwardsArgumentsToJotFileServiceAndReturnsResult() async throws {
        // Given
        let renameProviderExpectation = XCTestExpectation(description: "JotFileServiceMock.renameProvider is called.")
        let inputInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/old.jot"),
            name: "old",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let expectedRenamedInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/new.jot"),
            name: "new",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let jotFileServiceMock = JotFileServiceMock(
            renameProvider: { receivedInfo, receivedName in
                // Then
                XCTAssertEqual(receivedInfo, inputInfo)
                XCTAssertEqual(receivedName, "new")
                renameProviderExpectation.fulfill()
                return expectedRenamedInfo
            }
        )
        let repository = RenameJotRepository(jotFileService: jotFileServiceMock)

        // When
        let result = try repository.rename(jotFileInfo: inputInfo, newName: "new")

        // Then
        XCTAssertEqual(result, expectedRenamedInfo)
        await fulfillment(of: [renameProviderExpectation], timeout: 0.2)
    }
}
