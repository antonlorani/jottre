import UIKit

final class EmptyStateCell: UICollectionViewCell, PageCell {
    static let reuseIdentifier = "EmptyStateCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
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
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
        ])
    }

    func configure(
        viewModel: EmptyStateCellViewModel
    ) {
        titleLabel.text = viewModel.title
    }
}
