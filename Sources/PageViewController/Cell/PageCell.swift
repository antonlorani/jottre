import UIKit

protocol PageCell: UICollectionViewCell {
    static var reuseIdentifier: String { get }

    associatedtype ViewModel: Sendable & AnyObject

    func configure(viewModel: ViewModel)
}
