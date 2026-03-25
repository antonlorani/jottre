/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import UIKit

final class FeatureRowCell: UICollectionViewCell, PageCell {
    static let reuseIdentifier = "FeatureRowCell"

    private enum Constants {

        enum Icon {
            static let size = CGFloat(28)
        }
    }

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    private func setUpViews() {
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = DesignTokens.CornerRadius.cell
        contentView.clipsToBounds = true

        contentView.addSubview(iconImageView)
        contentView.addSubview(textLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: DesignTokens.Spacing.md
            ),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.Icon.size),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.Icon.size),

            textLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: DesignTokens.Spacing.md
            ),
            textLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -DesignTokens.Spacing.md
            ),
            textLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: DesignTokens.Spacing.md
            ),
            textLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -DesignTokens.Spacing.md
            ),
        ])
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: attributes.frame.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        attributes.frame.size.height = size.height
        return attributes
    }

    func configure(viewModel: FeatureRowCellViewModel) {
        iconImageView.image = UIImage(systemName: viewModel.systemImageName)
        textLabel.text = viewModel.text
    }
}
