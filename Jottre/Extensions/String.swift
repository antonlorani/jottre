//
//  String.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit

extension String {
    
    func width(inside label: UILabel) -> CGFloat {
        guard let font = label.font else {
            return 0
        }
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        
        return size.width
    }
    
    func width(inside button: UIButton) -> CGFloat {
        guard let font = button.titleLabel?.font else {
            return 0
        }
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        
        return size.width
    }
    
}
