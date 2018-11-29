//
//  DenseAlertViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 7/12/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class DropoutAlertViewController: UIViewController, ModelLayerViewControllerProtocol {
  
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateSlider: UISlider!
    
    @IBOutlet weak var encasingView: UIView!
    var precastLayer: ModelLayer?
    var modelLayer: SPDropoutLayer? {
        return precastLayer as? SPDropoutLayer
    }
    var graphBuilder: GraphBuilderViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        encasingView.layer.borderWidth = 2.0
        encasingView.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let modelLayer = modelLayer {
            let current = modelLayer.rate
            rateLabel.text = "\(current)"
            rateSlider.value = Float(current)
        }
    }
    
    // Avoid letting user set stuff to 0
    @IBAction func saveTouch(_ sender: Any) {
        if let modelLayer = modelLayer {
            // Only have 2 floating pts of precision
            let dict = ["rate": Int(100 * rateSlider.value)]
            modelLayer.updateParams(params: dict)
        }
        graphBuilder?.updateGraphValidity()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func sliderUpdate(_ sender: Any) {
        rateLabel.text = "\(Double(Int(100*rateSlider.value))/100)"
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
