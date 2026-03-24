import UIKit

final class SettingsToggleCell: SettingsCell<UISwitch>, PageCell {

    func configure(viewModel: SettingsToggleCellViewModel) {
        nameLabel.text = viewModel.name
        accessoryView.isOn = viewModel.isOn
    }
}
