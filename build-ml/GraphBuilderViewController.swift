//
//  GraphBuilderViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/26/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class GraphBuilderViewController: UIViewController {
    let LAYER_OBJ_BUFFER = 37.5
    
    var layerObjs = [LayerButton]()
    let debugLabel = UILabel()
    let viewTitle = UILabel()
    let debugHeader: String = "Debug Label:"
    
    var panGraph: UIPanGestureRecognizer?
    var swipeGesture: UISwipeGestureRecognizer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(debugLabel)
        view.addSubview(viewTitle)
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        // Title Label
        makeTitleLabel()
        
        // Button
        createButton()
        
        // Debug Label
        makeDebugLabel()
        
        // Debug only
        view.clipsToBounds = true
        
        // Scroll Graph
        // Set instance variable
        panGraph = UIPanGestureRecognizer(target: self, action: #selector(scrollGraph))
        view.addGestureRecognizer(panGraph!)
        
        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLayerObj(_:)))
        view.addGestureRecognizer(swipeGesture!)
        // Make sure swiping gets higher priority
        panGraph?.require(toFail: swipeGesture!)
    }
    
    func createButton() {
        let button = UIButton.init(type: .system)
        button.frame = CGRect(x: 50.0, y: 150.0, width: 200.0, height: 52.0)
        button.setTitle("Like this video", for: .normal)
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor.black
        button.titleLabel?.textColor = UIColor.white
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(buttonClicked(_ :)),
            for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func buttonClicked(_ : UIButton) {
        print("Clicked")
        let tabVC = tabBarController! as! MainViewController
        for layer in tabVC.userModel.layers {
            print(layer.getParams())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Make sure to display data loaded from persistence
        updateView()
    }
    
    // MARK: - Set up programmatic view
    // Set constraints and information about the view controller title
    func makeTitleLabel() {
        viewTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(60.0)
            make.centerX.equalToSuperview()
        }
        viewTitle.font = UIFont.boldSystemFont(ofSize: 35.0)
        viewTitle.text = "Graph Builder"
    }
    
    // Set up dragging of the debug label
    func allowDragDebug() {
        debugLabel.isUserInteractionEnabled = true

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.debugPan(_:)))
        debugLabel.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Dragging Interactions
    // Manual hand-coding to add extra space between top of view and the iOS pull down menu
    @objc func debugPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        let center = debugLabel.center
        debugLabel.center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        
        // clip everything to bounds...
        if let frame = tabBarController?.tabBar.frame {
            let bigFrame = self.view.frame
            let usableFrame = CGRect(x: bigFrame.minX, y: bigFrame.minY + 20.0, width: bigFrame.width, height: bigFrame.height - frame.height)
            Utils.clipToBounds(view: debugLabel, frame: usableFrame)
        }
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
    }
    
    // Be able to scroll up on the whole graph by tourching any of the elements..?
    @objc func scrollGraph(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        for obj in layerObjs {
            let center = obj.center
            obj.center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            // clip everything to bounds...
            if let frame = tabBarController?.tabBar.frame {
                let bigFrame = self.view.frame
                let usableFrame = CGRect(x: bigFrame.minX, y: bigFrame.minY + 20.0, width: bigFrame.width, height: bigFrame.height - frame.height)
//                Utils.clipToBounds(view: obj, frame: usableFrame)
//                obj.frame = Utils.clipToBounds(view: obj.frame, frame: usableFrame)
            }
        }
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
    }
    
    // MARK:- Swipe
    @objc func swipeLayerObj(_ gestureRecognizer: UISwipeGestureRecognizer) {
        // Look for the layer button this happened on
        var button: LayerButton?
        let location = gestureRecognizer.location(in: view)
        
        var idx = 0
        for layer in layerObjs {
            if layer.frame.contains(location) {
                button = layer
                break
            }
            idx += 1
        }
        
        // If you did find the layer, print its name
        if let button = button {
            let name: String = type(of: button.modelLayer).name
            print("\(name) found")
            
            // You should not be able to remove the input layer
            if idx > 0 {
                button.fadeOut()
                let model = (tabBarController as! MainViewController).userModel
                model?.removeLayer(at: idx, prevLayer: idx-1)
                layerObjs.remove(at: idx)
                updateGraphValidity()
                Utils.slideUp(layers: layerObjs, from: idx - 1, buffer: LAYER_OBJ_BUFFER)
            }
            
        }
    }
    
    // MARK: - Update View functions
    // Called by TabVC when showing the
    func updateView() {
        updateLayerObjs()
        updateDebugLabel()
        updateGraphValidity()
        view.bringSubview(toFront: viewTitle)
        view.bringSubview(toFront: debugLabel)
    }
    
    func updateLayerObjs() {
        let tabVC = self.tabBarController! as! MainViewController
        var prev: CGRect = debugLabel.frame
        
        // add layers if necessary from the model
        for layer in tabVC.userModel.toAdd {
            let but = instantiateLayerButton(layer: layer)
            view.addSubview(but)
            
            // Giving each button the same size
            but.frame = CGRect(x: 50.0, y: prev.maxY, width: 75.0, height: 75.0)
            
            // Now to always center the button underneath the other button
            var centerPoint = view.center
            var cX = centerPoint.x
            var cY = centerPoint.y
            if let above = layerObjs.last {
                centerPoint = above.center
                cX = centerPoint.x
                cY = centerPoint.y
                let height = LAYER_OBJ_BUFFER
                cY += CGFloat(height)
            }
            let offset = CGFloat(30.0)
            let newCenter = CGPoint(x: cX, y: cY + offset)
            but.center = newCenter
            prev = but.frame
            layerObjs.append(but)
            tabVC.userModel.addLayer(actualLayer: layer)
        }
        
        tabVC.userModel.flush()
    }
    
    func updateGraphValidity() {
        // check if the model is valid, kind of unnecessary tho
        // bc we present bad layers on a layer by layer basis
        let tabVC = tabBarController! as! MainViewController
        let valid = tabVC.userModel.isValid()
        for layer in tabVC.userModel.layers {
            print(layer.outputShape)
        }
        
        for layerButton in layerObjs {
            layerButton.updateBorder()
        }
        updateDebugLabel()
    }
    
    // MARK: This is where we could let user rename their model
    fileprivate func updateDebugLabel() {
        let tabVC: MainViewController = tabBarController as! MainViewController
        
        // Only a problem for initialization
        if let userModel = tabVC.userModel {
            debugLabel.text = userModel.convertLayersToString()
        }
    }
    
    // MARK: Set user model name
    // FIXME: change debugLabel var name to be modelNameLabel
    // Makes debug label programmatically
    fileprivate func makeDebugLabel() {
        debugLabel.snp.makeConstraints{(make) -> Void in
            make.right.equalTo(viewTitle).offset(-5.0)
            make.top.equalTo(viewTitle).offset(32.5)
            make.height.greaterThanOrEqualTo(20.0)
        }
        debugLabel.numberOfLines = 0
        debugLabel.text = debugHeader
        
//        allowDragDebug()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Launching VCs for each layer button
    // Passes the underlying ModelLayer to the corresponding popup ViewController
    @objc func touchInputLayer(button: LayerButton) {
        let prevStyle = modalPresentationStyle
        let vc = UIStoryboard(name: "InputAlert", bundle: nil).instantiateViewController(withIdentifier: "InputAlertVC") as! InputLayerAlertViewController
        vc.graphBuilder = self
        vc.modelLayer = (button.modelLayer as! SPInputLayer)
        //        vc.setLayer(layer: )
        modalPresentationStyle = .popover
        present(vc, animated: true, completion: nil)
        modalPresentationStyle = prevStyle
    }
    
    @objc func touchConv2DLayer(button: LayerButton) {
        let prevStyle = modalPresentationStyle
        let vc = UIStoryboard(name: "Conv2DAlert", bundle: nil).instantiateViewController(withIdentifier: "Conv2DAlertVC") as! Conv2DAlertViewController
        vc.graphBuilder = self
        vc.modelLayer = (button.modelLayer as! SPConv2DLayer)
        modalPresentationStyle = .popover
        present(vc, animated: true, completion: nil)
        modalPresentationStyle = prevStyle
    }
    
    @objc func touchDenseLayer(button: LayerButton) {
        let prevStyle = modalPresentationStyle
        let vc = UIStoryboard(name: "DenseAlert", bundle: nil).instantiateViewController(withIdentifier: "DenseLayerVC") as! DenseAlertViewController
        vc.graphBuilder = self
        vc.modelLayer = (button.modelLayer as! SPDenseLayer)
        modalPresentationStyle = .popover
        present(vc, animated: true, completion: nil)
        modalPresentationStyle = prevStyle
        //add to dictionary here
        
    }
    
    // MARK: - Connect LayerView with the LayerModel
    // Handles creation of the layer button objects
    // Attaches the ModelLayer to the Layer upon creation, and attaches corresponding UIInteractions
    func instantiateLayerButton(layer: ModelLayer) -> LayerButton {
        let button = LayerButton(actualLayer: layer)
        let layerName = type(of: layer).name
        
        if layerName.elementsEqual("Conv2D") {
            button.addTarget(self, action: #selector(touchConv2DLayer(button:)), for: UIControlEvents.touchUpInside)
        } else if layerName.elementsEqual("Input") {
            button.addTarget(self, action: #selector(touchInputLayer(button:)), for: UIControlEvents.touchUpInside)
        } else if layerName.elementsEqual("Dense") {
            button.addTarget(self, action: #selector(touchDenseLayer(button:)), for: .touchUpInside)
        } else {
            fatalError("bad layer name given: \(layerName)")
        }
        return button
        
        //FULL SEND BUTTON
        // tabVC - has GraphModel class
        //graphmodel contains var layers
        // get all the parameter shit from layers
        //when button is pressed, parse layers, put into json, full send
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
