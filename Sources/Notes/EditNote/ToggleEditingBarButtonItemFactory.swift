import UIKit

protocol ToggleEditingBarButtonItemFactory: Sendable {

    func make(
        primaryAction: UIAction,
        isOn: Bool
    ) -> UIBarButtonItem
}

struct IOS18ToggleEditingBarButtonItemFactory: ToggleEditingBarButtonItemFactory {

    func make(
        primaryAction: UIAction,
        isOn: Bool
    ) -> UIBarButtonItem {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: isOn ? "pencil.tip.crop.circle.fill" : "pencil.tip.crop.circle" )?
            .withTintColor(.systemBackground, renderingMode: .alwaysOriginal)
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .medium
        return UIBarButtonItem(
            customView: UIButton(
                configuration: configuration,
                primaryAction: primaryAction
            )
        )
    }
}

@available(iOS 26, *)
struct IOS26ToggleEditingBarButtonItemFactory: ToggleEditingBarButtonItemFactory {

    func make(
        primaryAction: UIAction,
        isOn: Bool
    ) -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: isOn ? "pencil.tip.crop.circle.fill" : "pencil.tip.crop.circle"),
            primaryAction: primaryAction
        )
    }
}
