import UIKit

extension UIMenu {

    static func make(noteMenuConfigurations: [NoteMenuConfiguration]) -> UIMenu {
        UIMenu(children: noteMenuConfigurations.map { configuration in
            switch configuration {
            case let .action(action):
                return UIAction(
                    title: action.title,
                    image: UIImage(systemName: action.systemImageName),
                    attributes: action.isDestructive ? .destructive : []
                ) { _ in action.handler() }
            case let .group(group):
                return UIMenu(
                    title: group.title,
                    image: UIImage(systemName: group.systemImageName),
                    children: group.actions.map { action in
                        UIAction(
                            title: action.title,
                            image: UIImage(systemName: action.systemImageName),
                            attributes: action.isDestructive ? .destructive : []
                        ) { _ in action.handler() }
                    }
                )
            }
        })
    }
}
