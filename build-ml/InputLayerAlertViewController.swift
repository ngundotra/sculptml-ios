//
//  InputLayerAlertViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 7/4/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class InputLayerAlertViewController: UIViewController {

    // Honestly I should have 0 indexed these
    @IBOutlet weak var encasingView: UIView!
    @IBOutlet weak var picker1: UIPickerView!
    @IBOutlet weak var picker2: UIPickerView!
    @IBOutlet weak var picker3: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set a border width bc I didn't know how to do this in the storyboard
        encasingView.layer.borderWidth = 2.0
        // Do any additional setup after loading the view.
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
