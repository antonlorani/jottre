import UIKit
import Combine

final class InfoTextView: UITextView {

    private struct Constants {
        static let font = UIFont.systemFont(ofSize: 25, weight: .regular)
        static let textColor = UIColor.secondaryLabel
        static let backgroundColor = UIColor.clear
    }

    init(text: String) {
        super.init(frame: .zero, textContainer: nil)
        self.text = text

        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    private func setUpViews() {
        isEditable = false
        isSelectable = false
        font = Constants.font
        textColor = Constants.textColor
        textAlignment = .center
        isScrollEnabled = false
        backgroundColor = Constants.backgroundColor
    }
}
