//
//  ViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/25/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tableView: UITableView!
    
    // Example layers to fill out the table
    var layersAvailable = ["Input", "Dense", "Conv2D"]
    var layerPhotos = ["inputlayer", "denselayer", "conv2dlayer"]
    var layersInfo = ["Specifies input to models", "Simplest deep transform", "Transform that learns spatial relations",
                      "Transform that learns sequential relations", "Replicates data to make image 2x larger"]
    
    var layerViewDelegate: LayerTableViewController!
    var graphBuilderVC: GraphBuilderViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        
        graphBuilderVC = GraphBuilderViewController(tableVC: self)
        
        // Setup Table View
        makeTableView()
        layerViewDelegate = LayerTableViewController(names: layersAvailable, photos: layerPhotos, descriptions: layersInfo, rowTapper: layerSelected)
        tableView.dataSource = layerViewDelegate
        tableView.delegate = layerViewDelegate
        tableView.reloadData()
        
        // make bar button item
        makeBarButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeTableView() {
        let rect = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: UIScreen.main.bounds.size
        )
        tableView = UITableView(frame: rect, style: UITableViewStyle.plain)
        tableView.register(LayerTableViewCell.self, forCellReuseIdentifier: "layerCell")
        tableView.isHidden = false
    }

    @objc func layerSelected(_ layerName: String) -> Void {
        graphBuilderVC.addLayer(layerName: layerName)
//        let navCtrl = UINavigationController(rootViewController: graphBuilderVC)
        self.tabBarController?.present(graphBuilderVC, animated: true, completion: nil)
    }
    
    func makeBarButton() {
        self.tabBarItem = UITabBarItem(title: "Layers", image: nil, selectedImage: nil)
    }

}

