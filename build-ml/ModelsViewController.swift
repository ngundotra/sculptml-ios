//
//  ModelsViewController.swift
//  build-ml
//
//  Created by Felipe Campos on 11/24/18.
//  Copyright © 2018 Noah Gundotra. All rights reserved.
//

import UIKit
import SnapKit
import CoreML

class ModelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var datasetNames: [String] = ["MNIST"]
    var modelNames: [String] = []
    var modelURLs: [URL] = []
    var tableView: UITableView!
    var selectedModelName: String = ""
    
    private let refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME: if MNIST.mlmodel is not in docs, add it?
        // TODO: add modelGET button (make sure not to download duplicates)
        
        let modelURLs = Utils.listAppSupportDirectory()
        for url in modelURLs {
            let subPaths = url.pathComponents
            modelNames.append(subPaths.last!)
        }
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshController
        } else {
            tableView.addSubview(refreshController)
        }
        
        // Configure Refresh Control
        refreshController.addTarget(self, action: #selector(refreshModelData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshModelData(_ sender: Any) {
        // Fetch Model Data
        if let modelUrl = modelGET(modelName: "bigDickCNN") {
            print("Model GET successful.")
            var compiledUrl: URL!
            do {
                compiledUrl = try MLModel.compileModel(at: modelUrl)
            } catch {
                print("Unable to compile model.")
                return
            }
            
            // find the app support directory
            let fileManager = FileManager.default
            let appSupportDirectory = try! fileManager.url(for: .applicationSupportDirectory,
                                                           in: .userDomainMask, appropriateFor: compiledUrl, create: true)
            // create a permanent URL in the app support directory
            let permanentUrl = appSupportDirectory.appendingPathComponent(compiledUrl.lastPathComponent)
            do {
                // if the file exists, replace it. Otherwise, copy the file to the destination.
                if fileManager.fileExists(atPath: permanentUrl.absoluteString) {
                    _ = try fileManager.replaceItemAt(permanentUrl, withItemAt: compiledUrl)
                } else {
                    try fileManager.copyItem(at: compiledUrl, to: permanentUrl)
                }
            } catch {
                print("Error during copy: \(error.localizedDescription)")
            }
            
            let subPaths = modelUrl.pathComponents
            modelNames.append(subPaths.last!)
        } else {
            print("Model GET unsuccessful.")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshController.endRefreshing()
        }
    }
    
    /**
     - returns:
     the URL of a local .mlmodel
     */
    func modelGET(modelName: String) -> URL? { // make a button for this and recognize all saved models in DEPLOY mode
        var modelURL: URL?
        // FIXME: use a semaphore to block until model is received
        let semaphore = DispatchSemaphore(value: 0)
        getMLModel("http://latte.csua.berkeley.edu:5000/get-model", parameters: ["model_name": modelName]) { fileURL, error in
            if fileURL == nil || error != nil {
                print(error ?? "something went wrong")
                semaphore.signal()
                return
            }
            
            modelURL = fileURL
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(UInt64(10) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC))
        
        return modelURL
    }
    
    // TODO: make so models are named according to JSON spec and date of creation
    // TODO: make get request for progress
    // TODO: make buttons for all this jank
    
    func getMLModel(_ url: String, parameters: [String: String], completion: @escaping (URL?, Error?) -> Void) {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print(response as Any)
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    completion(nil, error)
                    return
            }
            
            var fileURL: URL!
            do {
                fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(parameters["model_name"] ?? "test").mlmodel")
            } catch {
                print("LOL this shit fucked.")
                completion(nil, nil)
                return
            }
            
            do {
                try data.write(to: fileURL, options: Data.WritingOptions.atomic)
            } catch {
                print("Write failed.")
                completion(nil, nil)
                return
            }
            // let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            completion(fileURL, nil)
        }
        task.resume()
    } 
    
    // MARK: Protocols
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(modelNames[indexPath.row])")
        
        selectedModelName = modelNames[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        
        DispatchQueue.main.async {
            (self.tabBarController as! MainViewController).performSegue(withIdentifier: "deploy", sender: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(modelNames[indexPath.row])"
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
}
