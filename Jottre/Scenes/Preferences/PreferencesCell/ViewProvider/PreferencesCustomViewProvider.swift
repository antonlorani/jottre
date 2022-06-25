import UIKit

protocol PreferencesCustomViewProvider {

    func provideView() -> UIView
    func provideViewConstraints(superview: UIView, view: UIView)
}
