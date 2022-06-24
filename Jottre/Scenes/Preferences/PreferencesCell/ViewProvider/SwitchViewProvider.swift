import UIKit

final class SwitchViewProvider: PreferencesCustomViewProvider {

    private struct Constants {
        static let onTintColor = UIColor.systemBlue
    }

    private let isOn: Bool
    private let isEnabled: Bool
    private let onClick: (_ newState: Bool) -> Void

    init(
        isOn: Bool,
        isEnabled: Bool,
        onClick: @escaping (_ newState: Bool) -> Void
    ) {
        self.isOn = isOn
        self.isEnabled = isEnabled
        self.onClick = onClick
    }

    func provideView() -> UIView {
        let switchView = UISwitch()
        switchView.isOn = isOn
        switchView.isEnabled = isEnabled
        switchView.onTintColor = Constants.onTintColor
        switchView.addTarget(self, action: #selector(switchDidSelect(_:)), for: .valueChanged)
        return switchView
    }

    func provideViewConstraints(superview: UIView, view: UIView) {
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            superview.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }

    @objc private func switchDidSelect(_ sender: UISwitch) {
        onClick(sender.isOn)
    }
}
