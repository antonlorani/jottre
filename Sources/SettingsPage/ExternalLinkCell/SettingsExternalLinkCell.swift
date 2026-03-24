import UIKit

final class SettingsExternalLinkCell: UICollectionViewCell, PageCell {

    private enum Constants {

        struct ArrowImage {
            static let size = CGFloat(20)
        }
    }

    static let reuseIdentifier = "SettingsExternalLinkCell"

    private let labelContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "arrow.up.forward")
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var withInfoLabelConstraints = [
        infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
        infoLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
        infoLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),
        infoLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor),
    ]

    private lazy var withoutInfoLabelConstraints = [
        nameLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor)
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }

    private func setUpViews() {
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true

        contentView.addSubview(labelContainer)
        labelContainer.addSubview(nameLabel)
        contentView.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            labelContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelContainer.trailingAnchor.constraint(lessThanOrEqualTo: arrowImageView.leadingAnchor, constant: -8),

            nameLabel.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),

            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: Constants.ArrowImage.size),
            arrowImageView.heightAnchor.constraint(equalToConstant: Constants.ArrowImage.size),
        ] + withoutInfoLabelConstraints)
    }

    func configure(viewModel: SettingsExternalLinkCellViewModel) {
        nameLabel.text = viewModel.name

        infoLabel.removeFromSuperview()
        NSLayoutConstraint.deactivate(withoutInfoLabelConstraints + withInfoLabelConstraints)

        if let info = viewModel.info {
            infoLabel.text = info
            labelContainer.addSubview(infoLabel)
            NSLayoutConstraint.activate(withInfoLabelConstraints)
        } else {
            NSLayoutConstraint.activate(withoutInfoLabelConstraints)
        }
    }
}
