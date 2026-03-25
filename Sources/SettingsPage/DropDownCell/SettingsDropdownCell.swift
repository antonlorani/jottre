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
