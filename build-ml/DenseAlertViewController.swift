//
//  DenseAlertViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 7/12/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class DenseAlertViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  

    @IBOutlet weak var encasingView: UIView!
    @IBOutlet weak var unitsPicker: UIPickerView!
    
    let unitsMax = 512
    var modelLayer: SPDenseLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        encasingView.layer.borderWidth = 2.0
        encasingView.clipsToBounds = true
        
        unitsPicker.delegate = self
        unitsPicker.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let modelLayer = modelLayer {
            let (_, current) = modelLayer.weightShape
            unitsPicker.selectRow(current, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func saveTouch(_ sender: Any) {
        if let modelLayer = modelLayer {
            let prev = modelLayer.inputShape.d2
            let units = unitsPicker.selectedRow(inComponent: 0)
            modelLayer.weightShape = (prev, units)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unitsMax
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
