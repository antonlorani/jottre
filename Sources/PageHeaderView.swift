import UIKit

final class PageHeaderView: UIView {

    struct Configuration {
        let headline: String
        let subheadline: String
    }

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = {
            let font = UIFont.preferredFont(forTextStyle: .largeTitle)
            return UIFont.boldSystemFont(ofSize: font.pointSize)
        }()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subheadlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = {
            let font = UIFont.preferredFont(forTextStyle: .subheadline)
            return UIFont.boldSystemFont(ofSize: font.pointSize)
        }()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    init(configuration: Configuration) {
        super.init(frame: .zero)
        headlineLabel.text = configuration.headline
        subheadlineLabel.text = configuration.subheadline
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    private func setUpViews() {
        addSubview(headlineLabel)
        addSubview(subheadlineLabel)

        NSLayoutConstraint.activate([
            headlineLabel.topAnchor.constraint(equalTo: topAnchor),
            headlineLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            headlineLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            subheadlineLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            subheadlineLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            subheadlineLabel.centerXAnchor.constraint(equalTo: centerXAnchor).withPriority(.defaultHigh),
            subheadlineLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            subheadlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            subheadlineLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
