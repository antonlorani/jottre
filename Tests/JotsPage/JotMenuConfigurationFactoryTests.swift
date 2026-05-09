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

@MainActor
final class JotMenuConfigurationFactoryTests: XCTestCase {

    func test_make_givenNoOpenInNewWindow_producesRenameDuplicateDeleteRevealAndShareGroup() {
        // Given
        let factory = JotMenuConfigurationFactory()

        // When
        let configurations = factory.make(
            onShare: { _, _ in },
            onRename: {},
            onDuplicate: {},
            onDelete: {},
            onShowInFiles: {}
        )
        let resolved = configurations.make(popoverAnchorProvider: { nil })

        // Then
        XCTAssertEqual(resolved.count, 5)
        XCTAssertActionAt(resolved, index: 0, expectedSystemImage: "pencil")
        XCTAssertActionAt(resolved, index: 1, expectedSystemImage: "plus.square.on.square")
        XCTAssertActionAt(resolved, index: 2, expectedSystemImage: "trash", expectedDestructive: true)
        XCTAssertActionAt(resolved, index: 3, expectedSystemImage: "folder")
        XCTAssertGroupAt(resolved, index: 4, expectedActionCount: 3)
    }

    func test_make_givenOpenInNewWindow_prependsOpenInNewWindowAction() {
        // Given
        let factory = JotMenuConfigurationFactory()

        // When
        let configurations = factory.make(
            onShare: { _, _ in },
            onRename: {},
            onDuplicate: {},
            onDelete: {},
            onShowInFiles: {},
            onOpenInNewWindow: {}
        )
        let resolved = configurations.make(popoverAnchorProvider: { nil })

        // Then
        XCTAssertEqual(resolved.count, 6)
        XCTAssertActionAt(resolved, index: 0, expectedSystemImage: "plus.app")
        XCTAssertActionAt(resolved, index: 1, expectedSystemImage: "pencil")
    }

    func test_make_actionHandlers_invokeCorrespondingClosures() async {
        // Given
        let onRenameExpectation = XCTestExpectation(description: "onRename is called.")
        let onDuplicateExpectation = XCTestExpectation(description: "onDuplicate is called.")
        let onDeleteExpectation = XCTestExpectation(description: "onDelete is called.")
        let onShowInFilesExpectation = XCTestExpectation(description: "onShowInFiles is called.")
        let onShareExpectation = XCTestExpectation(description: "onShare is called for each format.")
        onShareExpectation.expectedFulfillmentCount = 3

        let factory = JotMenuConfigurationFactory()

        // When
        let configurations = factory.make(
            onShare: { _, _ in onShareExpectation.fulfill() },
            onRename: { onRenameExpectation.fulfill() },
            onDuplicate: { onDuplicateExpectation.fulfill() },
            onDelete: { onDeleteExpectation.fulfill() },
            onShowInFiles: { onShowInFilesExpectation.fulfill() }
        )
        let resolved = configurations.make(popoverAnchorProvider: { nil })

        invokeAction(resolved[0])
        invokeAction(resolved[1])
        invokeAction(resolved[2])
        invokeAction(resolved[3])
        if case let .group(group) = resolved[4] {
            for action in group.actions {
                action.handler()
            }
        }

        // Then
        await fulfillment(
            of: [
                onRenameExpectation,
                onDuplicateExpectation,
                onDeleteExpectation,
                onShowInFilesExpectation,
                onShareExpectation,
            ],
            timeout: 0.2
        )
    }

    private func invokeAction(_ configuration: JotMenuConfiguration) {
        if case let .action(action) = configuration {
            action.handler()
        } else {
            XCTFail("Expected .action, got \(configuration).")
        }
    }

    private func XCTAssertActionAt(
        _ configurations: [JotMenuConfiguration],
        index: Int,
        expectedSystemImage: String,
        expectedDestructive: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let .action(action) = configurations[index] else {
            XCTFail("Expected .action at index \(index)", file: file, line: line)
            return
        }
        XCTAssertEqual(action.systemImageName, expectedSystemImage, file: file, line: line)
        XCTAssertEqual(action.isDestructive, expectedDestructive, file: file, line: line)
    }

    private func XCTAssertGroupAt(
        _ configurations: [JotMenuConfiguration],
        index: Int,
        expectedActionCount: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let .group(group) = configurations[index] else {
            XCTFail("Expected .group at index \(index)", file: file, line: line)
            return
        }
        XCTAssertEqual(group.actions.count, expectedActionCount, file: file, line: line)
    }
}
