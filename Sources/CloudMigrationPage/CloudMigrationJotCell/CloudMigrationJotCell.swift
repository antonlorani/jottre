import UIKit

final class CloudMigrationJotCell: UICollectionViewCell, PageCell {
    static let reuseIdentifier = "CloudMigrationJotCell"

    private enum Constants {

        enum Preview {
            static let width = CGFloat(70)
        }

        enum Checbox {
            static let size = CGFloat(30)

            static func image(isOn: Bool) -> UIImage? {
                isOn ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
            }
        }
    }

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    private let labelContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 1
        return label
    }()

    private let infoTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let checkboxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            loadPreviewImage()
        }
    }

    private func setUpViews() {
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = DesignTokens.CornerRadius.cell
        contentView.clipsToBounds = true
        contentView.layoutMargins = UIEdgeInsets(
            top: DesignTokens.Spacing.xs,
            left: DesignTokens.Spacing.xs,
            bottom: DesignTokens.Spacing.xs,
            right: DesignTokens.Spacing.md
        )

        contentView.addSubview(previewImageView)
        contentView.addSubview(separatorLine)
        contentView.addSubview(labelContainer)
        labelContainer.addSubview(nameLabel)
        labelContainer.addSubview(infoTextLabel)
        contentView.addSubview(checkboxImageView)

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 56),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            previewImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            previewImageView.widthAnchor.constraint(equalToConstant: Constants.Preview.width),

            separatorLine.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor),
            separatorLine.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.widthAnchor.constraint(equalToConstant: DesignTokens.Length.separator),

            labelContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelContainer.leadingAnchor.constraint(
                equalTo: separatorLine.trailingAnchor,
                constant: DesignTokens.Spacing.md
            ),
            labelContainer.trailingAnchor.constraint(
                lessThanOrEqualTo: checkboxImageView.leadingAnchor,
                constant: -DesignTokens.Spacing.xs
            ),

            nameLabel.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),

            infoTextLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            infoTextLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
            infoTextLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),
            infoTextLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor),

            checkboxImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            checkboxImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxImageView.widthAnchor.constraint(equalToConstant: Constants.Checbox.size),
            checkboxImageView.heightAnchor.constraint(equalToConstant: Constants.Checbox.size),
        ])
    }

    private var viewModel: CloudMigrationJotCellViewModel?
    private var previewImageTask: Task<Void, Never>?

    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
    }

    func configure(
        viewModel: CloudMigrationJotCellViewModel
    ) {
        self.viewModel = viewModel
        nameLabel.text = viewModel.name
        infoTextLabel.text = viewModel.infoText
        checkboxImageView.image = Constants.Checbox.image(isOn: viewModel.isCloudCheckboxOn)
        loadPreviewImage()
    }

    private func loadPreviewImage() {
        guard let viewModel else {
            return
        }
        previewImageTask?.cancel()
        previewImageTask = Task { [weak self] in
            guard let self else {
                return
            }
            let image = await viewModel.getPreviewImage(userInterfaceStyle: traitCollection.userInterfaceStyle)
            guard !Task.isCancelled else {
                return
            }
            previewImageView.image = image
        }
    }
}
