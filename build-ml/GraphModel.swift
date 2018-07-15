//
//  GraphModel.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/27/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import Foundation

class GraphModel {
    
    // FIXME: - Add support for multi-headed models by not storing this as list, and storing all info in the `nextLayer` of each layer obj
    var layers = [ModelLayer]()
    var toAdd = [ModelLayer]()
    var name: String!
    
    init(name: String) {
        self.name = name
        toAdd.append(SPInputLayer())
    }
    
    // Connects the last layer to the layer at an index
    internal func attachLastLayer(to idx: Int) {
        let lastLayer = layers.last!
        var prevLayer = layers[idx]
        prevLayer.nextLayer = lastLayer
        prevLayer.updateChildren()
    }
    
    // Returns multiline description of the model (assuming it's sequential)
    func convertLayersToString() -> String {
        var desc: String = name
        for layer in self.layers {
            desc = desc + "\n - " + type(of: layer).name
        }
        desc = desc + "\n->" + getCurrentOutputShape()
        return desc
    }
    
    func flush() {
        toAdd = []
    }
    
    // MARK: Adding Layers
    // Setup to have models added
    // This adds layers to `toAdd`, which gets read from in GBVC to instantiate LayerButtons
    // GBVC then calls addLayer(..) to add the layer to the model
    func queueLayer(actualLayer: ModelLayer) {
        toAdd.append(actualLayer)
    }
    
    // Add a layer to the graph - usually you'll want to first queue the layer
    // then read from the queue to create the layer button
    func addLayer(actualLayer: ModelLayer) {
        let idxPrev = layers.count - 1
        layers.append(actualLayer)
        if layers.count >= 2 {
            attachLastLayer(to: idxPrev)
        }
    }
    
    // Remove a layer at this index
    func removeLayer(at idx: Int, prevLayer prevIdx: Int) {
        let layer = layers[idx]
        var prevLayer = layers[prevIdx]
        // Tie the graph together
        prevLayer.nextLayer = layer.nextLayer
        prevLayer.updateChildren()
        // Remove the layer 
        layers.remove(at: idx)
    }
    
    // Returns the output shape of the last layer
    func getCurrentOutputShape() -> String {
        if let last = layers.last {
            return "\(last.outputShape)"
        }
        return ""
    }
    
    // Checks if whole graph is valid
    func isValid() -> Bool {
        if layers.count < 1 {
            return true
        }
        
        // If first layer is an input layer
        if let inputLayer = layers.first as? SPInputLayer {
            for layer in self.layers {
                // If output of previous layer does not match input of this layer, throw a fit
                if !layer.validLayer() {
                    print("\(layer) is not valid")
                    
                    return false
                }
                // You cannot have multiple input layers
                if let inputlayer2 = layer as? SPInputLayer {
                    if inputlayer2 !== inputLayer {
                        print("Multiple input layers in the model")
                        return false
                    }
                }
            }
        } else {
            print("First layer is not an input layer")
            return false
        }
        
        
        return true
    }
}

// MARK: - ModelLayer Protocol
// Named all the layers prefixed with 'SP' - squinch + peeze
protocol ModelLayer {
    
    // Set property is for changing which layer precedes current layer
    var inputShape: ShapeTup { get set }
    var outputShape: ShapeTup { get }
    var nextLayer: ModelLayer? { get set }
    static var imgName: String { get }
    static var name: String { get }
    
    func updateParams(params: [String : Int]) -> Void
    func updateChildren() -> Void
    func validLayer() -> Bool
}

// InputShapes are always 3-tuples
//
class ShapeTup: CustomStringConvertible, Equatable {
    var d0: Int
    var d1: Int
    var d2: Int
    var description: String {
        return "(\(d0), \(d1), \(d2))"
    }
    
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
    
    static func ==(lhs: ShapeTup, rhs: ShapeTup) -> Bool {
        return lhs.d0 == rhs.d0 && lhs.d1 == rhs.d1 && lhs.d2 == rhs.d2
    }
}

// MARK: - SP Layers below
class SPInputLayer: ModelLayer {
    static let imgName: String = "inputlayer"
    static let name: String = "Input"
    var nextLayer: ModelLayer?
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
    
    func updateChildren() {
        nextLayer?.inputShape = outputShape
        nextLayer?.updateChildren()
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
        updateChildren()
    }
    
    func validLayer() -> Bool {
        return true
    }
}

class SPConv2DLayer: ModelLayer {
    static let imgName: String = "conv2dlayer"
    static let name: String = "Conv2D"
    var inputShape: ShapeTup
    var kernelSize: (Int, Int)
    var stride: (Int, Int)
    var filters: Int
    var padding: (Int, Int)
    var nextLayer: ModelLayer?
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
    
    func updateChildren() {
        nextLayer?.inputShape = outputShape
        nextLayer?.updateChildren()
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
        if let sW = params["sW"] {
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
        updateChildren()
    }
    
    func validLayer() -> Bool {
        if inputShape.d0 > 0 && inputShape.d1 > 0 && inputShape.d2 > 0 {
            if outputShape.d0 > 0 && outputShape.d1 > 0 && outputShape.d2 > 0 {
                return true
            }
        }
        return false
    }
}

class SPDenseLayer: ModelLayer {
    static let imgName: String = "denselayer"
    static let name: String = "Dense"
    var inputShape: ShapeTup
    var weightShape: (Int, Int)
    var nextLayer: ModelLayer?
    
    // I don't know how to throw good iOS errors :/
    var outputShape: ShapeTup {
        let (_, w1) = weightShape
        return ShapeTup(0, 0, w1)
    }
    
    init() {
        inputShape = ShapeTup(0, 0, 69)
        weightShape = (69, 128)
    }
    
    func updateChildren() {
        nextLayer?.inputShape = outputShape
        nextLayer?.updateChildren()
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
        updateChildren()
    }
    
    func validLayer() -> Bool {
        return inputShape.d0 == 0 && inputShape.d1 == 0 && inputShape.d2 > 0 &&
            outputShape.d0 == 0 && outputShape.d1 == 0 && outputShape.d2 > 0
    }
    
}
