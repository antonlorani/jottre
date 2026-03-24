import UIKit

final class SettingsInfoCell: UICollectionViewCell, PageCell {

    static let reuseIdentifier = "SettingsInfoCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .right
        label.textColor = .secondaryLabel
        return label
    }()

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
        contentView.layoutMargins = UIEdgeInsets(
            top: .zero,
            left: 16,
            bottom: .zero,
            right: 16
        )

        contentView.addSubview(nameLabel)
        contentView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -8),

            valueLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(viewModel: SettingsInfoCellViewModel) {
        nameLabel.text = viewModel.name
        valueLabel.text = viewModel.value
    }
}
