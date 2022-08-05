import UIKit
import Combine

final class InfoTextView: UITextView {

    private struct Constants {
        static let font = UIFont.systemFont(ofSize: 25, weight: .regular)
        static let textColor = UIColor.secondaryLabel
        static let backgroundColor = UIColor.clear
    }

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: InfoTextViewModel) {
        super.init(frame: .zero, textContainer: nil)

        setUpViews()
        bindViewModel(viewModel: viewModel)
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

    private func bindViewModel(viewModel: InfoTextViewModel) {
        viewModel
            .infoTextString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] infoTextString in
                self?.text = infoTextString
            }
            .store(in: &cancellables)
    }
}
