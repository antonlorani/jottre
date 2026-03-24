import UIKit

final class SettingsDropdownCell: UICollectionViewCell, PageCell {

    static let reuseIdentifier = "SettingsDropdownCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    private let dropdownButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.titleLabel?.font = .preferredFont(forTextStyle: .body, weight: .semibold)
        button.setTitleColor(.label, for: .normal)
        return button
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

        contentView.addSubview(nameLabel)
        contentView.addSubview(dropdownButton)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: dropdownButton.leadingAnchor, constant: -8),

            dropdownButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dropdownButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(viewModel: SettingsDropdownCellViewModel) {
        nameLabel.text = viewModel.name
        dropdownButton.setTitle(viewModel.current.label, for: .normal)
        dropdownButton.menu = UIMenu(
            children: viewModel.options.map { option in
                UIAction(
                    title: option.label,
                    state: AnyHashable(option.value.hashValue) == AnyHashable(viewModel.current.value) ? .on : .off
                ) { _ in
                    viewModel.onAction(option)
                }
            }
        )
    }
}
