import UIKit

final class SwitchViewProvider: PreferencesCustomViewProvider {

    private struct Constants {
        static let onTintColor = UIColor.systemBlue
    }

    private lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = Constants.onTintColor
        switchView.addTarget(self, action: #selector(switchDidSelect), for: .valueChanged)
        return switchView
    }()

    private var onClick: ((_ newState: Bool) -> Void)?

    init(
        isOn: Bool,
        isEnabled: Bool,
        onClick: @escaping (_ newState: Bool) -> Void
    ) {
        reuse(isOn: isOn, isEnabled: isEnabled, onClick: onClick)
    }

    func reuse(
        isOn: Bool,
        isEnabled: Bool,
        onClick: @escaping (_ newState: Bool) -> Void
    ) {
        switchView.isOn = isOn
        switchView.isEnabled = isEnabled
        self.onClick = onClick
    }

    func provideView() -> UIView {
        switchView
    }

    func provideViewConstraints(superview: UIView, view: UIView) {
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            superview.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }

    @objc private func switchDidSelect() {
        onClick?(switchView.isOn)
    }
}
