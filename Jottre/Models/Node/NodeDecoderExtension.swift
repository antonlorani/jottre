//
//  NodeDecoderExtension.swift
//  Jottre
//
//  Created by Anton Lorani on 30.01.21.
//

import Foundation
import UIKit
import OSLog

extension Node {
    
    // FIXME: - Is there a way to do this recursive?
    
    /// Decodes the latest NodeCodable from given data
    /// - Parameter data: Data of a NodeCodable object
    /// - Returns: NodeCodable2
    func decode(from data: Data) -> NodeCodableV2? {
        let decoder = PropertyListDecoder()
        
        do {
            return try decoder.decode(NodeCodableV2.self, from: data)
        } catch {
            
            do {
                let codableV1 = try decoder.decode(NodeCodableV1.self, from: data)
                return NodeCodableV2(drawing: codableV1.drawing, width: codableV1.width, version: 1, lastModified: NSDate().timeIntervalSince1970)
            } catch {
                Logger.main.error("Could not decode data as NodeCodable(V1, V2)")
                return nil
            }
            
        }

    }
    
}
