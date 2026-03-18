import UIKit

protocol ExpandMoreMenuBarButtonItemFactory: Sendable {

    func make(menu: UIMenu) -> UIBarButtonItem
}

struct IOS18ExpandMoreMenuBarButtonItemFactory: ExpandMoreMenuBarButtonItemFactory {

    func make(menu: UIMenu) -> UIBarButtonItem {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "ellipsis.circle.fill")?
            .withTintColor(.systemBackground, renderingMode: .alwaysOriginal)
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .medium
        let button = UIButton(configuration: configuration)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        return UIBarButtonItem(customView: button)
    }
}

@available(iOS 26, *)
struct IOS26ExpandMoreMenuBarButtonItemFactory: ExpandMoreMenuBarButtonItemFactory {

    func make(menu: UIMenu) -> UIBarButtonItem {
        UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
    }
}
