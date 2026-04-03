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

    private enum Constants {

        enum CloudIconImage {
            static let size = CGFloat(60)
        }
    }

    static let reuseIdentifier = "JotCell"

    private let previewLayoutGuide = UILayoutGuide()

    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var cloudIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "icloud.and.arrow.down.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    private lazy var downloadActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
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
        label.textAlignment = .center
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

        if traitCollection.hasRenderingChange(comparedTo: previousTraitCollection) {
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

        contentView.addLayoutGuide(previewLayoutGuide)
        contentView.addSubview(separatorLine)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate(
            [
                previewLayoutGuide.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                previewLayoutGuide.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                previewLayoutGuide.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                previewLayoutGuide.bottomAnchor.constraint(equalTo: separatorLine.topAnchor),

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
        viewModel = nil
        previewImageTask?.cancel()
        previewImageView.image = nil
        previewImageView.removeFromSuperview()
        cloudIconImageView.removeFromSuperview()
        downloadActivityIndicator.stopAnimating()
        downloadActivityIndicator.removeFromSuperview()
    }

    func configure(
        viewModel: JotCellViewModel
    ) {
        self.viewModel = viewModel
        nameLabel.text = viewModel.name

        loadPreviewImage()
    }

    private func loadPreviewImage() {
        previewImageTask?.cancel()
        previewImageView.image = nil
        previewImageView.removeFromSuperview()
        cloudIconImageView.removeFromSuperview()
        downloadActivityIndicator.stopAnimating()
        downloadActivityIndicator.removeFromSuperview()

        guard let viewModel else {
            return
        }

        switch viewModel.preview {
        case .thumbnail:
            contentView.addSubview(previewImageView)
            NSLayoutConstraint.activate([
                previewImageView.topAnchor.constraint(equalTo: previewLayoutGuide.topAnchor),
                previewImageView.leadingAnchor.constraint(equalTo: previewLayoutGuide.leadingAnchor),
                previewImageView.trailingAnchor.constraint(equalTo: previewLayoutGuide.trailingAnchor),
                previewImageView.bottomAnchor.constraint(equalTo: previewLayoutGuide.bottomAnchor),
            ])
            previewImageTask = Task { [weak self] in
                guard let self else {
                    return
                }
                previewImageView.image = await viewModel.getPreviewImage(
                    userInterfaceStyle: traitCollection.userInterfaceStyle,
                    displayScale: traitCollection.displayScale
                )
            }
        case .cloudImage:
            contentView.addSubview(cloudIconImageView)
            NSLayoutConstraint.activate([
                cloudIconImageView.centerXAnchor.constraint(equalTo: previewLayoutGuide.centerXAnchor),
                cloudIconImageView.centerYAnchor.constraint(equalTo: previewLayoutGuide.centerYAnchor),
                cloudIconImageView.widthAnchor.constraint(equalToConstant: Constants.CloudIconImage.size),
                cloudIconImageView.heightAnchor.constraint(equalToConstant: Constants.CloudIconImage.size),
            ])
        case .loadingIndicator:
            contentView.addSubview(cloudIconImageView)
            NSLayoutConstraint.activate([
                cloudIconImageView.centerXAnchor.constraint(equalTo: previewLayoutGuide.centerXAnchor),
                cloudIconImageView.centerYAnchor.constraint(equalTo: previewLayoutGuide.centerYAnchor),
                cloudIconImageView.widthAnchor.constraint(equalToConstant: Constants.CloudIconImage.size),
                cloudIconImageView.heightAnchor.constraint(equalToConstant: Constants.CloudIconImage.size),
            ])
            contentView.addSubview(downloadActivityIndicator)
            NSLayoutConstraint.activate([
                downloadActivityIndicator.centerXAnchor.constraint(equalTo: previewLayoutGuide.centerXAnchor),
                downloadActivityIndicator.topAnchor.constraint(
                    equalTo: cloudIconImageView.bottomAnchor,
                    constant: DesignTokens.Spacing.sm
                ),
            ])
            downloadActivityIndicator.startAnimating()
        }
    }
}
