//
//  ReachBackend.swift
//  build-ml
//
//  Created by Srisai Mandava on 10/8/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import Foundation
import SystemConfiguration

open class Reach {
    
    /// Pings 'www.google.com' for status response>
    /// - returns: 'true' if boolean variable 'Status' returns 200 or 403, else returns 'false'
    
    class func isConnectedToNetwork() -> (connected: Bool, code: Int) {
        let semaphore = DispatchSemaphore(value: 0)
        let url = URL(string: "https://www.google.com")!
        
        var network: Bool = false
        var timeout: Bool = true
        var status: URLResponse?
        
        var code: Int = 200
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            status = response
            // Log().DLog(String(response))
            timeout = false
            semaphore.signal()
        })
        
        task.resume()
        
        // times out NSURLSession task after 10 seconds
        _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(UInt64(10) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC))
        
        if !timeout {
            if let httpResponse = status as? HTTPURLResponse {
                code = httpResponse.statusCode
                if code == 200 || code == 403 { // are there other possible status codes?
                    network = true
                } else {
                    print("Server status code was invalid (returned \(code))")
                }
            } else {
                code = -1
                print("Server response was invalid.")
            }
        } else {
            code = -1
            print("Server response timed out.")
        }
        
        return (connected: network, code: code)
    }
    
    /// Checks if the device is able to connect to the internet via a WiFi connection.
    
    class func isConnectedToWifi() -> Bool {
        var reachability: Reachability
        var wifi: Bool = false
        
        reachability = Reachability.init()!
        
        if reachability.isReachableViaWiFi {
            // Wi-Fi is enabled
            wifi = true
        } else {
            // Wifi not enabled
            wifi = false
        }
        
        return wifi
    }
    
    /// Checks if the device is able to connect to the internet via a cellular (WWAN) connection.
    
    class func isConnectedToCellular() -> Bool {
        let reachability: Reachability
        var cellular: Bool = false
        
        reachability = Reachability.init()!
        
        if reachability.isReachableViaWWAN {
            // Cellular is enabled
            cellular = true
        } else {
            // Cellular not enabled
            cellular = false
        }
        
        return cellular
    }
    
}



