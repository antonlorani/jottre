import UIKit

struct IOS18SettingsBarButtonItemFactory: BarButtonItemFactory {

    func make(primaryAction: UIAction) -> UIBarButtonItem {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "gear")?
            .withTintColor(.systemBackground, renderingMode: .alwaysOriginal)
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
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
struct IOS26SettingsBarButtonItemFactory: BarButtonItemFactory {

    func make(primaryAction: UIAction) -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            primaryAction: primaryAction
        )
    }
}
