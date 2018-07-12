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
    var modelLayer: ModelLayer
    
    init(actualLayer: ModelLayer) {
        self.modelLayer = actualLayer
        
        super.init(frame: CGRect(x: 80.0, y: 200.0, width: 75.0, height: 75.0))
        print(buttonType)
        
        let layerImg = UIImage(named: type(of: modelLayer).imgName)
        self.setTitle(type(of: modelLayer).name, for: .normal)
        self.isHidden = false
        self.setBackgroundImage(layerImg, for: .normal)
        self.setBackgroundImage(layerImg, for: .disabled)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("LayerButton init(coder:) not implemented")
    }

}
