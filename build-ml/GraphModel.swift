//
//  GraphModel.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/27/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import Foundation

class GraphModel {
    
    var layers = [String]()
    var name: String!
    
    init(name: String) {
        self.name = name
    }
    
    func addLayer(layer: String) {
        layers.append(layer)
    }
    
    // Returns multiline description of the model (assuming it's sequential)
    func convertLayersToString() -> String {
        var desc: String = name
        for layer in self.layers {
            desc = desc + "\n - " + layer
        }
        return desc
    }
}
