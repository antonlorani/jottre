import UIKit

final class SettingsInfoCell: SettingsCell<UILabel>, PageCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessoryView.font = .preferredFont(forTextStyle: .body)
        accessoryView.textAlignment = .right
        accessoryView.textColor = .secondaryLabel
    }

    func configure(viewModel: SettingsInfoCellViewModel) {
        nameLabel.text = viewModel.name
        accessoryView.text = viewModel.value
    }
}
