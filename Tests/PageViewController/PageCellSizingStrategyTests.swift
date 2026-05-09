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

final class PageCellSizingStrategyTests: XCTestCase {

    func test_columnSpacing_givenFullWidth_isZero() {
        // Given
        let strategy = PageCellSizingStrategy.fullWidth()

        // Then
        XCTAssertEqual(strategy.columnSpacing, .zero)
    }

    func test_columnSpacing_givenEqualSplit_returnsConfiguredColumnSpacing() {
        // Given
        let strategy = PageCellSizingStrategy.equalSplit(
            perRow: 2,
            itemHeight: 100,
            columnSpacing: 12,
            rowSpacing: 8
        )

        // Then
        XCTAssertEqual(strategy.columnSpacing, 12)
    }

    func test_rowSpacing_givenEqualSplit_returnsConfiguredRowSpacing() {
        // Given
        let strategy = PageCellSizingStrategy.equalSplit(
            perRow: 2,
            itemHeight: 100,
            columnSpacing: 12,
            rowSpacing: 8
        )

        // Then
        XCTAssertEqual(strategy.rowSpacing, 8)
    }

    func test_columnAndRowSpacing_givenAdaptiveGrid_returnsConfiguredSpacings() {
        // Given
        let strategy = PageCellSizingStrategy.adaptiveGrid(
            minColumns: 2,
            maxColumns: 8,
            minItemWidth: 100,
            maxItemWidth: 200,
            columnSpacing: 16,
            rowSpacing: 24,
            aspectRatio: CGSize(width: 1, height: 1)
        )

        // Then
        XCTAssertEqual(strategy.columnSpacing, 16)
        XCTAssertEqual(strategy.rowSpacing, 24)
    }

    func test_rowSpacing_givenFullWidthWithDefaultRowSpacing_returnsDefault() {
        // Given
        let strategy = PageCellSizingStrategy.fullWidth(estimatedHeight: 120, rowSpacing: 7)

        // Then
        XCTAssertEqual(strategy.rowSpacing, 7)
    }
}
