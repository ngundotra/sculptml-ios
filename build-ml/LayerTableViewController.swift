//
//  LayerTableViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/25/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class LayerTableViewController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var layerNames: [String]
    var layerDescriptions: [String]?
    var photos: [String]
    // Used to connect to Prototype Cells
    let cellID = "layerCell"
    let defaultCellHeight = 70
    
    // Init data from the OG View Controller
    init(names: [String], photos: [String]) {
        layerNames = names
        self.photos = photos
    }
    
    init(names: [String], photos: [String], descriptions: [String]) {
        layerNames = names
        self.photos = photos
        layerDescriptions = descriptions
        
    }
    
    // Required: Gives the number of rows in a "section"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layerNames.count
    }
    
    // Required: Creates cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if let cell = cell as? LayerTableViewCell {
            cell.layerName.text = layerNames[indexPath.row]
            cell.layerImg.image = UIImage(imageLiteralResourceName: photos[indexPath.row])
//            (lCell.viewsDict["message"] as! UILabel).text = "m: \(indexPath.row)"
//            (lCell.viewsDict["labTime"] as! UILabel).text = "t: time"
        }
        
        return cell
    }
    
    // User selects row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        print("selected row at \(indexPath.row)")
        if let cell = cell {
            print(cell.subviews)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < layerNames.count {
            return CGFloat(defaultCellHeight)
        } else {
            return CGFloat(25.0)
        }
    }

}
