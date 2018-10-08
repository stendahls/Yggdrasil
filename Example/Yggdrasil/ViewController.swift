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
            execute(example: self.dataTasks)
            
            execute(example: self.downloadTasks)
            
            execute(example: self.uploadTasks)
            
            execute(example: self.multipartUploadTask)
            
            execute(example: self.retryRequest)
            
            execute(example: self.requestValidation)
            
            execute(example: self.progressObserving)
            
            execute(example: self.multiDownloadTask)
            
            DispatchQueue.main.sync { self.label.text = "DONE!" }
        }
    }
    
    // MARK: - Examples
    
    private func dataTasks() throws {
        // Data task with string based URL with cutom HttpBinUUID response
        let dataTask = DataTask<HttpBinUUID>(url: "https://httpbin.org/uuid")
        let httpBinUUID = try dataTask.await()
        print(httpBinUUID.uuid)
        
        // Data task with uses a defined endpoint and the response is a string-array
        let endPoint = Endpoint(baseUrl: "https://baconipsum.com",
                                path: "/api",
                                parameters: ["type": "meat-and-filler"])
        let meatAndFillersText: [String] = try DataTask(request: Request(endpoint: endPoint)).await()
        print(meatAndFillersText)
        
        // Execute data task with a pre-defined enum based endpoint
        let allMeatText = try DataTask<[String]>(endpoint: BaconIpsumEndpoints.allMeat).await()
        print(allMeatText)
        
        // A data task with a request based on a previously defined endpoint
        let request = Request(endpoint: BaconIpsumEndpoints.meatAndFiller, ignoreLocalCache: true, retryCount: 2)
        let baconIpsumText: [String] = try DataTask(request: request).await()
        print(baconIpsumText)
        
        // Data task with predefined LoremRequest
        let text: [String] = try DataTask(request: LoremRequest()).await()
        print(text)
    }
    
    private func downloadTasks() throws {
        // Download task which will return a file URL to the downloaded data
        let imageDownloadTask = DownloadTask(url: "https://picsum.photos/1024/1024/?random")
        
        let temporaryFileURL = try imageDownloadTask.await()
        
        imageView.setImageWith(contentsOfFile: temporaryFileURL)

        // Download task with custom file URL
        let downloadDestinationURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("MyImage")
            .appendingPathExtension("jpeg")
        
        try DownloadTask(url: "https://picsum.photos/1024/1024/?random",
                         downloadDestination: downloadDestinationURL).await()
        
        imageView.setImageWith(contentsOfFile: downloadDestinationURL)
    }
    
    private func uploadTasks() throws {
        // Data upload with JSON response
        let data = "Foobar".data(using: .utf8)!
        
        let uploadTask = UploadTask<JSONDictionary>(url: "https://httpbin.org/post",
                                                    dataToUpload: .data(data))
        
        let jsonUpload = try uploadTask.await()
        
        print(jsonUpload)
    }
    
    private func multipartUploadTask() throws {
        // Fetch first data to upload
        let imageData = try DataTask<Data>(url: "https://picsum.photos/2048/2048").await()
        
        // Multipart form data POST request
        let multipartEndpoint = Endpoint(baseUrl: "https://httpbin.org",
                                         path: "/post",
                                         method: .post)
        
        let multipartRequest = MultipartFormDataRequest(endpoint: multipartEndpoint,
                                                        data: imageData,
                                                        mimeType: "jpeg",
                                                        dataName: "MyImage")
        
        let multipartUploadTask = MultipartFormDataUploadTask<Data>(request: multipartRequest)
        
        let resultData = try multipartUploadTask.await()
        print(resultData)
    }
    
    private func progressObserving() throws {
        let imageEndPoint = Endpoint(baseUrl: "https://picsum.photos",
                                     path: "/2048/2048")
        
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
    }
    
    private func multiDownloadTask() throws {
        // Fetch many small images at the same time
        let iconEndPoint = Endpoint(baseUrl: "https://picsum.photos",
                                    path: "/256/256/?random")
        
        // All icon data will be fetched,
        // if one request fails an error will be thrown
        // Then the data will be converted to images
        var iconImages = try (0..<10)
            .map({ _ in DataTask<Image>(endpoint: iconEndPoint) })
            .awaitAll()
        
        self.imageView.presentImages(iconImages, withInBetweenDelay: 0.5)
        
        iconImages = (0..<10)
            .map({ _ in DataTask<Image>(endpoint: iconEndPoint) })
            .awaitAllResults()
            .compactMap({ (resultImage) -> Image? in
                try? resultImage.unpack()
            })

        self.imageView.presentImages(iconImages, withInBetweenDelay: 0.5)
    }
    
    private func retryRequest() throws {
        // Request with a retry count of 3
        // This will repeat the request up to 3 times in case of errors before giving up and returning.
        // It will also ignore local caches
        let retryRequest = Request(url: "ThisWill/Fail",
                                   ignoreLocalCache: true,
                                   retryCount: 3)
        
        try DataTask<Data>(request: retryRequest).await()
    }
    
    private func requestValidation() throws {
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
    }
    
    private func userSignedIn() -> Bool {
        // Fake method
        return true
    }
    
    enum MyErrors: Error {
        case wrongStatusCode
        case noActiveUser
    }
    
    // MARK: - Endpoints definition
    
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
    
    // MARK: - Request definition
    
    // Network request just using the defined BaconIpsumEndpoint.loremIpsum endpoint
    struct LoremRequest: RequestType {
        let endpoint: EndpointType = BaconIpsumEndpoints.meatAndFiller
        let retryCount = 3
        let ignoreLocalCache = true
        
        var preconditions: [PreconditionValidation] = []
        var responseValidations: [ResponseValidation] = []
    }
}

// MARK: - Parsable support

// Define decodable struct for httpbin.org uuid

// httpbin.org/uuid response
// { "uuid": "0a4f1b83-8781-4258-8d72-635edbfa79b5" }

struct HttpBinUUID: Decodable {
    let uuid: String
}

// Make decodable
extension HttpBinUUID: Parsable {}

// Add support for parsable to UIImage
// This needs a wrapper class which is marked as final to conform to Parsable
final class Image: UIImage, Parsable {
    static func parseData(_ data: Data) throws -> Image {
        guard let image = Image(data: data) else {
            throw "Couldn't convert image"
        }
        
        return image
    }
}

// MARK: - Helpers

extension String: Error {}

fileprivate extension UIImageView {
    func setImageWith(contentsOfFile fileURL: URL) {
        let fileimage = UIImage(contentsOfFile: fileURL.path)
        
        DispatchQueue.main.sync {
            self.image = fileimage
        }
    }
    
    func presentImages(_ images: [UIImage], withInBetweenDelay delay: TimeInterval) {
        for image in images {
            DispatchQueue.main.async {
                self.image = image
            }
            
            Thread.sleep(forTimeInterval: delay)
        }
    }
}

fileprivate func execute(example: () throws ->Void) {
    do {
        try example()
    } catch {
        DispatchQueue.main.sync {
            print(error)
        }
    }
}
