import UIKit

protocol BarButtonItemFactory: Sendable {

    func make(primaryAction: UIAction) -> UIBarButtonItem
}
