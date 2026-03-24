import UIKit

enum PageItemSizing {
    case fullWidth
    case equalSplit(perRow: Int, height: CGFloat)
    case adaptiveGrid(maxColumns: Int, height: CGFloat)
}
