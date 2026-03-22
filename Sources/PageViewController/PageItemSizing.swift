import UIKit

enum PageItemSizing {

    /// Spans the full available width. Height is self-sizing based on content.
    case fullWidth

    /// Distributes items equally across `perRow` columns at a fixed height.
    ///
    /// Use `perRow: 2` for a side-by-side 50/50 split.
    case equalSplit(perRow: Int, height: CGFloat)

    /// Responsive grid: 1 column in portrait, up to `maxColumns` in landscape, fixed height.
    case adaptiveGrid(maxColumns: Int, height: CGFloat)
}
