//
//  Conv2DAlertViewController.swift
//  build-ml
//
//  Created by Noah Gundotra on 7/12/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class Conv2DAlertViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, ModelLayerViewControllerProtocol {

    @IBOutlet weak var encasingView: UIView!
    // Kernel
    @IBOutlet weak var kp1: UIPickerView!
    @IBOutlet weak var kp2: UIPickerView!
    let kernelMax = 32
    @IBOutlet weak var filters: UIPickerView!
    let filtersMax = 256
    // Strides
    @IBOutlet weak var sp1: UIPickerView!
    @IBOutlet weak var sp2: UIPickerView!
    let stridesMax = 7
    // Padding
    @IBOutlet weak var pp1: UIPickerView! // 0 indexed
    @IBOutlet weak var pp2: UIPickerView! // 0 indexed
    let paddingMax = 128
    var precastLayer: ModelLayer?
    var modelLayer: SPConv2DLayer? {
        return precastLayer as? SPConv2DLayer
    }
    var graphBuilder: GraphBuilderViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        encasingView.layer.borderWidth = 2.0
        
        for picker in [kp1, kp2, sp1, sp2, pp1, pp2, filters] {
            picker?.delegate = self
            picker?.dataSource = self
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // The plus one is to convert from the indices back
    // Everything is buffered to avoid starting from 0
    @IBAction func saveTouch(_ sender: Any) {
        if let convLayer = modelLayer {
            let kh = kp1.selectedRow(inComponent: 0)
            let kw = kp2.selectedRow(inComponent: 0)

            let sh = sp1.selectedRow(inComponent: 0)
            let sw = sp2.selectedRow(inComponent: 0)

            let ph = pp1.selectedRow(inComponent: 0)
            let pw = pp2.selectedRow(inComponent: 0)

            let fs = filters.selectedRow(inComponent: 0)
            
            let dict = ["kH": kh + 1, "kW": kw + 1, "sH": sh + 1, "sW": sw + 1,
                        "pH": ph, "pW": pw, "filters": fs + 1]
            convLayer.updateParams(params: dict)
        }
        graphBuilder?.updateGraphValidity()
        dismiss(animated: true, completion: nil)
    }
    
    // Read from the conv2d layer
    override func viewWillAppear(_ animated: Bool) {
        if let convLayer = modelLayer {
            let (kh, kw) = convLayer.kernelSize
            let (sh, sw) = convLayer.stride
            let fs = convLayer.filters
            let (ph, pw) = convLayer.padding
            
            kp1.selectRow(kh - 1, inComponent: 0, animated: false)
            kp2.selectRow(kw - 1, inComponent: 0, animated: false)
            sp1.selectRow(sh - 1, inComponent: 0, animated: false)
            sp2.selectRow(sw - 1, inComponent: 0, animated: false)
            pp1.selectRow(ph, inComponent: 0, animated: false)
            pp2.selectRow(pw, inComponent: 0, animated: false)
            filters.selectRow(fs - 1, inComponent: 0, animated: false)
        }
        
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == kp1 || pickerView == kp2 {
            return kernelMax
        } else if pickerView == sp1 || pickerView == sp2 {
            return stridesMax
        } else if pickerView == pp1 || pickerView == pp2 {
            return paddingMax
        } else if pickerView == filters {
            return filtersMax
        } else {
            fatalError("Bitch the fuck happened to my pickers???")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pp1 || pickerView == pp2 {
            return "\(row)"
        }
        return "\(row + 1)"
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
