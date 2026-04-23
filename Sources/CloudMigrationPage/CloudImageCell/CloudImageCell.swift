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

final class CloudImageCell: UICollectionViewCell, PageCell {
    static let reuseIdentifier = "CloudImageCell"

    private enum Constants {

        static let height = CGFloat(80)
    }

    private let cloudImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.icloud.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = .label
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
        contentView.addSubview(cloudImageView)

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: Constants.height),

            cloudImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            cloudImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            cloudImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            cloudImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        ])
    }

    func configure(
        viewModel: CloudImageCellViewModel
    ) {
        /* no-op */
    }
}
