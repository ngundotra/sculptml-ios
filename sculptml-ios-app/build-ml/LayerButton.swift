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
        // This looks gross now, also the user should know the name of the layer
        // from the icon, I assume this was for debugging
//        self.setTitle(type(of: modelLayer).name, for: .normal)
        self.isHidden = false
        self.setBackgroundImage(layerImg, for: .normal)
        self.setBackgroundImage(layerImg, for: .disabled)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("LayerButton init(coder:) not implemented")
    }
    
    func updateBorder() {
        if self.modelLayer.validLayer() {
            self.layer.borderWidth = 0.0
        } else {
            self.layer.borderWidth = 2.0
            self.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    // MARK: animations courtesy of stack overflow
    func shake() {
        self.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func shake2() {
        let midX = center.x
        let midY = center.y
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: midX - 10, y: midY)
        animation.toValue = CGPoint(x: midX + 10, y: midY)
        layer.add(animation, forKey: "position")
    }
    
    func rotateShake() {
        self.transform = CGAffineTransform(rotationAngle: CGFloat(60.0 / 180.0 * Double.pi))
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 1.0, animations: {self.alpha = 0.0})
    }

}
