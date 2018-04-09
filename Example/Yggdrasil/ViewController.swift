//
//  ViewController.swift
//  Nätverk
//
//  Created by Thomas Sempf on 2018-02-23.
//  Copyright © 2018 Stendahls AB. All rights reserved.
//

import UIKit
import Yggdrasil
import Taskig

enum BaconIpsumEndpoint: Endpoint {
    case loremIpsum
    case fail
    
    var baseUrl: String { return "https://baconipsum.com" }
    
    var path: String {
        switch self {
        case .loremIpsum:
            return "/api"
        case .fail:
            return "/foobar"
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .loremIpsum:
            return ["type": "meat-and-filler"]
        default:
            return [:]
        }
    }
}

enum HttpBinEndpoint: Endpoint {
    case get
    case post
    case uuid
    
    var baseUrl: String { return "https://httpbin.org" }
    
    var path: String {
        switch self {
        case .get: return "/get"
        case .post: return "/post"
        case .uuid: return "/uuid"
        }
    }
}

struct LoremRequest: Request {
    let endpoint: Endpoint = BaconIpsumEndpoint.loremIpsum
}

class ViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task.async {
            do {
                let retryRequest = NetworkRequest(endpoint: NetworkEndpoint(baseUrl: "blah", path: "blah"), ignoreCache: true, retryCount: 3)
                let _ = try? DataTask<Data>(request: retryRequest).await()
                
                let fileURL = try DownloadTask(url: "https://picsum.photos/1024/1024").await()
                let fileimage = UIImage(contentsOfFile: fileURL.path)
                
                Task.async(executionQueue: .main) {
                    self.imageView.image = fileimage
                }
                
                let jsonUpload: JSONDictionary = try UploadTask(url: "https://httpbin.org/post", dataToUpload: .file(fileURL)).await()
                print(jsonUpload)
                
                let json: JSONDictionary = try DataTask(url: "https://httpbin.org/uuid").await()
                print(json)
                
                let endPoint = NetworkEndpoint(baseUrl: "https://baconipsum.com", path: "/api", parameters: ["type": "meat-and-filler"])
                var text: [String] = try DataTask(request: NetworkRequest(endpoint: endPoint)).await()
                print(text)
                
                let request = NetworkRequest(endpoint: BaconIpsumEndpoint.loremIpsum, ignoreCache: true, retryCount: 2)
                text = try DataTask(request: request).await()
                print(text)
                
                text = try DataTask(request: LoremRequest()).await()
                print(text)
                
                let textAnother = try DataTask<[String]>(request: LoremRequest()).await()
                print(textAnother)
                
                let imageEndPoint = NetworkEndpoint(baseUrl: "https://picsum.photos", path: "/2048/2048")
                let imageData = try DataTask<Data>(request: NetworkRequest(endpoint: imageEndPoint)).await()
                
                let multiPartEndpoint = NetworkEndpoint(baseUrl: "https://httpbin.org", path: "/post", method: .post, parameters: [:])
                let multiPartRequest = NetworkMultipartFormDataRequest(endpoint: multiPartEndpoint,
                                                                       data: imageData,
                                                                       mimeType: "jpeg",
                                                                       filename: "MyImage")
                
                let uploadTask = MultipartFormDataUploadTask<Data>(request: multiPartRequest)
                
                DispatchQueue.main.sync {
                    self.progressView.observedProgress = uploadTask.progress
                }
                
                let resultData = try uploadTask.await()
                print(resultData)
                
                let directory = NSTemporaryDirectory()
                let fileName = NSUUID().uuidString
                
                let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
                let downloadRequest = NetworkRequest(endpoint: imageEndPoint)
                let downloadTask = DownloadTask(request: downloadRequest, downloadDestination: fullURL!)
                
                DispatchQueue.main.sync {
                    self.progressView.observedProgress = downloadTask.progress
                }
                
                let destinationURL = try downloadTask.await()
                let image = UIImage(contentsOfFile: destinationURL.path)
                
                Task.async(executionQueue: .main) {
                    self.imageView.image = image
                }
                
                print("DONE!!!")
            } catch {
                print("ERROR: \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

