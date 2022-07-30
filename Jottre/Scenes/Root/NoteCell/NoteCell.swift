import UIKit

final class NoteCell: UICollectionViewCell {

    private struct Constants {
        static let cornerRadius = CGFloat(20)

        struct Title {
            static let font = UIFont.systemFont(ofSize: 19, weight: .bold)
            static let contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        }

        struct TitleContainer {
            static let backgroundColor = UIColor.systemGray5
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Title.font
        label.numberOfLines = 2
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.TitleContainer.backgroundColor
        return view
    }()

    func configure(title: String, image: UIImage) {
        titleLabel.text = title
        imageView.image = image
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        titleLabel.text = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpViews()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    private func setUpViews() {
        backgroundColor = UIColor.secondarySystemBackground
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(titleContainer)
        titleContainer.addSubview(titleLabel)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleContainer.topAnchor)
        ])
        NSLayoutConstraint.activate([
            titleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: Constants.Title.contentInset.top),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: Constants.Title.contentInset.top),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -Constants.Title.contentInset.top),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: -Constants.Title.contentInset.top)
        ])
    }
}
