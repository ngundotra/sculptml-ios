//
//  GraphBuilderViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/26/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class GraphBuilderViewController: UIViewController {
    var layerObjs = [UIButton]()
    var testLayerObj: UIButton = LayerButton(layerImgName: "inputLayer")
    let debugLabel = UILabel()
    let viewTitle = UILabel()
    let backButton = UIButton()
    let debugHeader: String = "Debug Label:"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        testLayerObj = instantiateLayerButton(layerName: "Input")
        view.addSubview(debugLabel)
        view.addSubview(viewTitle)
        view.addSubview(testLayerObj)
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        // Title Label
        makeTitleLabel()
        
        // Debug Label
        makeDebugLabel()
        
        // Set Back Button
//        makeBackButton()
        
        // Debug only
        layerObjs = [testLayerObj]
        view.clipsToBounds = true
        
        // Scroll Graph
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(scrollGraph))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set Drag N Drop
        print("entered")
        
        // Make sure to display data loaded from persistence
        updateView()
    }
    
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
        
        // Note that there is a specific delegate for dragging text boxes...(?)
//        let dropInteraction = UIDragInteraction(delegate: self.debugLabel.view)
//        view.addInteraction(dropInteraction)
//        let masterVC = tabBarController! as! MainViewController
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.debugPan(_:)))
        debugLabel.addGestureRecognizer(panGesture)
    }
    
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
    
    @objc func touchInputLayer() {
        let vc = UIStoryboard(name: "InputAlert", bundle: nil).instantiateViewController(withIdentifier: "InputAlertVC")
//        vc.setLayer(layer: )
        modalPresentationStyle = .popover
        present(vc, animated: true, completion: nil)
        print("touched!")
    }
    
    func updateLayerObjs() {
        let ct = view.subviews.count
        for subv in layerObjs {
            subv.removeFromSuperview()
        }
        layerObjs = []
        print("Delta = \(view.subviews.count - ct)")
        let tabVC = self.tabBarController! as! MainViewController
        var prev: CGRect = debugLabel.frame
        for layer in tabVC.userModel.layers {
            let but = instantiateLayerButton(layerName: layer)
            layerObjs.append(but)
            print("button: \(layer) added")
            view.addSubview(but)
            but.frame = CGRect(x: 50.0, y: prev.maxY, width: 75.0, height: 75.0)
            //            layer.snp.makeConstraints { (make) -> Void in
            //                make.top.equalTo(prev).offset(15.0)
            //                make.centerX.equalTo(prev)
            //                make.height.greaterThanOrEqualTo(75.0).priority(600)
            //                make.width.greaterThanOrEqualTo(75.0).priority(600)
            //            }
            prev = but.frame
        }
        
        
    }
    
    // Called by TabVC when showing the
    func updateView() {
        updateDebugLabel()
        updateLayerObjs()
    }
    
    fileprivate func updateDebugLabel() {
        let tabVC: MainViewController = tabBarController as! MainViewController
        
        // Only a problem for initialization
        if let userModel = tabVC.userModel {
            debugLabel.text = userModel.convertLayersToString()
        }
    }
    
    // Makes debug label programmatically
    fileprivate func makeDebugLabel() {
        debugLabel.snp.makeConstraints{(make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20.0)
            make.height.greaterThanOrEqualTo(20.0)
        }
        debugLabel.numberOfLines = 0
        debugLabel.text = debugHeader
        
        allowDragDebug()
    }
    
    // Currently deprecated
    fileprivate func makeBackButton() {
        backButton.setTitle("Layers", for: .normal)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.addTarget(self, action: #selector(self.backToLayer), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // Currently unused
    @objc func backToLayer() {
        self.navigationController?.popViewController(animated: true)
        print("nav button has been hit")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Handles creation of the layer button objects
    func instantiateLayerButton(layerName: String) -> UIButton {
        let button = UIButton(type: .custom)
        var img = UIImage()
        if layerName.elementsEqual("Conv2D") {
            img = #imageLiteral(resourceName: "conv2dlayer")
            //            return LayerButton(layerImgName: layerName)
        } else if layerName.elementsEqual("Input") {
            img = #imageLiteral(resourceName: "inputlayer")
            button.addTarget(self, action: #selector(touchInputLayer), for: UIControlEvents.touchUpInside)
//            return LayerButton(layerImgName: layerName)
        } else if layerName.elementsEqual("Dense") {
            img = #imageLiteral(resourceName: "denselayer")
//            return LayerButton(layerImgName: layerName)
        } else {
            fatalError("bad layer name given: \(layerName)")
        }
        button.setBackgroundImage(img, for: .normal)
        button.setBackgroundImage(img, for: .selected)
        button.setTitle(layerName, for: .normal)
        button.setTitle(layerName, for: .selected)
        return button
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
