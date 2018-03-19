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

enum TestEndpoint: Endpoint {
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

struct LoremRequest: Request {
    typealias Response = [String]
    
    let endpoint: Endpoint = TestEndpoint.loremIpsum
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
                let fileURL = try NetworkDownloadTask(url: "https://picsum.photos/1024/1024").await()
                let fileimage = UIImage(contentsOfFile: fileURL.path)
                
                Task.async(executionQueue: .main) {
                    self.imageView.image = fileimage
                }
                
                let jsonUpload: JSONDictionary = try NetworkUploadTask(url: "https://httpbin.org/post", fileURL: fileURL, data: nil).await()
                print(jsonUpload)

                let json: JSONDictionary = try NetworkDataTask(url: "https://httpbin.org/uuid").await()
                print(json)
                
                let endPoint = NetworkEndpoint(baseUrl: "https://baconipsum.com", path: "/api", parameters: ["type": "meat-and-filler"])
                var text: [String] = try NetworkDataTask(request: NetworkRequest(endpoint: endPoint)).await()
                print(text)
                
                let request = NetworkRequest(endpoint: TestEndpoint.loremIpsum, ignoreCache: true, retryCount: 2)
                text = try NetworkDataTask(request: request).await()
                print(text)
                
                text = try NetworkDataTask(request: LoremRequest()).await()
                print(text)
                
                let textAnother = try NetworkDataTask<[String]>(request: LoremRequest()).await()
                print(textAnother)
                
                let imageEndPoint = NetworkEndpoint(baseUrl: "https://picsum.photos", path: "/2048/2048")
                let imageData = try NetworkDataTask<Data>(request: NetworkRequest(endpoint: imageEndPoint)).await()
                
                let multiPartEndpoint = NetworkEndpoint(baseUrl: "https://httpbin.org", path: "/post", method: .post, parameters: [:])
                let multiPartRequest = NetworkMultipartFormDataRequest(endpoint: multiPartEndpoint,
                                                                       data: imageData,
                                                                       mimeType: "jpeg",
                                                                       filename: "MyImage")
                
                let uploadTask = NetworkMultipartFormDataUploadTask<Data>(request: multiPartRequest)
                
                DispatchQueue.main.sync {
                    self.progressView.observedProgress = uploadTask.progress
                }
                
                let resultData = try uploadTask.await()
                print(resultData)
                
                let directory = NSTemporaryDirectory()
                let fileName = NSUUID().uuidString
                
                let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
                let downloadRequest = NetworkRequest(endpoint: imageEndPoint)
                let downloadTask = NetworkDownloadTask(request: downloadRequest, downloadDestination: fullURL!)
                
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

