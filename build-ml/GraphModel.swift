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
    
    static let LAYERS : [Any.Type] = [SPConv2DLayer.self, SPInputLayer.self, SPDenseLayer.self, SPMaxPooling2DLayer.self, SPDropoutLayer.self, SPFlattenLayer.self, SPReshapeLayer.self]

    var layers = [ModelLayer]()
    var toAdd = [ModelLayer]()
    var name: String = "User Model"
    
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
    
    func toJSON() -> [String : Any] {
        if !self.isValid() {
            return [:]
        }
        
        // loop through model layer list, generate corresponding layers + params
        //
        var modelSpec: [String: Any] = [
            "info": "Right now optimizer & dataset are hard-coded:",
            "model_name": name,
            "num_layers": layers.count - 1,
            "optimizer": "Adadelta",
            ]
        var count = 0
        print("Entering the JSON gen loop for each layer")
        print(layers)
        for layer in layers {
            if count == 0 {
                modelSpec["input_layer"] = layer.getParams()
                count += 1
                continue
            }
            let layerid = "layer_\(count-1)"
            var layerParams = layer.getParams()
            
            // MARK:- HARDCODED LOGIC FOR SOFTMAX
            // Fixme: - make activations accessible
            // HARDCODED LOGIC
            if count == (layers.count - 1) {
                layerParams["activation"] = "softmax"
            }
            modelSpec[layerid] = layerParams
            count += 1
        }
        print("Exited the JSON gen loop")
        let totalJSON: [String: Any] = ["model": modelSpec,
                                        "dataset": [
                                            "name" : "MNIST",
                                            "batch_size" : 32,
                                            "epochs" : 12,
                                            "metrics" : ["accuracy"],
                                            "loss" : "categorical_crossentropy"
            ]
        ]
        print(totalJSON)
        return totalJSON
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
    static var description: String { get }
    
    func updateParams(params: [String : Int]) -> Void
    func updateChildren() -> Void
    func validLayer() -> Bool
    func getParams() -> [String : Any]
}

extension ModelLayer {
    func getName() -> String { return Self.name }
    func getDescription() -> String { return Self.description }
    func getIconName() -> String { return Self.imgName }
}

// InputShapes are always 3-tuples
//
class ShapeTup: CustomStringConvertible, Equatable {
    var d0: Int
    var d1: Int
    var d2: Int
    var size: Int {
        return (d0 != 0 ? d0 : 1)*(d1 != 0 ? d1 : 1)*(d2 != 0 ? d2 : 1)
    }
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
    static let description: String = "Specifies input to models"
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
    
    func getParams() -> [String : Any] {
        return ["dim" : inputShape.description]
    }
}

// NOTE: padding is deprecated in TF.Keras? look in keras source docs to find default padding calculation
class SPConv2DLayer: ModelLayer {
    static let imgName: String = "conv2dlayer"
    static let name: String = "Conv2D"
    static let description: String = "Transform that learns spatial features"
    var inputShape: ShapeTup
    var kernelSize: (Int, Int)
    var stride: (Int, Int)
    var filters: Int
    var activation: String = "relu"
    var padding: (Int, Int)
    var nextLayer: ModelLayer?
    var outputShape: ShapeTup {
        let (h, w, ch) = (inputShape.d0, inputShape.d1, inputShape.d2)
        let (pH, pW) = padding
        let (kH, kW) = kernelSize
        let (sH, sW) = stride
        let outH = SPConv2DLayer.dimCalc(h, pH, kH, sH)
        let outW = SPConv2DLayer.dimCalc(w, pW, kW, sW)
        return ShapeTup(outH, outW, filters)
    }
    
    // Calculates ouput spatial dimension of conv2d layer
    static func dimCalc(_ h: Int, _ p: Int, _ k: Int, _ s: Int) -> Int {
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
    
    func getParams()  -> [String : Any] {
        return ["layer": SPConv2DLayer.name + "Lyr",
                "dim": String(inputShape.d0),
                "kernel_size": "(\(kernelSize.0), \(kernelSize.1))",
                "stride": "(\(stride.0), \(stride.1))",
                "activation": "\(activation)"]
    }
}

class SPMaxPooling2DLayer: ModelLayer {
    var inputShape: ShapeTup
    var outputShape: ShapeTup {
        let (h, w, ch) = (inputShape.d0, inputShape.d1, inputShape.d2)
        let (pH, pW) = poolSize
        let outH = SPConv2DLayer.dimCalc(h, 0, pH, pH)
        let outW = SPConv2DLayer.dimCalc(w, 0, pW, pW)
        return ShapeTup(outH, outW, ch)
    }
    var poolSize: (Int, Int)
    var stride: (Int, Int)
    var nextLayer: ModelLayer?
    static var imgName: String = "maxpooling2dlayer"
    static var name: String = "MaxPooling2D"
    static var description: String = "Filters regions by returning largest element per region"
    
    init() { // default
        inputShape = ShapeTup(8, 0, 8)
        poolSize = (2, 2)
        stride = (1, 1)
    }
    
    func updateParams(params: [String : Int]) {
        if let p0 = params["poolW"] {
            poolSize.0 = p0
        }
        if let p1 = params["poolH"] {
            poolSize.1 = p1
        }
        if let s0 = params["sW"] {
            stride.0 = s0
        }
        if let s1 = params["sH"] {
            stride.1 = s1
        }
        updateChildren()
    }
    
    func updateChildren() {
        nextLayer?.inputShape = outputShape
        nextLayer?.updateChildren()
    }
    
    func validLayer() -> Bool {
        return inputShape.d0 > 0 && inputShape.d1 > 0 && inputShape.d2 > 0 && poolSize.0 > 0 && poolSize.1 > 0 && stride.0 > 1 && stride.1 > 0
    }
    
    func getParams() -> [String : Any] {
        return ["layer": SPMaxPooling2DLayer.name + "Lyr",
                "pool_size": "(\(poolSize.0), \(poolSize.1))",
                "stride:": "(\(stride.0), \(stride.1))"]
    }
}

class SPDropoutLayer: ModelLayer {
    var inputShape: ShapeTup
    var outputShape: ShapeTup {
        return inputShape
    }
    
    var nextLayer: ModelLayer?
    var rate: Double
    
    init() { // default dropout
        inputShape = ShapeTup(8, 0, 8)
        rate = 0.25
    }
    
    static var imgName: String = "dropoutlayer" // FIXME: dropout graphic?
    static var name: String = "Dropout"
    static var description: String = "Helps prevent overfitting"
    
    func updateParams(params: [String : Int]) {
        if let r = params["rate"] {
            rate = Double(r) / 100
        }
    }
    
    func updateChildren() {
        nextLayer?.inputShape = outputShape
        nextLayer?.updateChildren()
    }
    
    func validLayer() -> Bool {
        return rate < 1.0 && rate > 0.0
    }
    
    func getParams() -> [String : Any] {
        return ["layer" : SPDropoutLayer.name + "Lyr", "rate" : rate]
    }
}

class SPFlattenLayer: ModelLayer {
    var inputShape: ShapeTup
    var outputShape: ShapeTup {
        return ShapeTup(0,0,inputShape.size)
    }
    var nextLayer: ModelLayer?
    static var imgName: String = "flattenlayer"
    static var name: String = "Flatten"
    static var description: String = "Flattens the previous layer's output"
    
    init() {
        inputShape = ShapeTup(8, 0, 8)
    }
    
    func updateParams(params: [String : Int]) {
        return
    }
    
    func updateChildren() {
        nextLayer?.inputShape = outputShape
        nextLayer?.updateChildren()
    }
    
    func validLayer() -> Bool {
        return true
    }
    
    func getParams() -> [String : Any] {
        return ["layer": SPFlattenLayer.name + "Lyr"]
    }
}

class SPReshapeLayer: ModelLayer {
    var inputShape: ShapeTup
    var outputShape: ShapeTup {
        return dim
    }
    // This is the parameter they control
    var dim: ShapeTup
    var nextLayer: ModelLayer?
    static var imgName: String = "reshapelayer"
    static var name: String = "Reshape"
    static var description: String = "Reshapes the previous layer's output"
    
    init() {
        inputShape = ShapeTup(8, 0, 8)
        dim = ShapeTup(0, 0, 64)
    }
    
    func updateParams(params: [String : Int]) {
        if let d0 = params["d0"] {
            dim.d0 = d0
        }
        if let d1 = params["d1"] {
            dim.d1 = d1
        }
        if let d2 = params["d2"] {
            dim.d2 = d2
        }
        updateChildren()
    }
    
    func updateChildren() {
        nextLayer?.inputShape = outputShape
        nextLayer?.updateChildren()
    }
    
    func validLayer() -> Bool {
        return dim.d0 != 0 && inputShape.size == outputShape.size
    }
    
    func getParams() -> [String : Any] {
        return ["layer": SPFlattenLayer.name + "Lyr",
                "dim": dim.description
        ]
    }
}

class SPDenseLayer: ModelLayer {
    static let imgName: String = "denselayer"
    static let name: String = "Dense"
    static let description: String = "Simplest deep transform"
    var inputShape: ShapeTup
    var units: Int
    var activation: String
    var nextLayer: ModelLayer?
    
    // I don't know how to throw good iOS errors :/
    var outputShape: ShapeTup {
        return ShapeTup(0, 0, units)
    }
    
    init() {
        inputShape = ShapeTup(0, 0, 69)
        units = 128
        activation = "relu"
    }
    
    func updateChildren() {
        nextLayer?.inputShape = outputShape
        nextLayer?.updateChildren()
    }
    
    func updateParams(params: [String : Int]) {
        if let u = params["u"] {
            units = u
        }
        updateChildren()
    }
    
    func validLayer() -> Bool {
        return inputShape.d0 == 0 && inputShape.d1 == 0 && inputShape.d2 > 0 &&
            outputShape.d0 == 0 && outputShape.d1 == 0 && outputShape.d2 > 0
    }
    
    func getParams() -> [String : Any] {
        return ["layer": SPDenseLayer.name + "Lyr", "units" : outputShape.d2, "activation" : "\(activation)"]
    }
}

