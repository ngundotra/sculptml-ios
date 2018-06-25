//
//  ViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/25/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // Example layers to fill out the table
    var layersAvailable = ["Input", "Dense", "Conv2D"]
    var layerPhotos = ["inputlayer", "denselayer", "conv2dlayer"]
    var layersInfo = ["Specifies input to models", "Simplest deep transform", "Transform that learns spatial relations",
                      "Transform that learns sequential relations", "Replicates data to make image 2x larger"]
    
    var layerViewDelegate: LayerTableViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        layerViewDelegate = LayerTableViewController(names: layersAvailable, photos: layerPhotos)
        tableView.dataSource = layerViewDelegate
        tableView.delegate = layerViewDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

