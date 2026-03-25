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

final class SettingsDropdownCell: SettingsCell<UIButton>, PageCell {

    override init(frame: CGRect) {
        super.init(frame: frame, accessoryView: UIButton(type: .system))
        accessoryView.showsMenuAsPrimaryAction = true
        accessoryView.titleLabel?.font = .preferredFont(forTextStyle: .body, weight: .semibold)
        accessoryView.setTitleColor(.label, for: .normal)
    }

    func configure(viewModel: SettingsDropdownCellViewModel) {
        nameLabel.text = viewModel.name
        accessoryView.setTitle(viewModel.current.label, for: .normal)
        accessoryView.menu = UIMenu(
            children: viewModel.options.map { option in
                UIAction(
                    title: option.label,
                    state: AnyHashable(option.value.hashValue) == AnyHashable(viewModel.current.value) ? .on : .off
                ) { _ in
                    viewModel.onAction(option)
                }
            }
        )
    }
}
