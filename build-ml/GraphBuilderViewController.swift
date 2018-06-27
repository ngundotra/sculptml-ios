//
//  GraphBuilderViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/26/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class GraphBuilderViewController: UIViewController {
    let debugLabel = UILabel()
    let viewTitle = UILabel()
    var tableVC = UIViewController()
    var layers = [String]()
    let debugHeader: String = "Debug Label:"
    
    init(tableVC: UIViewController) {
        // Do some cool persistence stuff here (?)
        
        self.tableVC = tableVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(debugLabel)
        view.addSubview(viewTitle)
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        // Title Label
        makeTitleLabel()
        
        // Debug Label
        makeDebugLabel()
        
        // Make sure to display data loaded from persistence
        updateLayers()
    }
    
    func makeTitleLabel() {
        viewTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(40.0)
            make.centerX.equalToSuperview()
        }
        viewTitle.font = UIFont.boldSystemFont(ofSize: 35.0)
        viewTitle.text = "Graph Builder"
    }
    
    func makeDebugLabel() {
        debugLabel.snp.makeConstraints{(make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20.0)
            make.height.greaterThanOrEqualTo(20.0)
        }
        debugLabel.numberOfLines = 0
        debugLabel.text = debugHeader
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addLayer(layerName: String) {
        // Adds a layer to the debug label
        layers.append(layerName)
    }
    
    func updateLayers() {
        var newText = debugHeader
        for layerName in layers {
            newText = newText + "\n" + layerName
        }
        debugLabel.text = newText
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
