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
        return label
    }()

    private let lastEditedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
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
        labelContainer.addSubview(lastEditedDateLabel)
        contentView.addSubview(checkboxImageView)

        NSLayoutConstraint.activate([
            previewImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            previewImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            previewImageView.widthAnchor.constraint(equalToConstant: Constants.Preview.width),

            separatorLine.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor),
            separatorLine.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.widthAnchor.constraint(equalToConstant: DesignTokens.Length.separator),

            labelContainer.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            labelContainer.leadingAnchor.constraint(
                equalTo: separatorLine.trailingAnchor,
                constant: DesignTokens.Spacing.md
            ),
            labelContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelContainer.bottomAnchor
                .constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            labelContainer.trailingAnchor.constraint(
                lessThanOrEqualTo: checkboxImageView.leadingAnchor,
                constant: -DesignTokens.Spacing.xs
            ),

            nameLabel.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),

            lastEditedDateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            lastEditedDateLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
            lastEditedDateLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),
            lastEditedDateLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor),

            checkboxImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            checkboxImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxImageView.widthAnchor.constraint(equalToConstant: Constants.Checbox.size),
            checkboxImageView.heightAnchor.constraint(equalToConstant: Constants.Checbox.size),
        ])
    }

    func configure(viewModel: CloudMigrationJotCellViewModel) {
        previewImageView.image = viewModel.jot.previewImage
        nameLabel.text = viewModel.jot.name
        lastEditedDateLabel.text = viewModel.jot.lastEditedDateString
        checkboxImageView.image = Constants.Checbox.image(isOn: viewModel.jot.isCloudSynchronized)
    }
}
