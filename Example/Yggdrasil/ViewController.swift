//
//  ViewController.swift
//  Yggdrasil
//
//  Created by Thomas Sempf on 2017-12-08.
//  Copyright © 2017 Stendahls AB. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import Yggdrasil
import Taskig

class ViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isRunningTests = NSClassFromString("XCTestCase") != nil
        
        guard isRunningTests == false else { return }
        
        Task.async {
            do {
                // Network request with a retry count of 3
                // This will repeat the request up to 3 times in case of errors before giving up and returning.
                // It will also ignore local caches
                let retryRequest = NetworkRequest(endpoint: NetworkEndpoint(baseUrl: "ThisWill", path: "Fail"),
                                                  ignoreCache: true,
                                                  retryCount: 3)
                
                let _ = try? DataTask<Data>(request: retryRequest).await()
                
                // Download task which will return a file URL to the downloaded data
                let fileURL = try DownloadTask(url: "https://picsum.photos/1024/1024").await()
                self.imageView.setImageWith(contentsOfFile: fileURL)
                
                // Upload of a file with json response
                let jsonUpload: JSONDictionary = try UploadTask(url: "https://httpbin.org/post", dataToUpload: .file(fileURL)).await()
                print(jsonUpload)
                
                // Data request with direct URL instead of request and json response                
                let json: JSONDictionary = try DataTask(url: "https://httpbin.org/uuid").await()
                print(json)
                
                // Define API endpoint with parameters
                let endPoint = NetworkEndpoint(baseUrl: "https://baconipsum.com",
                                               path: "/api",
                                               parameters: ["type": "meat-and-filler"])
                
                // Execute data request with text-array response
                let meatAndFillersText: [String] = try DataTask(request: NetworkRequest(endpoint: endPoint)).await()
                print(meatAndFillersText)
                
                // Execute data request with endpoint and text-array response
                let allMeatText = try DataTask<[String]>(endpoint: BaconIpsumEndpoints.allMeat).await()
                print(allMeatText)
                
                // Creates a request with a previously defined endpoint
                let request = NetworkRequest(endpoint: BaconIpsumEndpoints.meatAndFiller, ignoreCache: true, retryCount: 2)
                
                // Execute data with defined request, text-array result
                let baconIpsumText: [String] = try DataTask(request: request).await()
                print(baconIpsumText)
                
                // Data request with predefined LoremRequest
                let text: [String] = try DataTask(request: LoremRequest()).await()
                print(text)
                
                // Data request with predefined LoremRequest, showing that you can define result type as <> parameter
                let textAnother = try DataTask<[String]>(request: LoremRequest()).await()
                print(textAnother)
                
                // Define custom endpoint and create inline a request with it
                let imageEndPoint = NetworkEndpoint(baseUrl: "https://picsum.photos",
                                                    path: "/2048/2048")
                
                let imageData = try DataTask<Data>(request: NetworkRequest(endpoint: imageEndPoint)).await()
                
                // Multipart form data POST request
                let multiPartEndpoint = NetworkEndpoint(baseUrl: "https://httpbin.org",
                                                        path: "/post",
                                                        method: .post,
                                                        parameters: [:])
                
                let multiPartRequest = NetworkMultipartFormDataRequest(endpoint: multiPartEndpoint,
                                                                       data: imageData,
                                                                       mimeType: "jpeg",
                                                                       filename: "MyImage")
                let uploadTask = MultipartFormDataUploadTask<Data>(request: multiPartRequest)
                
                // Track progress from upload task
                DispatchQueue.main.sync {
                    self.progressView.observedProgress = uploadTask.progress
                }
                
                let resultData = try uploadTask.await()
                print(resultData)
                
                // Download task with specific file URL
                let downloadFileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpeg")
                
                let downloadRequest = NetworkRequest(endpoint: imageEndPoint)
                let downloadTask = DownloadTask(request: downloadRequest, downloadDestination: downloadFileURL)
                
                // Track progress from download task
                DispatchQueue.main.sync {
                    self.progressView.observedProgress = downloadTask.progress
                }
                
                let destinationURL = try downloadTask.await()
                
                // Should be the same
                assert(downloadFileURL == destinationURL)
                
                self.imageView.setImageWith(contentsOfFile: destinationURL)
                
                print("DONE!!!")
            } catch {
                print("ERROR: \(error)")
            }
        }
    }
    
    // An enum following the Endpoint protocol defining two network endpoints
    enum BaconIpsumEndpoints: Endpoint {
        case meatAndFiller
        case allMeat
        case fail
        
        var baseUrl: String { return "https://baconipsum.com" }
        
        var path: String {
            switch self {
            case .meatAndFiller:
                return "/api"
            case .allMeat:
                return "/api/"
            case .fail:
                return "/foobar"
            }
        }
        
        var parameters: [String : Any] {
            switch self {
            case .meatAndFiller:
                return ["type": "meat-and-filler"]
            case .allMeat:
                return ["type": "all-meat", "paras" : "2", "start-with-lorem": "1"]
            default:
                return [:]
            }
        }
    }
    
    // Network request just using the defined BaconIpsumEndpoint.loremIpsum endpoint
    struct LoremRequest: Request {
        let endpoint: Endpoint = BaconIpsumEndpoints.meatAndFiller
    }
}

// MARK: - Helpers

extension UIImageView {
    func setImageWith(contentsOfFile fileURL: URL) {
        let fileimage = UIImage(contentsOfFile: fileURL.path)
        
        DispatchQueue.main.sync {
            self.image = fileimage
        }
    }
}


