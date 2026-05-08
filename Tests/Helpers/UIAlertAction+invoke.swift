import UIKit

extension UIAlertAction {

    func invokeHandler() {
        typealias Handler = @convention(block) (UIAlertAction) -> Void
        guard let block = value(forKey: "handler") else {
            return
        }
        let handler = unsafeBitCast(block as AnyObject, to: Handler.self)
        handler(self)
    }
}
