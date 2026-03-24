import UIKit

final class PageHeaderCell: UICollectionViewCell, PageCell {
    private struct Constants {

        struct Subheadline {
            static let maxWidth = CGFloat(300)
        }
    }

    static let reuseIdentifier = "PageHeaderCell"

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subheadlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium)
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
            subheadlineLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).withPriority(.defaultHigh),
            subheadlineLabel.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.Subheadline.maxWidth),
            subheadlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            subheadlineLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: attributes.frame.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        attributes.frame.size.height = size.height
        return attributes
    }

    func configure(viewModel: PageHeaderCellViewModel) {
        headlineLabel.text = viewModel.headline
        subheadlineLabel.text = viewModel.subheadline
    }
}
