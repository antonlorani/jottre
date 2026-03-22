import UIKit

enum PrimaryBarButtonAction: Sendable {
    case action(UIAction)
    case menu(UIMenu)
}

protocol SymbolBarButtonItemFactory: Sendable {

    func make(
        symbolName: String,
        primaryAction: PrimaryBarButtonAction
    ) -> UIBarButtonItem
}

struct IOS18SymbolBarButtonItemFactory: SymbolBarButtonItemFactory {

    func make(
        symbolName: String,
        primaryAction: PrimaryBarButtonAction
    ) -> UIBarButtonItem {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: symbolName)?
            .withTintColor(.systemBackground, renderingMode: .alwaysOriginal)
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .medium

        switch primaryAction {
        case let .action(action):
            return UIBarButtonItem(
                customView: UIButton(
                    configuration: configuration,
                    primaryAction: action
                )
            )
        case let .menu(menu):
            let button = UIButton(configuration: configuration)
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
            return UIBarButtonItem(customView: button)
        }
    }
}

@available(iOS 26, *)
struct IOS26SymbolBarButtonItemFactory: SymbolBarButtonItemFactory {

    func make(
        symbolName: String,
        primaryAction: PrimaryBarButtonAction
    ) -> UIBarButtonItem {
        let image = UIImage(systemName: symbolName)
        return switch primaryAction {
        case let .action(action):
            UIBarButtonItem(image: image, primaryAction: action)
        case let .menu(menu):
            UIBarButtonItem(image: image, menu: menu)
        }
    }
}
