/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

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
