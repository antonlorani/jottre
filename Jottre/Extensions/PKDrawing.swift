//
//  PKDrawing.swift
//  Jottre
//
//  Created by Anton Lorani on 21.01.21.
//

import PencilKit

extension PKDrawing {
    
    /// Converts PKDrawing to a UIImage using a presetted appearance
    /// NOTE: - The returned image has 3 channels (4th channel (alpha) will be just white color)
    /// - Parameters:
    ///   - rect: The portion of the drawing that you want to capture. Specify a rectangle in the canvas' coordinate system.
    ///   - scale: The scale factor at which to create the image. Specifying scale factors greater than 1.0 creates an image with more detail. For example, you might specify a scale factor of 2.0 or 3.0 when displaying the image on a Retina display.
    ///   - userInterfaceStyle: Prefered user-interface style such as dark or light
    /// - Returns:
    func image(from rect: CGRect, scale: CGFloat, userInterfaceStyle: UIUserInterfaceStyle) -> UIImage {
        let currentTraits = UITraitCollection.current
        UITraitCollection.current = UITraitCollection(userInterfaceStyle: userInterfaceStyle)
        
        let image = self.image(from: rect, scale: scale)
        UITraitCollection.current = currentTraits
        
        return image
    }
    
}
