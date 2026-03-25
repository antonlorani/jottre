import UIKit

class SettingsCell<T: UIView>: UICollectionViewCell {

    static var reuseIdentifier: String {
        "SettingsCell<\(T.self)>"
    }

    let labelContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    let accessoryView: T

    private(set) lazy var nameLabelBottomConstraint = nameLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor)

    override init(frame: CGRect) {
        self.accessoryView = T(frame: .zero)
        super.init(frame: frame)
        setUpViews()
    }

    init(frame: CGRect, accessoryView: T) {
        self.accessoryView = accessoryView
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
        contentView.layer.cornerRadius = DesignTokens.CornerRadius.cell
        contentView.clipsToBounds = true
        contentView.layoutMargins = UIEdgeInsets(top: .zero, left: DesignTokens.Spacing.md, bottom: .zero, right: DesignTokens.Spacing.md)

        accessoryView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(labelContainer)
        labelContainer.addSubview(nameLabel)
        contentView.addSubview(accessoryView)

        NSLayoutConstraint.activate([
            labelContainer.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            labelContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelContainer.trailingAnchor.constraint(lessThanOrEqualTo: accessoryView.leadingAnchor, constant: -DesignTokens.Spacing.xs),

            nameLabel.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),
            nameLabelBottomConstraint,

            accessoryView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            accessoryView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
