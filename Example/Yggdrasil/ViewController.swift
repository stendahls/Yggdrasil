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
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isRunningTests = NSClassFromString("XCTestCase") != nil
        
        guard isRunningTests == false else { return }
        
        label.text = "Running tests..."
        
        Task.async {
            do {
                // Request with a retry count of 3
                // This will repeat the request up to 3 times in case of errors before giving up and returning.
                // It will also ignore local caches
                let retryRequest = Request(endpoint: Endpoint(baseUrl: "ThisWill", path: "Fail"),
                                           ignoreCache: true,
                                           retryCount: 3)
                
                let _ = try? DataTask<Data>(request: retryRequest).await()
                
                // Download task which will return a file URL to the downloaded data
                let imageDownloadTask = DownloadTask(url: "https://picsum.photos/1024/1024/?random")
                let fileURL = try imageDownloadTask.await()
                self.imageView.setImageWith(contentsOfFile: fileURL)
                
                
                // Download task with custom file URL
                let downloadDestinationURL = FileManager.default
                    .temporaryDirectory
                    .appendingPathComponent("MyImage")
                    .appendingPathExtension("jpeg")
                
                try DownloadTask(url: "https://picsum.photos/1024/1024/?random",
                                 downloadDestination: downloadDestinationURL).await()
                
                self.imageView.setImageWith(contentsOfFile: downloadDestinationURL)
                
                // File upload with JSON response
                let uploadTask = UploadTask<JSONDictionary>(url: "https://httpbin.org/post", dataToUpload: .file(fileURL))
                let jsonUpload = try uploadTask.await()
                print(jsonUpload)
                
                // Data request
                let dataTask = DataTask<JSONDictionary>(url: "https://httpbin.org/uuid")
                let json = try dataTask.await()
                print(json)
                
                // Defines an API endpoint with parameters
                let endPoint = Endpoint(baseUrl: "https://baconipsum.com",
                                        path: "/api",
                                        parameters: ["type": "meat-and-filler"])
                
                // Data request with text-array response
                let meatAndFillersText: [String] = try DataTask(request: Request(endpoint: endPoint)).await()
                print(meatAndFillersText)
                
                // Execute data task with API endpoint and text-array response
                let allMeatText = try DataTask<[String]>(endpoint: BaconIpsumEndpoints.allMeat).await()
                print(allMeatText)
                
                // Creates a request with a previously defined endpoint
                let request = Request(endpoint: BaconIpsumEndpoints.meatAndFiller, ignoreCache: true, retryCount: 2)
                
                // Execute data task with defined request, text-array result
                let baconIpsumText: [String] = try DataTask(request: request).await()
                print(baconIpsumText)
                
                // Data task with predefined LoremRequest
                let text: [String] = try DataTask(request: LoremRequest()).await()
                print(text)
                
                // Data task with predefined LoremRequest
                var loremRequest = LoremRequest()
                
                // Adding a precondition
                loremRequest.preconditions.append({ () -> ValidationResult in
                    guard self.userSignedIn() else {
                        return .failure(MyErrors.noActiveUser)
                    }
                    
                    return .success
                })
                
                // Adding a responseValidation
                loremRequest.responseValidations.append({ (request, response, data) -> ValidationResult in
                    guard response.statusCode < 300 else {
                        return .failure(MyErrors.wrongStatusCode)
                    }
                    
                    return .success
                })
                
                let textAnother = try DataTask<[String]>(request: LoremRequest()).await()
                print(textAnother)
                
                // Define custom API endpoint and create an inline request with it
                let imageEndPoint = Endpoint(baseUrl: "https://picsum.photos",
                                             path: "/2048/2048")
                
                let imageData = try DataTask<Data>(request: Request(endpoint: imageEndPoint)).await()
                
                // Multipart form data POST request
                let multipartEndpoint = Endpoint(baseUrl: "https://httpbin.org",
                                                 path: "/post",
                                                 method: .post)
                
                let multipartRequest = MultipartFormDataRequest(endpoint: multipartEndpoint,
                                                                data: imageData,
                                                                mimeType: "jpeg",
                                                                dataName: "MyImage")

                let multipartUploadTask = MultipartFormDataUploadTask<Data>(request: multipartRequest)
                
                // Track progress from upload task
                DispatchQueue.main.sync {
                    self.progressView.observedProgress = multipartUploadTask.progress
                }
                
                let resultData = try multipartUploadTask.await()
                print(resultData)
                
                // Download task with specific file URL
                let downloadFileURL = FileManager.default
                    .temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpeg")
                
                let downloadRequest = Request(endpoint: imageEndPoint)
                let downloadTask = DownloadTask(request: downloadRequest, downloadDestination: downloadFileURL)
                
                // Track progress from download task
                DispatchQueue.main.sync {
                    self.progressView.observedProgress = downloadTask.progress
                }
                
                let destinationURL = try downloadTask.await()
                
                // Should be the same
                assert(downloadFileURL == destinationURL)
                
                self.imageView.setImageWith(contentsOfFile: destinationURL)
                
                // Fetch many small images at the same time
                let iconEndPoint = Endpoint(baseUrl: "https://picsum.photos",
                                             path: "/256/256/?random")
                
                // All icon data will be fetched,
                // if one request fails an error will be thrown
                // Then the data will be converted to images
                let iconImages = try (0..<10)
                    .map({ _ in DataTask<Data>(endpoint: iconEndPoint) })
                    .awaitAll()
                    .compactMap({ UIImage(data: $0) })
                
                for image in iconImages {
                    DispatchQueue.main.sync {
                        self.imageView.image = image
                    }
                    
                    Thread.sleep(forTimeInterval: 0.5)
                }
                
                
                DispatchQueue.main.sync {
                    self.label.text = "DONE!"
                }
            } catch {
                DispatchQueue.main.sync {
                    self.label.text = "ERROR: \(error)!"
                }
            }
        }
    }
    
    private func userSignedIn() -> Bool {
        // Fake method
        return true
    }
    
    enum MyErrors: Error {
        case wrongStatusCode
        case noActiveUser
    }
    
    // An enum following the EndpointType protocol defining two API endpoints
    enum BaconIpsumEndpoints: EndpointType {
        case meatAndFiller
        case allMeat
        
        var baseUrl: String { return "https://baconipsum.com" }
        
        var path: String {
            switch self {
            case .meatAndFiller:
                return "/api"
            case .allMeat:
                return "/api/"
            }
        }
        
        var parameters: [String : Any] {
            switch self {
            case .meatAndFiller:
                return ["type": "meat-and-filler"]
            case .allMeat:
                return ["type": "all-meat", "paras" : "2", "start-with-lorem": "1"]
            }
        }
    }
    
    // Network request just using the defined BaconIpsumEndpoint.loremIpsum endpoint
    struct LoremRequest: RequestType {
        let endpoint: EndpointType = BaconIpsumEndpoints.meatAndFiller
        let retryCount = 3
        let ignoreCache = true
        
        var preconditions: [PreconditionValidation] = []
        var responseValidations: [ResponseValidation] = []
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


