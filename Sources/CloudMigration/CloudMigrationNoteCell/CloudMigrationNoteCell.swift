import UIKit

final class CloudMigrationNoteCell: UICollectionViewCell, PageCell {
    static let reuseIdentifier = "CloudMigrationNoteCell"

    private enum Constants {

        struct Checbox {
            static let size = CGFloat(30)

            static func image(isOn: Bool) -> UIImage? {
                isOn ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
            }
        }
    }

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    private let lastEditedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
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

    private func setUpViews() {
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true

        contentView.addSubview(previewImageView)
        contentView.addSubview(separatorLine)
        contentView.addSubview(labelContainer)
        labelContainer.addSubview(nameLabel)
        labelContainer.addSubview(lastEditedDateLabel)
        contentView.addSubview(checkboxImageView)

        NSLayoutConstraint.activate([
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            previewImageView.widthAnchor.constraint(equalToConstant: 70),

            separatorLine.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor),
            separatorLine.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.widthAnchor.constraint(equalToConstant: 1),

            labelContainer.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            labelContainer.leadingAnchor.constraint(equalTo: separatorLine.trailingAnchor, constant: 16),
            labelContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelContainer.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            labelContainer.trailingAnchor.constraint(lessThanOrEqualTo: checkboxImageView.leadingAnchor, constant: -8),

            nameLabel.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),

            lastEditedDateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            lastEditedDateLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
            lastEditedDateLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),
            lastEditedDateLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor),

            checkboxImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkboxImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxImageView.widthAnchor.constraint(equalToConstant: Constants.Checbox.size),
            checkboxImageView.heightAnchor.constraint(equalToConstant: Constants.Checbox.size),
        ])
    }

    func configure(viewModel: CloudMigrationNoteCellViewModel) {
        previewImageView.image = viewModel.note.previewImage
        nameLabel.text = viewModel.note.name
        lastEditedDateLabel.text = viewModel.note.lastEditedDateString
        checkboxImageView.image = Constants.Checbox.image(isOn: viewModel.note.isCloudSynchronized)
    }
}
