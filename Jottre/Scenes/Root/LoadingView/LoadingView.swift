import UIKit

final class LoadingView: UIView {

    private struct Constants {
        struct ActivityIndicatorView {
            static let size = CGSize(width: 30, height: 30)
        }
        struct TitleLabel {
            static let font = UIFont.systemFont(ofSize: 18, weight: .medium)
            static let textColor = UIColor.secondaryLabel
        }
    }

    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.TitleLabel.font
        label.textColor = Constants.TitleLabel.textColor
        return label
    }()

    init(title: String, tintColor: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = tintColor
        activityIndicatorView.tintColor = tintColor
        activityIndicatorView.color = tintColor
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
        addSubview(activityIndicatorView)
        addSubview(titleLabel)
    }

    private func setUpContraints() {
        NSLayoutConstraint.activate([
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: Constants.ActivityIndicatorView.size.width),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: Constants.ActivityIndicatorView.size.height)
        ])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: activityIndicatorView.trailingAnchor)
        ])
    }
}
