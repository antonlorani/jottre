import UIKit

extension UITableView {

    func register<C: UITableViewCell>(_ cell: C.Type) {
        register(C.self, forCellReuseIdentifier: C.reuseIdentifier)
    }
}
