//
//  GraphModel.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/27/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import Foundation
// Should I add a Layer struct??
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

// Named all the layers prefixed with 'SP' - squinch + peeze
protocol ModelLayer {
    
    // Set property is for changing which layer precedes current layer
    var inputShape: ShapeTup { get set }
    var outputShape: ShapeTup { get }
    
    func updateParams(params: [String : Int]) -> Void
}

// InputShapes are always 3-tuples
//
struct ShapeTup: CustomStringConvertible {
    var description: String {
        return "(\(d0), \(d1), \(d2))"
    }
    
    var d0: Int
    var d1: Int
    var d2: Int
    
    init(_ d0: Int, _ d1: Int, _ d2: Int) {
        self.d0 = d0
        self.d1 = d1
        self.d2 = d2
    }
    
    init(tup: (Int, Int, Int)) {
        let (a, b, c) = tup
        d0 = a
        d1 = b
        d2 = c
    }
}

class SPInputLayer: ModelLayer {
    var inputShape: ShapeTup
    var outputShape: ShapeTup {
        return inputShape
    }
    
    init() {
        inputShape = ShapeTup(6, 6, 6)
    }
    
    init(tupShape: (Int, Int, Int)) {
        inputShape = ShapeTup(tup: tupShape)
    }
    
    func updateParams(params: [String : Int]) {
        if let d0 = params["dim0"] {
            inputShape.d0 = d0
        }
        if let d1 = params["dim1"] {
            inputShape.d1 = d1
        }
        if let d2 = params["dim2"] {
            inputShape.d2 = d2
        }
    }
}

class SPConv2DLayer: ModelLayer {
    var inputShape: ShapeTup
    var kernelSize: (Int, Int)
    var stride: (Int, Int)
    var filters: Int
    var padding: (Int, Int)
    var outputShape: ShapeTup {
        let (h, w, ch) = (inputShape.d0, inputShape.d1, inputShape.d2)
        let (pH, pW) = padding
        let (kH, kW) = kernelSize
        let (sH, sW) = stride
        let outH = dimCalc(h, pH, kH, sH)
        let outW = dimCalc(w, pW, kW, sW)
        return ShapeTup(outH, outW, filters)
    }
    
    // Calculates ouput spatial dimension of conv2d layer
    func dimCalc(_ h: Int, _ p: Int, _ k: Int, _ s: Int) -> Int {
        let inner: Double = (Double(h) + 2.0 * Double(p) - 1) / Double(s)
        let out = Int(floor(inner))
        return out
    }
    
    // Default init
    init() {
        inputShape = ShapeTup(8, 0, 8)
        kernelSize = (3, 3)
        stride = (1, 1)
        filters = 64
        padding = (0, 0)
    }
    
    // Holy ass this seems so stupid
    func updateParams(params: [String : Int]) {
        if let kH = params["kH"] {
            let (_, w) = kernelSize
            kernelSize = (kH, w)
        }
        if let kW = params["kW"] {
            let (h, _) = kernelSize
            kernelSize = (h, kW)
        }
        if let sH = params["sH"] {
            let (_, w) = stride
            stride = (sH, w)
        }
        if let sW = params["sH"] {
            let (h, _) = stride
            stride = (h, sW)
        }
        if let pH = params["pH"] {
            let (_, w) = padding
            padding = (pH, w)
        }
        if let pW = params["pW"] {
            let (h, _) = padding
            padding = (h, pW)
        }
        if let f = params["filters"] {
            filters = f
        }
    }
}

class SPDenseLayer: ModelLayer {
    var inputShape: ShapeTup
    var weightShape: (Int, Int)
    
    // I don't know how to throw good iOS errors :/
    var outputShape: ShapeTup {
        let (w0, w1) = weightShape
        return ShapeTup(0, inputShape.d0, w1)
    }
    
    init() {
        inputShape = ShapeTup(0, 0, 69)
        weightShape = (69, 128)
    }
    
    func updateParams(params: [String : Int]) {
        if let w0 = params["w0"] {
            let (_, w1) = weightShape
            weightShape = (w0, w1)
        }
        if let w1 = params["w1"] {
            let (w0, _) = weightShape
            weightShape = (w0, w1)
        }
    }
}
