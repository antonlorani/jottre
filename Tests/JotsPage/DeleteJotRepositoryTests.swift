import XCTest

@testable import Jottre

final class DeleteJotRepositoryTests: XCTestCase {

    func test_deleteJot_forwardsToJotFileServiceRemove() async throws {
        // Given
        let removeProviderExpectation = XCTestExpectation(description: "JotFileServiceMock.removeProvider is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let jotFileServiceMock = JotFileServiceMock(
            removeProvider: { receivedInfo in
                // Then
                XCTAssertEqual(receivedInfo, info)
                removeProviderExpectation.fulfill()
            }
        )
        let repository = DeleteJotRepository(jotFileService: jotFileServiceMock)

        // When
        try repository.deleteJot(jotFileInfo: info)

        // Then
        await fulfillment(of: [removeProviderExpectation], timeout: 0.2)
    }
}
