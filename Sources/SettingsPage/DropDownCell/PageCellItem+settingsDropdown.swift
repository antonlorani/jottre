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

extension PageCellItem {

    @MainActor
    static func settingsDropdown(
        name: String,
        current: SettingsDropdownBusinessModel.Option,
        options: [SettingsDropdownBusinessModel.Option],
        onAction: @Sendable @escaping (SettingsDropdownBusinessModel.Option) -> Void
    ) -> PageCellItem {
        PageCellItem(
            id: name,
            cellType: SettingsDropdownCell.self,
            sizing: .fullWidth(estimatedHeight: 56),
            viewModel: SettingsDropdownCellViewModel(
                name: name,
                current: current,
                options: options,
                onAction: onAction
            )
        )
    }
}
