//
//  ModelLayerViewControllerProtocol.swift
//  build-ml
//
//  Created by Noah Gundotra on 11/28/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import Foundation

// This allows us to do general stuff without having to worry about specific
// SPModelLayer
protocol ModelLayerViewControllerProtocol {
    // Each actual VC will have to implement its own downcast
    // i.e. var modelLayer : SPNewLayer { return precastLayer as? SPNewLayer }
    var precastLayer : ModelLayer? {get set}
    var graphBuilder: GraphBuilderViewController? {get set}
}
