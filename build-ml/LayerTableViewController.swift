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
    // Used to connect to Prototype Cells
    let cellID = "layerCell"
    
    // Init data from the OG View Controller
    init(names: [String]) {
        layerNames = names
    }
    
    init(names: [String], descriptions: [String]) {
        layerNames = names
        layerDescriptions = descriptions
    }
    
    // Required: Gives the number of rows in a "section"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layerNames.count
    }
    
    // Required: Creates cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if let lCell = cell as? LayerTableViewCell {
            lCell.labUserName.text = layerNames[indexPath.row]
//            (lCell.viewsDict["message"] as! UILabel).text = "m: \(indexPath.row)"
//            (lCell.viewsDict["labTime"] as! UILabel).text = "t: time"
        }
        
        return cell
    }
    
    // User selects row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        print("selected row at \(indexPath.row)")
        print(cell.subviews)
    }

}
