import UIKit

extension UIFont {

    static func preferredFont(
        forTextStyle style: TextStyle,
        weight: Weight
    ) -> UIFont {
        let size = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style).pointSize
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: base)
    }
}
