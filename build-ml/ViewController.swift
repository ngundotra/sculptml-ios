//
//  ViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/25/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    // Example layers to fill out the table
    var layerNames = ["Input", "Dense", "Conv2D"]
    var layersInfo = ["Specifies input to models", "Simplest deep transform", "Transform that learns spatial relations",
                      "Transform that learns sequential relations", "Replicates data to make image 2x larger"]
    var layerPhotos = ["inputlayer", "denselayer", "conv2dlayer"]
    
    let cellID = "layerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        
        tableView.delegate = self
        tableView.dataSource = self
        // Setup Table View
        makeTableView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeTableView() {
        tableView.register(LayerTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.isHidden = false
    }
    
    // Handling layer selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.cellForRow(at: indexPath)
        
        print("selected row at \(indexPath.row)")
        
//        layerSelected(self.layerNames[indexPath.row])
    }
    
    // Required: Gives the number of rows in a "section"
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layerNames.count
    }
    
    // Make cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        if let cell = cell as? LayerTableViewCell {
            print("cell already created")
            //            (lCell.viewsDict["message"] as! UILabel).text = "m: \(indexPath.row)"
            //            (lCell.viewsDict["labTime"] as! UILabel).text = "t: time"
        } else {
            print("creating cell")
            cell = LayerTableViewCell(style: .default, reuseIdentifier: cellID)
        }
        let layerCell = cell as! LayerTableViewCell
        layerCell.layerName.text = layerNames[indexPath.row]
        print(layerCell.layerName)
        layerCell.layerDesc.text = layersInfo[indexPath.row]
        layerCell.layerImg.image = UIImage(imageLiteralResourceName: layerPhotos[indexPath.row])
        layerCell.isHidden = false
        return layerCell
    }

    @objc func layerSelected(_ layerName: String) -> Void {
        // Shorthand for actually writing to a model...
//        graphBuilderVC.addLayer(layerName: layerName)
//        self.tabBarController?.present(graphBuilderVC, animated: true, completion: nil)
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row < layerNames.count {
//            return CGFloat(default.CellHeight)
//        } else {
//            return CGFloat(25.0)
//        }
//    }

}

