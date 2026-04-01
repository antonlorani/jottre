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

final class JotCell: UICollectionViewCell, PageCell {
    static let reuseIdentifier = "JotCell"

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
        view.backgroundColor = UIColor.separator
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        #if targetEnvironment(macCatalyst)
        label.font = .preferredFont(forTextStyle: .body, weight: .semibold)
        #else
        label.font = .preferredFont(forTextStyle: .caption1, weight: .semibold)
        #endif
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
            bottom: DesignTokens.Spacing.sm,
            right: DesignTokens.Spacing.xs
        )

        contentView.addSubview(previewImageView)
        contentView.addSubview(separatorLine)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate(
            [
                previewImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                previewImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                previewImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                previewImageView.bottomAnchor.constraint(equalTo: separatorLine.topAnchor),

                separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                separatorLine.heightAnchor.constraint(equalToConstant: DesignTokens.Length.separator),

                nameLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: DesignTokens.Spacing.sm),
                nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                nameLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                nameLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            ]
        )
    }

    private var viewModel: JotCellViewModel?
    private var previewImageTask: Task<Void, Never>?

    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
    }

    func configure(
        viewModel: JotCellViewModel
    ) {
        self.viewModel = viewModel
        nameLabel.text = viewModel.name
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
            previewImageView.image = await viewModel.getPreviewImage(
                userInterfaceStyle: traitCollection.userInterfaceStyle,
                displayScale: traitCollection.displayScale
            )
        }
    }
}
