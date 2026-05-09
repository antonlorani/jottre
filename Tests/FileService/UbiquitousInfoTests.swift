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

final class UbiquitousInfoTests: XCTestCase {

    func test_equality_givenSameValues_returnsEqual() {
        // Given
        let lhs = UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        let rhs = UbiquitousInfo(downloadStatus: .current, isDownloading: false)

        // Then
        XCTAssertEqual(lhs, rhs)
    }

    func test_equality_givenDifferentDownloadStatus_returnsNotEqual() {
        // Given
        let lhs = UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        let rhs = UbiquitousInfo(downloadStatus: .notDownloaded, isDownloading: false)

        // Then
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_equality_givenDifferentIsDownloading_returnsNotEqual() {
        // Given
        let lhs = UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        let rhs = UbiquitousInfo(downloadStatus: .current, isDownloading: true)

        // Then
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_equality_givenNilDownloadStatusOnBoth_returnsEqual() {
        // Given
        let lhs = UbiquitousInfo(downloadStatus: nil, isDownloading: true)
        let rhs = UbiquitousInfo(downloadStatus: nil, isDownloading: true)

        // Then
        XCTAssertEqual(lhs, rhs)
    }
}
