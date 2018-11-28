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
        // submitAction(sender: <#T##AnyObject#>) //JSON POST
        
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
        button.setTitle("Full Send Model", for: .normal)
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor.black
        button.titleLabel?.textColor = UIColor.white
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(buttonClicked(_ :)),
            for: .touchUpInside)
        self.view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.width.equalTo(button.frame.width)
            make.height.equalTo(button.frame.height)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(50)
        }
    }
    
    @objc func buttonClicked(_ : UIButton) { // make button hidden/greyed out if model isn't valid
        print("Clicked")
        let tabVC = tabBarController! as! MainViewController
        for layer in tabVC.userModel.layers {
            print(layer.getParams())
        }
        let messageDictionary = [
            "model": [
                "info": "Mnist CNN model from keras-team examples",
                "model_name": "bigDickCNN-69",
                "num_layers": 8,
                "optimizer": "Adadelta",
                "input_layer": [
                    "dim": "(28,28,1)"
                ],
                "layer_0": [
                    "layer": "Conv2DLyr",
                    "filters": 32,
                    "kernel_size": "(3,3)",
                    "activation": "relu",
                    "input_shape": "(28,28,1)"
                ],
                "layer_1": [
                    "layer": "Conv2DLyr",
                    "filters": 64,
                    "kernel_size": "(3,3)",
                    "activation": "relu"
                ],
                "layer_2": [
                    "layer": "MaxPooling2DLyr",
                    "pool_size" : "(2,2)"
                ],
                "layer_3": [
                    "layer": "DropoutLyr",
                    "rate": 0.25
                ],
                "layer_4": [
                    "layer":"FlattenLyr"
                ],
                "layer_5": [
                    "layer": "DenseLyr",
                    "units": 128,
                    "activation": "relu"
                ],
                "layer_6": [
                    "layer": "DropoutLyr",
                    "rate": 0.5
                ],
                "layer_7": [
                    "layer": "DenseLyr",
                    "units": 10,
                    "activation":"softmax"
                ]
            ],
            "dataset":[
                "name" : "MNIST",
                "batch_size" : 32,
                "img_rows" : 28,
                "img_cols" : 28,
                "num_classes" : 10,
                "epochs" : 12,
                "metrics" : ["accuracy"],
                "loss" : "mse"
            ]
            ] as [String : Any]
        jsonPOST(modelDictionary: messageDictionary) // FIXME: jsonPOST(modelDictionary: tabVC.userModel.toJSON())
        let alert = UIAlertController(title: "Congratulations!", message: "You've just uploaded a model!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
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
        print(tabVC.userModel)
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
            layerButton.updateBorder();
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
    // Trick was doing this so that it generalizes to each unique ModelLayerViewController
    @objc func touchLayer(button: LayerButton) {
        // Build name -> layer type for referencing

        let prevStyle = modalPresentationStyle
        var vc = UIStoryboard(name: button.modelLayer.getName() + "Alert", bundle: nil).instantiateViewController(withIdentifier: button.modelLayer.getName() + "VC") as! ModelLayerViewControllerProtocol
        vc.graphBuilder = self
        vc.precastLayer = button.modelLayer
        modalPresentationStyle = .popover
        present(vc as! UIViewController, animated: true, completion: nil)
        modalPresentationStyle = prevStyle
    }
    
    // MARK: - Connect LayerView with the LayerModel
    // Handles creation of the layer button objects
    // Attaches the ModelLayer to the Layer upon creation, and attaches corresponding UIInteractions
    func instantiateLayerButton(layer: ModelLayer) -> LayerButton {
        let button = LayerButton(actualLayer: layer)
        button.addTarget(self, action: #selector(touchLayer(button:)), for: UIControlEvents.touchUpInside)
        return button
        
        //FULL SEND BUTTON
        // tabVC - has GraphModel class
        //graphmodel contains var layers
        // get all the parameter shit from layers
        //when button is pressed, parse layers, put into json, full send
    }
    
    //JSON POST code below
    func jsonPOST(modelDictionary: [String : Any]) {
        //put JSON in AppData/Documents/JSONS and get from there then use the NSURL to send to server
        //Big Idea: format JSON --> write JSON to Documents/JSONS/.. --> POST JSON
        //declare parameter as a dictionary which contains string as key and value combination.
        
        let jsonData = try! JSONSerialization.data(withJSONObject: modelDictionary)
        print(jsonData)
        _ = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
    
        //create the url with NSURL
        let url = NSURL(string: "http://latte.csua.berkeley.edu:5000/make-model")
        
        //create the session object
        let session = URLSession.shared
        
        //now create the NSMutableRequest object using the url object
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST" //set http method as POST
        request.httpBody = jsonData
        
        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data huehuehuehuehue")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) // FIXME:
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            } else {
                print("Hmm...")
            }
        }
        
        task.resume()
    }
    
    /**
     - returns:
     the URL of a local .mlmodel
     */
    func modelGET(modelName: String) -> URL? { // make a button for this and recognize all saved models in DEPLOY mode
        var modelURL: URL?
        // FIXME: use a semaphore to block until model is received
        let semaphore = DispatchSemaphore(value: 0)
        getMLModel("http://latte.csua.berkeley.edu:5000/get-model", parameters: ["model_name": modelName]) { fileURL, error in
            if fileURL == nil || error != nil {
                print(error ?? "something went wrong")
                semaphore.signal()
                return
            }
            
            modelURL = fileURL
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(UInt64(10) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC))
        
        return modelURL
    }
    
    // TODO: make so models are named according to JSON spec and date of creation
    // TODO: make get request for progress
    // TODO: make buttons for all this jank
    
    func getMLModel(_ url: String, parameters: [String: String], completion: @escaping (URL?, Error?) -> Void) {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print(response as Any)
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    completion(nil, error)
                    return
            }
            
            var fileURL: URL!
            do {
                fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("test.mlmodel")
            } catch {
                print("LOL this shit fucked.")
                completion(nil, nil)
                return
            }
            
            do {
                try data.write(to: fileURL, options: Data.WritingOptions.atomic)
            } catch {
                print("Write failed.")
                completion(nil, nil)
                return
            }
            // let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            completion(fileURL, nil)
        }
        task.resume()
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
