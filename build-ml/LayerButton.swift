//
//  LayerButton.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/28/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class LayerButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    init(layerImgName: String) {
        super.init(frame: CGRect(x: 80.0, y: 200.0, width: 200.0, height: 200.0))
        print(buttonType)
        self.setBackgroundImage(UIImage(named: layerImgName), for: .normal)
        self.setBackgroundImage(UIImage(named: layerImgName), for: .disabled)

        self.setImage(UIImage(named: layerImgName), for: .reserved)
        self.setImage(UIImage(named: layerImgName), for: .disabled)
        self.setImage(UIImage(named: layerImgName), for: .focused)
        self.setImage(UIImage(named: layerImgName), for: .highlighted)
        self.setImage(UIImage(named: layerImgName), for: .selected)
        self.setTitle(layerImgName, for: .normal)
        self.backgroundColor = UIColor.white
        self.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
