//
//  ThumbnailGenerator.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import OSLog

class ThumbnailGenerator {
    
    // MARK: - Properties
    
    private let thumbnailQueue = DispatchQueue(label: "ThumbnailQueue", qos: .default)
    
    var size: CGSize
    
    
    
    // MARK: - Init
    
    /// Initializer of the ThumbnailGenerator class
    /// - Parameter size: Target-size (width, height) of thumbnail
    init(size: CGSize) {
        self.size = size
    }
    
    
    
    // MARK: - Methods
    
    /// Creates thumbnail for a given node
    /// - Parameters:
    ///   - node: Object of class Node. Requires that nodeCodable.drawing is not nil
    ///   - completion: A boolean that indicates success or failure and the resulting image (nil on failure)
    func execute(for node: Node, _ completion: @escaping (_ success: Bool, _ image: UIImage?) -> Void) {

        thumbnailQueue.async {
        
            guard let drawing = node.codable?.drawing, let width = node.codable?.width else {
                Logger.main.error("Cannot create thumbnail")
                completion(false, nil)
                return
            }
            
            let aspectRatio = self.size.width / self.size.height
            
            let thumbnailRect = CGRect(x: 0, y: 0, width: width, height: width / aspectRatio)
            
            let thumbnailScale = UIScreen.main.scale * self.size.width / width
                    
            let traitCollection = UITraitCollection(userInterfaceStyle: settings.preferredUserInterfaceStyle())
            
            traitCollection.performAsCurrent {
                let image = drawing.image(from: thumbnailRect, scale: thumbnailScale)
                completion(true, image)
            }
            
        }
        
    }
    
}
