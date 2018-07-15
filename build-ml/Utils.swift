//
//  Utils.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/28/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit

class Utils: NSObject {

    static func clipToBounds(view: UIView, frame: CGRect) {
        // Right
        if view.frame.maxX >= frame.maxX {
            view.center = CGPoint(x: frame.maxX - view.frame.width / 2.0, y: view.center.y)
        }
        // Left
        if view.frame.minX <= frame.minX {
            view.center = CGPoint(x: frame.minY + 20.0, y: view.center.y)
        }
        // Top
        if view.frame.minY <= frame.minY {
            view.center = CGPoint(x: view.center.x, y: frame.minY + view.frame.height / 2.0)
        }
        // Bottom
        if view.frame.maxY >= frame.maxY {
            view.center = CGPoint(x: view.center.x, y: frame.maxY - view.frame.height / 2.0)
        }
    }
    
    static func clipToBounds(view: CGRect, frame: CGRect) -> CGRect {
        var newView: CGRect = view
        // Right
        if view.maxX >= frame.maxX {
            newView = view.offsetBy(dx: -1.0, dy: 0.0)
        }
        // Left
        if view.minX <= frame.minX {
            newView = view.offsetBy(dx: 1.0, dy: 0.0)
        }
        // Top
        if view.minY <= frame.minY {
            newView = view.offsetBy(dx: 0.0, dy: 1.0)
        }
        // Bottom
        if frame.maxY >= frame.maxY {
            newView = view.offsetBy(dx: 0.0, dy: -1.0)
        }
        return newView
    }
    
    // Slides all layers from [idx, layers.count - 1] up so they touch
    static func slideUp(layers: [LayerButton], from idx: Int, buffer: Double) {
        if idx >= layers.count - 1 { return }
        
        var bot = layers[idx].frame.maxY // Bottom of screen is maxY
        for i in (idx+1)...(layers.count - 1) {
            var button = layers[i]
            let finalDestination = bot + CGFloat(buffer)
            var anim = CABasicAnimation(keyPath: "position")
            anim.duration = 0.75
            anim.fromValue = CGPoint(x: button.center.x, y: button.center.y)
            anim.toValue = CGPoint(x: button.center.x, y: finalDestination)
            button.layer.add(anim, forKey: "Position")
            button.center = CGPoint(x: button.center.x, y: finalDestination)
            bot = button.frame.maxY
        }
    }
}
