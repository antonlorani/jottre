import UIKit

final class ImageViewProvider: PreferencesCustomViewProvider {

    private struct Constants {
        static let paddingVertical = CGFloat(5)
        static let tintColor = UIColor.systemGray
    }

    private let image: UIImage?

    init(image: UIImage?) {
        self.image = image
    }

    func provideView() -> UIView {
        let imageView = UIImageView(image: image)
        imageView.tintColor = Constants.tintColor
        return imageView
    }

    func provideViewConstraints(superview: UIView, view: UIView) {
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            view.heightAnchor.constraint(equalTo: superview.heightAnchor, constant: -Constants.paddingVertical * 2),
            view.widthAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}
