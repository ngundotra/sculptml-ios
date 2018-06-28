//
//  MainViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/26/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    let graphBuilderVC = GraphBuilderViewController()
    let layerVC = ViewController()
    
    var userModel: GraphModel!
    
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
        graphBuilderVC.tabBarItem = UITabBarItem(title: "Graph", image: nil, selectedImage: nil)
        layerVC.tabBarItem = UITabBarItem(title: "Layers", image: nil, selectedImage: nil)
        viewControllers = [graphBuilderVC, layerVC]
        
    }
    
    func updateGraphBuilder() {
        graphBuilderVC.updateView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
