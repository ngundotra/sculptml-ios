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
            view.center = CGPoint(x: frame.minY + view.frame.width / 2.0, y: view.center.y)
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
}
