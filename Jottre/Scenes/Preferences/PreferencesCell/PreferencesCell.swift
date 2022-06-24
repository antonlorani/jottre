import UIKit

final class PreferencesCell: UITableViewCell {

    private struct Constants {
        static let backgroundColor = UIColor.secondarySystemBackground
        static let cornerRadius = CGFloat(10)

        struct Card {
            static let spacing = CGFloat(10)
            static let paddingHorizontal = CGFloat(20)
        }

        struct CustomContentView {
            static let paddingTrailing = CGFloat(10)
        }

        struct TitleLabel {
            static let font = UIFont.systemFont(ofSize: 19, weight: .bold)
            static let padding = (horizontal: CGFloat(10), vertical: CGFloat(15))
        }
    }

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.backgroundColor
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.TitleLabel.font
        return label
    }()

    private let customContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpViews()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        customContentView.subviews.forEach { $0.removeFromSuperview() }
    }

    func configure(
        title: String,
        customViewProvider: PreferencesCustomViewProvider
    ) {
        titleLabel.text = title
        setUpCustomContentView(customViewProvider: customViewProvider)
    }

    private func setUpViews() {
        selectionStyle = .none

        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(customContentView)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Card.spacing),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Card.paddingHorizontal),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Card.paddingHorizontal),
            contentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: Constants.TitleLabel.padding.vertical
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Constants.TitleLabel.padding.horizontal
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -Constants.TitleLabel.padding.vertical
            )
        ])
        NSLayoutConstraint.activate([
            customContentView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            customContentView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Constants.CustomContentView.paddingTrailing),
            customContentView.topAnchor.constraint(equalTo: cardView.topAnchor),
            customContentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }

    private func setUpCustomContentView(
        customViewProvider: PreferencesCustomViewProvider
    ) {
        let newCustomView = customViewProvider.provideView()
        newCustomView.translatesAutoresizingMaskIntoConstraints = false
        customContentView.addSubview(newCustomView)
        customViewProvider.provideViewConstraints(superview: customContentView, view: newCustomView)
    }
}
