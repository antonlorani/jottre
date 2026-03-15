import UIKit

struct IOS18CreateNoteBarButtonItemFactory: BarButtonItemFactory {

    func make(primaryAction: UIAction) -> UIBarButtonItem {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Create"
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
struct IOS26CreateNoteBarButtonItemFactory: BarButtonItemFactory {

    func make(primaryAction: UIAction) -> UIBarButtonItem {
        UIBarButtonItem(
            title: "Create",
            primaryAction: primaryAction
        )
    }
}
