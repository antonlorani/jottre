import UIKit

enum PageCellSizingStrategy: Sendable, Hashable {
    case fullWidth(estimatedHeight: CGFloat = 120)
    case equalSplit(perRow: Int, itemHeight: CGFloat)
    case adaptiveGrid(maxColumns: Int, minItemWidth: CGFloat, itemHeight: CGFloat)
}
