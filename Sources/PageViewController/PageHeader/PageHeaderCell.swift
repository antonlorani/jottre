import UIKit

final class PageHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "PageHeaderCell"

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

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    private func setUpViews() {
        contentView.addSubview(headlineLabel)
        contentView.addSubview(subheadlineLabel)

        NSLayoutConstraint.activate([
            headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            headlineLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            headlineLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            subheadlineLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            subheadlineLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.leadingAnchor),
            subheadlineLabel.centerXAnchor.constraint(equalTo: centerXAnchor).withPriority(.defaultHigh),
            subheadlineLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            subheadlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            subheadlineLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    func configure(pageHeader: PageHeaderBusinessModel) {
        headlineLabel.text = pageHeader.headline
        subheadlineLabel.text = pageHeader.subheadline
    }
}
