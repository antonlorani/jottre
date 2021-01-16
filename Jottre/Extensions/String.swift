//
//  String.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit

extension String {
    
    /// Computes the width of the text inside a UILabel
    /// - Parameter label: UILabel that will contain the text
    /// - Returns: Width in px
    func width(inside label: UILabel) -> CGFloat {
        guard let font = label.font else {
            return 0
        }
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        
        return size.width
    }
    
    
    /// Computes the width of the text inside a UIButton
    /// - Parameter label: UIButton that will contain the text
    /// - Returns: Width in px
    func width(inside button: UIButton) -> CGFloat {
        guard let font = button.titleLabel?.font else {
            return 0
        }
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        
        return size.width
    }
    
}
