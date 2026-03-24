import UIKit

final class NoteCell: UICollectionViewCell, PageCell {
    static let reuseIdentifier = "NoteCell"

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.separator
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body, weight: .semibold)
        return label
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var withInfoLabelConstraints = [
        infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
        infoLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
        infoLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        infoLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
    ]

    private lazy var withoutInfoLabelConstraints = [
        nameLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
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
        contentView.layer.cornerRadius = DesignTokens.CornerRadius.cell
        contentView.clipsToBounds = true
        contentView.layoutMargins = UIEdgeInsets(
            top: DesignTokens.Spacing.xs,
            left: DesignTokens.Spacing.xs,
            bottom: DesignTokens.Spacing.sm,
            right: DesignTokens.Spacing.xs
        )

        contentView.addSubview(previewImageView)
        contentView.addSubview(separatorLine)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: separatorLine.topAnchor),

            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: DesignTokens.Length.separator),

            nameLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: DesignTokens.Spacing.sm),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ] + withoutInfoLabelConstraints)
    }

    func configure(
        viewModel: NoteCellViewModel
    ) {
        previewImageView.image = viewModel.note.previewImage
        nameLabel.text = viewModel.note.name

        infoLabel.removeFromSuperview()
        NSLayoutConstraint.deactivate(withInfoLabelConstraints + withoutInfoLabelConstraints)

        if let infoText = viewModel.infoText {
            infoLabel.text = infoText
            contentView.addSubview(infoLabel)
            NSLayoutConstraint.activate(withInfoLabelConstraints)
        } else {
            NSLayoutConstraint.activate(withoutInfoLabelConstraints)
        }
    }
}
