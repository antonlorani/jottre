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

final class SettingsExternalLinkCell: SettingsCell<UIImageView>, PageCell {

    private enum Constants {

        static let arrowSize = CGFloat(20)
    }

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var withInfoLabelConstraints = [
        infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
        infoLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor),
        infoLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor),
        infoLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor),
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessoryView.image = UIImage(systemName: "arrow.up.forward")
        accessoryView.tintColor = .label
        accessoryView.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            accessoryView.widthAnchor.constraint(equalToConstant: Constants.arrowSize),
            accessoryView.heightAnchor.constraint(equalToConstant: Constants.arrowSize),
        ])
    }

    func configure(viewModel: SettingsExternalLinkCellViewModel) {
        nameLabel.text = viewModel.name
        infoLabel.removeFromSuperview()
        NSLayoutConstraint.deactivate([nameLabelBottomConstraint] + withInfoLabelConstraints)

        if let info = viewModel.info {
            infoLabel.text = info
            labelContainer.addSubview(infoLabel)
            NSLayoutConstraint.activate(withInfoLabelConstraints)
        } else {
            NSLayoutConstraint.activate([nameLabelBottomConstraint])
        }
    }
}
