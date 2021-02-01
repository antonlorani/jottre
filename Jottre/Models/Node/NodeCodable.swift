//
//  NodeCodable.swift
//  Jottre
//
//  Created by Anton Lorani on 30.01.21.
//

import Foundation
import PencilKit


/// V1 of the NodeCodable The content of this struct will be serialized to a binary file
struct NodeCodableV1: Codable {
    
    var drawing: PKDrawing = PKDrawing()
    
    var width: CGFloat = 1200
    
}


/// V2 of the NodeCodable The content of this struct will be serialized to a binary file
struct NodeCodableV2: Codable {
    
    var drawing: PKDrawing = PKDrawing()
    
    var width: CGFloat = 1200
    
    var version: Int = 0
    
    var lastModified: Double = NSDate().timeIntervalSince1970
    
}
