//
//  Utils.swift
//  build-ml
//
//  Created by Noah Gundotra on 6/28/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit
import Photos

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}

class Utils: NSObject {
    
    static func checkCameraPermission() -> Bool {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access granted by user.")
            return true
        case .notDetermined:
            print("Authorization undetermined until now.")
            var auth = false
            let semaphore = DispatchSemaphore(value: 0)
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("Status is \(newStatus)")
                auth = newStatus == PHAuthorizationStatus.authorized
                if auth {
                    print("Authorized.")
                }
                semaphore.signal()
            })
            
            _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(UInt64(10) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC))
            return auth
        case .restricted:
            print("User does not have access to photo album.")
            return false
        case .denied:
            print("User has denied permission.")
            return false
        default:
            return false
        }
    }
    
    static func listDocumentsDirectory() -> [URL] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            return fileURLs
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            return []
        }
    }

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
