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

import UIKit

enum PageCellSizingStrategy: Sendable, Hashable {
    case fullWidth(
        estimatedHeight: CGFloat = 120,
        rowSpacing: CGFloat = DesignTokens.Spacing.xs
    )
    case equalSplit(
        perRow: Int,
        itemHeight: CGFloat,
        columnSpacing: CGFloat = DesignTokens.Spacing.sm,
        rowSpacing: CGFloat = DesignTokens.Spacing.sm
    )
    case adaptiveGrid(
        minColumns: Int,
        maxColumns: Int,
        minItemWidth: CGFloat,
        maxItemWidth: CGFloat,
        columnSpacing: CGFloat,
        rowSpacing: CGFloat,
        aspectRatio: CGSize
    )

    var columnSpacing: CGFloat {
        switch self {
        case .fullWidth:
            return .zero
        case let .equalSplit(_, _, columnSpacing, _):
            return columnSpacing
        case let .adaptiveGrid(_, _, _, _, columnSpacing, _, _):
            return columnSpacing
        }
    }

    var rowSpacing: CGFloat {
        switch self {
        case let .fullWidth(_, rowSpacing):
            return rowSpacing
        case let .equalSplit(_, _, _, rowSpacing):
            return rowSpacing
        case let .adaptiveGrid(_, _, _, _, _, rowSpacing, _):
            return rowSpacing
        }
    }
}
