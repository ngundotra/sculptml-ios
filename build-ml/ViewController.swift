//
//  ViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/25/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

// Really the LayerTableVC
class ViewController: UITableViewController {
    // Example layers to fill out the table
    var layerNames = ["Input", "Dense", "Conv2D"]
    var layersInfo = ["Specifies input to models", "Simplest deep transform", "Transform that learns spatial relations",
                      "Transform that learns sequential relations", "Replicates data to make image 2x larger"]
    var layerPhotos = ["inputlayer", "denselayer", "conv2dlayer"]
    var layerHeight = [false, true, false]
    
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
        let cell = tableView.cellForRow(at: indexPath) as! LayerTableViewCell
//        cell.snp.updateConstraints { (make) -> Void in
//            make.center.equalTo(cell.contentView.snp.center)
//            make.centerY.equalTo(cell.contentView.snp.centerY)
//            make.width.equalTo(cell.contentView.snpwidth)
//            make.height.equalTo(cell.contentView.snp.height)
//        }
        self.updateViewConstraints()
        super.updateViewConstraints()
        
        let tabVC: MainViewController = self.tabBarController as! MainViewController
        let layerName = layerNames[indexPath.row]
        
        // Add the layer to the model
        tabVC.userModel.addLayer(layer: layerName)
        // Need some animation here!!
        print("\n\nNeed some animation to switch between tab views...\nCurrently too rough\n")
        tabVC.selectedViewController = tabVC.graphBuilderVC
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cell = tableView.cellForRow(at: indexPath)
//        let height = cell!.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
//
//        if layerHeight[indexPath.row] {
//            return 120.0
//        } else {
//            return height
//        }
//    }
    
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
        
//        cell.snp.makeConstraints{ (make) -> Void in
//            make.left.greaterThanOrEqualTo(self.view)
//            make.right.lessThanOrEqualTo(self.view)
//        }
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

