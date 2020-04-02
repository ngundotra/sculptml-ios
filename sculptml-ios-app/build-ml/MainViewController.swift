//
//  MainViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/26/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit
import CoreML

class MainViewController: UITabBarController {
    let graphBuilderVC = GraphBuilderViewController()
    let layerVC = ViewController()
    let modelsVC = ModelsViewController()
    let lessonsVC = LessonsViewController()
    var userModel: GraphModel!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(graphModel: GraphModel) {
        super.init(nibName: nil, bundle: nil)
        self.userModel = graphModel
    }
    
    // FIXME: I should probably use this...
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        graphBuilderVC.tabBarItem = UITabBarItem(title: "Graph", image: #imageLiteral(resourceName: "graph-icon"), selectedImage: #imageLiteral(resourceName: "graph-icon"))
        layerVC.tabBarItem = UITabBarItem(title: "Layers", image: #imageLiteral(resourceName: "layer-bar-icon"), selectedImage: #imageLiteral(resourceName: "layer-bar-icon"))
        modelsVC.tabBarItem = UITabBarItem(title: "Your Models", image: #imageLiteral(resourceName: "layer-bar-icon"), selectedImage: #imageLiteral(resourceName: "layer-bar-icon"))
        lessonsVC.tabBarItem = UITabBarItem(title: "Lessons", image: #imageLiteral(resourceName: "layer-bar-icon"), selectedImage: #imageLiteral(resourceName: "layer-bar-icon"))
        viewControllers = [graphBuilderVC, layerVC, modelsVC, lessonsVC]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "deploy" {
            let vc = segue.destination as! DeployViewController
            var model: MLModel!
            do {
                let compiledURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(modelsVC.selectedModelName)
                model = try MLModel(contentsOf: compiledURL)
                vc.modelInputDimension = (28, 28, 1) // FIXME
            } catch {
                model = MNIST().model
                vc.modelInputDimension = (28, 28, 1)
                print("Error getting compiled model URL, using MNIST default.")
            }
            
            vc.model = model
        }
    }

}
