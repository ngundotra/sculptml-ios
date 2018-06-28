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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! LayerTableViewCell
        
        // Pass information from the database to the custom tableview cell
        cell.layerName.text = layerNames[indexPath.row]
        cell.layerDesc.text = layersInfo[indexPath.row]
        cell.layerImg.image = UIImage(imageLiteralResourceName: layerPhotos[indexPath.row])
        cell.isHidden = false
        return cell
    }

    // How to pass information back to graph?
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

