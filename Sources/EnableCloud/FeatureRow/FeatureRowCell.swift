import UIKit

final class FeatureRowCell: UICollectionViewCell {
    static let reuseIdentifier = "FeatureRowCell"

    private enum Constants {
        static let iconSize = CGFloat(28)
        static let padding = CGFloat(16)
        static let cornerRadius = CGFloat(20)
    }

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
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
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.clipsToBounds = true

        contentView.addSubview(iconImageView)
        contentView.addSubview(textLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.padding
            ),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),

            textLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: Constants.padding
            ),
            textLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.padding
            ),
            textLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.padding
            ),
            textLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.padding
            ),
        ])
    }

    func configure(featureRow: FeatureRowBusinessModel) {
        iconImageView.image = UIImage(systemName: featureRow.systemImageName)
        textLabel.text = featureRow.text
    }
}
