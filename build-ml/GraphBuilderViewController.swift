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
    let backButton = UIButton()
    let debugHeader: String = "Debug Label:"
    
    // Things to be updated in response to actions
    var tableVC = UIViewController()
    
    init(tableVC: UIViewController) {
        // Do some cool persistence stuff here (?)
        
        self.tableVC = tableVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
        
        // Set Back Button
        makeBackButton()
        
        // Make sure to display data loaded from persistence
        updateView()
    }
    
    func makeTitleLabel() {
        viewTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(60.0)
            make.centerX.equalToSuperview()
        }
        viewTitle.font = UIFont.boldSystemFont(ofSize: 35.0)
        viewTitle.text = "Graph Builder"
    }
    
    func updateView() {
        updateDebugLabel()
    }
    
    fileprivate func updateDebugLabel() {
        let tabVC: MainViewController = tabBarController as! MainViewController
        
        if let userModel = tabVC.userModel {
            debugLabel.text = userModel.convertLayersToString()
        }
    }
    
    fileprivate func makeDebugLabel() {
        debugLabel.snp.makeConstraints{(make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20.0)
            make.height.greaterThanOrEqualTo(20.0)
        }
        debugLabel.numberOfLines = 0
        debugLabel.text = debugHeader
    }
    
    fileprivate func makeBackButton() {
        backButton.setTitle("Layers", for: .normal)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.addTarget(self, action: #selector(self.backToLayer), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // Currently unused
    @objc func backToLayer() {
        self.navigationController?.popViewController(animated: true)
        print("nav button has been hit")
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
