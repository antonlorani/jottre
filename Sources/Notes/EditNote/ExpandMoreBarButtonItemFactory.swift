import UIKit

struct IOS18ExpandMoreBarButtonItemFactory: BarButtonItemFactory {

    func make(primaryAction: UIAction) -> UIBarButtonItem {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "ellipsis.circle.fill")?
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
struct IOS26ExpandMoreBarButtonItemFactory: BarButtonItemFactory {

    func make(primaryAction: UIAction) -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            primaryAction: primaryAction
        )
    }
}
