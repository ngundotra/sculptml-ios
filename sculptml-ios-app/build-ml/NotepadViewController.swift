//
//  NotepadViewController.swift
//  build-ml
//
//  Created by Felipe Campos on 11/29/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreML
import Vision

class NotepadViewController: UIViewController {
    
    var lastPoint = CGPoint.zero
    var color = UIColor.white
    var brushWidth: CGFloat = 40.0
    var opacity: CGFloat = 1.0
    let y: CGFloat = 100.0
    var width: CGFloat = -100.0 // Not actual value (see ViewDidLoad)
    let edgiX: CGFloat  = 7.5
    var swiped = false
    var model: VNCoreMLModel!
    
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var classificationLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        width = view.frame.width - 15.0
        // Create MNIST model
        guard let model = try? VNCoreMLModel(for: MNIST().model) else {
            fatalError("Failed to load MNIST model")
        }
        self.model = model
        resetPressed(1.0)
    }
    
    @IBAction func classifyBoxDigit(_ sender: Any) {
        
        // Capture an Image in the area
        UIGraphicsBeginImageContext(CGSize(width: width, height: width))
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.translateBy(x: -edgiX, y: -y)
        mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
        let tmpImg = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        predictAndChangeLabel(image: tmpImg)
        // If you want to allow users to visualize the part of canvas being predicted on....
        // then uncomment the portion below
        //    let activity = UIActivityViewController(activityItems: [tmpImg],
        //                                            applicationActivities: nil)
        //    present(activity, animated: true)
    }
    
    func predictAndChangeLabel(image: UIImage) {
        // Classify the image
        let classificationRequest = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topClassification = results.first else {
                    self?.classificationLabel.text = "Failed to classify"
                    return
            }
            
            DispatchQueue.main.async {
                print("VNClassificationObservation identifier: \(topClassification.identifier)")
                print("Type of topClass: \(type(of: topClassification))")
                self?.classificationLabel.text = topClassification.identifier // "\(classifications.first)"
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: CIImage(cgImage: image.cgImage!))
            do {
                try handler.perform([classificationRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func drawBox(leftX: CGFloat, topY: CGFloat, width: CGFloat) {
        drawLine(from: CGPoint(x: leftX, y: topY), to: CGPoint(x: leftX + width, y: topY), imageView: mainImageView)
        drawLine(from: CGPoint(x: leftX, y: topY + width), to: CGPoint(x: leftX + width, y: topY + width), imageView: mainImageView)
        drawLine(from: CGPoint(x: leftX, y: topY), to: CGPoint(x: leftX, y: topY + width), imageView: mainImageView)
        drawLine(from: CGPoint(x: leftX + width, y: topY), to: CGPoint(x: leftX + width, y: topY + width), imageView: mainImageView)
    }
    
    // MARK: - Actions
    @IBAction func resetPressed(_ sender: Any) {
        // Set main view image to black
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setFillColor(UIColor.black.cgColor)
        context.fill(view.frame)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let tmp = brushWidth
        brushWidth = 2.0
        drawBox(leftX: edgiX, topY: y, width: width)
        brushWidth = tmp
    }
    
    
    @IBAction func sharePressed(_ sender: Any) {
        guard let image = mainImageView.image else {
            return
        }
        
        let activity = UIActivityViewController(activityItems: [image],
                                                applicationActivities: nil)
        present(activity, animated: true)
    }
    
    @IBAction func pencilPressed(_ sender: UIButton) {
        guard let pencil = Pencil(tag: sender.tag) else {
            return
        }
        
        color = pencil.color
        
        if pencil == .eraser {
            opacity = 1.0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = false
        lastPoint = touch.location(in: view)
        //    print(lastPoint)
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint, imageView: UIImageView? = nil) {
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let imageView = imageView ?? tempImageView
        imageView!.image?.draw(in: view.bounds)
        
        // 2
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        
        // 3
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)
        
        // 4
        context.strokePath()
        
        // 5
        imageView!.image = UIGraphicsGetImageFromCurrentImageContext()
        if imageView! == tempImageView {
            tempImageView.alpha = opacity
        }
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        // 6
        swiped = true
        let currentPoint = touch.location(in: view)
        drawLine(from: lastPoint, to: currentPoint)
        
        // 7
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLine(from: lastPoint, to: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
}
