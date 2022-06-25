import UIKit

enum CustomUserInterfaceStyle: Int {
    case dark=0,
         light=1,
         system=2

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return .unspecified
        }
    }

    var string: String {
        switch self {
        case .dark:
            return LocalizableStringsDataSource.shared.getText(identifier: "UserInterfaceStyle.dark")
        case .light:
            return LocalizableStringsDataSource.shared.getText(identifier: "UserInterfaceStyle.light")
        case .system:
            return LocalizableStringsDataSource.shared.getText(identifier: "UserInterfaceStyle.system")
        }
    }
}
