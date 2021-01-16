//
//  UIView.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit

extension UIView {
    
    // MARK: - Methods
    
    /// Round corners only for the specified regions
    /// - Parameters:
    ///   - corners: An array that takes the regions to be cornered
    ///   - radius: Affects each selected corner
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
            mask.path = path.cgPath
    
        layer.mask = mask
    }
    
}
