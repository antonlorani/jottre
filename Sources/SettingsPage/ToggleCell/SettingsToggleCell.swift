import UIKit

final class SettingsToggleCell: UICollectionViewCell, PageCell {

    static let reuseIdentifier = "SettingsToggleCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    private let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
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
        contentView.addSubview(toggle)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -8),

            toggle.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(viewModel: SettingsToggleCellViewModel) {
        nameLabel.text = viewModel.name
        toggle.isOn = viewModel.isOn
    }
}
