import UIKit

final class TextViewProvider: PreferencesCustomViewProvider {

    private struct Constants {
        static let textColor = UIColor.secondaryLabel
        static let font = UIFont.systemFont(ofSize: 20)
        static let textAlignment = NSTextAlignment.right
    }

    private let text: String

    init(text: String) {
        self.text = text
    }

    func provideView() -> UIView {
        let label = UILabel()
        label.text = text
        label.textColor = Constants.textColor
        label.font = Constants.font
        label.textAlignment = Constants.textAlignment
        return label
    }

    func provideViewConstraints(superview: UIView, view: UIView) {
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            view.heightAnchor.constraint(equalTo: superview.heightAnchor)
        ])
    }
}
