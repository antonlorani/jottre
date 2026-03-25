import UIKit

@MainActor
protocol TextBarButtonItemFactory: Sendable {

    func make(
        title: String,
        primaryAction: UIAction
    ) -> UIBarButtonItem
}

struct IOS18TextBarButtonItemFactory: TextBarButtonItemFactory {

    func make(
        title: String,
        primaryAction: UIAction
    ) -> UIBarButtonItem {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
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
struct IOS26TextBarButtonItemFactory: TextBarButtonItemFactory {

    func make(
        title: String,
        primaryAction: UIAction
    ) -> UIBarButtonItem {
        UIBarButtonItem(
            title: title,
            primaryAction: primaryAction
        )
    }
}
