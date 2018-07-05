//
//  InputLayerAlertViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 7/4/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class InputLayerAlertViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // Honestly I should have 0 indexed these
    @IBOutlet weak var encasingView: UIView!
    @IBOutlet weak var picker1: UIPickerView!
    @IBOutlet weak var picker2: UIPickerView!
    @IBOutlet weak var picker3: UIPickerView!
    
    // would ideally have ~2048, but just not easy right now
    let maxIn = 512
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set a border width bc I didn't know how to do this in the storyboard
        encasingView.layer.borderWidth = 2.0
        
        // Do any additional setup after loading the view.
        for picker in [picker1, picker2, picker3] {
            picker?.dataSource = self
            picker?.delegate = self
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return maxIn
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
