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

final class SettingsDropdownCellViewModel: PageCellViewModel {

    let name: String
    let current: SettingsDropdownBusinessModel.Option
    let options: [SettingsDropdownBusinessModel.Option]
    let onAction: @Sendable (SettingsDropdownBusinessModel.Option) -> Void

    init(
        settingsDropdown: SettingsDropdownBusinessModel,
        onAction: @Sendable @escaping (SettingsDropdownBusinessModel.Option) -> Void
    ) {
        self.name = settingsDropdown.name
        self.current = settingsDropdown.current
        self.options = settingsDropdown.options
        self.onAction = onAction
    }

    func handle(action: PageCellAction) {
        /* no-op */
    }
}
