import UIKit

extension UITableView {
    
    func dequeueReusableCell<C: UITableViewCell>(_ cell: C.Type) -> C {
        guard let cell = dequeueReusableCell(withIdentifier: C.reuseIdentifier) as? C else {
            preconditionFailure("Could not cast cell to type \(C.self)")
        }
        return cell
    }
}
