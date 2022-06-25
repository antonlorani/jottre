import UIKit

extension UIUserInterfaceStyle {

    var string: String {
        switch self {
        case .dark:
            return LocalizableStringsDataSource.shared.getText(identifier: "UserInterfaceStyle.dark")
        case .light:
            return LocalizableStringsDataSource.shared.getText(identifier: "UserInterfaceStyle.light")
        case .unspecified:
            return LocalizableStringsDataSource.shared.getText(identifier: "UserInterfaceStyle.system")
        default:
            return LocalizableStringsDataSource.shared.getText(identifier: "UserInterfaceStyle.system")
        }
    }
}
