//
//  ModelsViewController.swift
//  build-ml
//
//  Created by Felipe Campos on 11/24/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit
import SnapKit

class ModelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var modelNames: [String] = []
    private var modelURLs: [URL] = []
    private var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME: if MNIST.mlmodel is not in docs, add it?
        // TODO: add modelGET button (make sure not to download duplicates)
        
        let modelURLs = Utils.listDocumentsDirectory()
        for url in modelURLs {
            let subPaths = url.pathComponents
            modelNames.append(subPaths.last!)
        }
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(modelNames[indexPath.row])")
        // TODO: goto notepad or camera roll and select images to classify on
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(modelNames[indexPath.row])"
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
