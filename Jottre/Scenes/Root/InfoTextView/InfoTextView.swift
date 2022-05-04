import UIKit

final class InfoTextView: UITextView {

    private struct Constants {
        static let font = UIFont.systemFont(ofSize: 25, weight: .regular)
        static let textColor = UIColor.secondaryLabel
        static let backgroundColor = UIColor.clear
    }

    init(viewModel: InfoTextViewModel) {
        super.init(frame: .zero, textContainer: nil)

        setUpViews(viewModel: viewModel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    private func setUpViews(viewModel: InfoTextViewModel) {
        text = viewModel.text
        isEditable = false
        isSelectable = false
        font = Constants.font
        textColor = Constants.textColor
        textAlignment = .center
        isScrollEnabled = false
        backgroundColor = Constants.backgroundColor
    }
}
