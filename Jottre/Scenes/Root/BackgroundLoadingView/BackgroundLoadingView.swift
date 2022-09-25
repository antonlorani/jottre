import UIKit

final class BackgroundLoadingView: UIView {

    private struct Constants {
        static let cornerRadius = CGFloat(15)
        static let backgroundColor = UIColor.darkGray.withAlphaComponent(0.9)
        static let contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 10)
    }

    private let loadingViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        view.backgroundColor = Constants.backgroundColor
        return view
    }()

    private lazy var loadingView: LoadingView = {
        let view = LoadingView(title: title, tintColor: .white)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let title: String
    init(title: String) {
        self.title = title
        super.init(frame: .zero)

        setUpViews()
        setUpContraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
        return nil
    }

    private func setUpViews() {
        addSubview(loadingViewContainer)
        addSubview(loadingView)
    }

    private func setUpContraints() {
        NSLayoutConstraint.activate([
            loadingViewContainer.topAnchor.constraint(equalTo: topAnchor),
            loadingViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: loadingViewContainer.topAnchor, constant: Constants.contentInset.top),
            loadingView.leadingAnchor.constraint(equalTo: loadingViewContainer.leadingAnchor, constant: Constants.contentInset.left),
            loadingView.trailingAnchor.constraint(equalTo: loadingViewContainer.trailingAnchor, constant: -Constants.contentInset.right),
            loadingView.bottomAnchor.constraint(equalTo: loadingViewContainer.bottomAnchor, constant: -Constants.contentInset.bottom),
        ])
    }
}
