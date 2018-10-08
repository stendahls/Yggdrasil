# Yggdrasil

[![CI Status](http://img.shields.io/travis/stendahls/Yggdrasil.svg?style=flat)](https://travis-ci.org/stendahls/Yggdrasil)
[![Version](https://img.shields.io/cocoapods/v/Yggdrasil.svg?style=flat)](http://cocoapods.org/pods/Yggdrasil)
[![License](https://img.shields.io/cocoapods/l/Yggdrasil.svg?style=flat)](http://cocoapods.org/pods/Yggdrasil)
[![Platform](https://img.shields.io/cocoapods/p/Yggdrasil.svg?style=flat)](http://cocoapods.org/pods/Yggdrasil)
![Swift](https://img.shields.io/badge/%20in-swift%204.2-orange.svg)

Yggdrasil is a network library which allows to create and execute async/await based network requests. The focus is on easy and simple usage to avoid too much code overhead. Yggdrasil is protocol based with some additional structs and classes for convenient usage.

For more information concenring async/await take a look at [Taskig](https://github.com/stendahls/Taskig) which is the underlying async/await library.  

Internally Yggdrasil uses [Taskig](https://github.com/stendahls/Taskig) and [Alamofire](https://github.com/Alamofire/Alamofire).

## Quick Start 

Start a simple download to file task.

```swift
let imageDownloadTask = DownloadTask(url: "https://picsum.photos/1024/1024")

let fileURL = try imageDownloadTask.await()
```
This defines a download task which will return a file URL to the downloaded data. Calling `.await()` starts the download request for the given URL. The request is executed on a background queue and the current thread is paused until the result is retrieved or an error has happened. Yggdrasil uses do/catch based error handling which allows to seperate the request code from the error hanlding one. Be careful not to start tasks with `.await()` on the main thread as this would block the UI.

Or download the same as data task:

```swift
// Data task which returns the downloaded data as Swift data structure
// The response type needs to be defined as type parameter
let imageData = try DataTask<Data>(url: "https://picsum.photos/1024/1024").await
```
It is also to straight forward to start an upload task:

```swift
// Upload task which does a POST request to the given URL 
// The response is a JSON dictionary
let uploadTask = UploadTask<JSONDictionary>(url: "https://httpbin.org/post", 
                                            dataToUpload: .data(imageData))
let jsonUpload = try uploadTask.await()
```

## Architecture

Yggdrasil is based on a set of protocols which define requirements for API endpoints, request types and response values. Based on these protocols Yggdrasil offers convenience structs/classes for easier usage and smaller code footprint. Let's have a look at the underlying protocols. 

### Endpoint
The `EndpointType` protocol defines the base requirements for an API endpoint: baseUrl, path, method and parameters. It's easy to define your own API endpoints, for example with the help of an enum:

```swift
// An enum adopting the EndpointType protocol defining two API endpoints
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
```
The `Endpoint` convenience struct can be used to define endpoints without the need to define your own enums or structs.

```swift
// Defines an endpoint with parameters
let endpoint = NetworkEndpoint(baseUrl: "https://baconipsum.com",
                               path: "/api",
                               parameters: ["type": "meat-and-filler"])
```

### Request
The `RequestType` protocol defines the actual network request with all its possilbe parameters, this includes endpoint, headers, body, retryCount, ignoreLocalCache, responseValidation and preconditions. 

```swift
// Network request using the defined BaconIpsumEndpoints
struct LoremRequest: RequestType {
    let endpoint: EndpointType = BaconIpsumEndpoints.meatAndFiller
    let retryCount = 3
    let ignoreLocalCache = true    
}
```
This request definition sets the `retryCount` parameter to 3 which will try to fetch the request 3 times after the intial one before giving up and returning an error. Additionally the `ignoreLocalCache` parameter is set to *true* which ignores local cache data during the request.

The convenience struct `Request` allows the easy creation of requests without the need of dedicated structs or enums.

```swift
let request = Request(url: "https://picsum.photos/1024",  
                      ignoreLocalCache: true, 
                      retryCount: 2)
```

#### Preconditions & response validations
It is possible to add precondition and response validation checks to a request to ensure that specific conditions are met before starting or at the end of a request. The request will only be started if all preconditions are met. Likewise the request finish only successfully if all response validations are met. Each precondition and response validation check must return a validition result either `.success()` or `.failure(YourErrorHere)`.

```swift
// Network request with preconditions and response validations
struct LoremRequest: RequestType {
    let endpoint: EndpointType = BaconIpsumEndpoints.meatAndFiller

    var preconditions: [PreconditionValidation] = []
    var responseValidations: [ResponseValidation] = []
}

var loremRequest = LoremRequest()

// Adding a precondition check
loremRequest.preconditions.append({ () -> ValidationResult in
    guard self.isUserSignedIn() else {
        return .failure(MyErrors.noActiveUser)
    }

    return .success
})

// Adding a response validation check
loremRequest.responseValidations.append({ (request, response, data) -> ValidationResult in
    guard response.statusCode < 300 else {
        return .failure(MyErrors.wrongStatusCode)
    }

    return .success
})
```

### MultipartRequest

The `MultipartFormDataRequestType` protocol and the corresponding `MultipartFormDataRequest` struct can be used to create a multipart file request to upload for example images or other binary data. It inherits from `RequestType` and adds data, dataName and mimeType  properties.

```swift
let multipartEndpoint = Endpoint(baseUrl: "https://httpbin.org",
                                 path: "/post",
                                 method: .post)

let multipartRequest = MultipartFormDataRequest(endpoint: multipartEndpoint,
                                                data: imageData,
                                                mimeType: "jpeg",
                                                dataName: "MyImage")
```
### Execution Tasks
Requests are executed by async/await based tasks. Tasks can be initalized with either `RequestTypes`, `EndpointTypes` or string based `URL`s. They are then executed by calling `.await()` or `.async()` and are executed on a background thread`.await()` pauses the current thread until the task finished.  `async()`  expects a completion handler which should handle the result of the request.

#### Parsable & Return types
Each task has a type parameter which defines the expected return type, e.g. a JSON dictionary or a specific data structure. These return types must comply to the `Parsable` protocol. The only exception to this is the DownloadTask which has a predefined `URL` return type. Types which adopts the `Decodable` protocol are supported out of the box.

```swift
// MARK: - Define decodable struct for httpbin.org/uuid

// httpbin.org/uuid response
// { "uuid": "0a4f1b83-8781-4258-8d72-635edbfa79b5" }

struct HttpBinUUID: Decodable {
    let uuid: String
}

// Make parsable
extension HttpBinUUID: Parsable {}
```

Other types must adopt the `Parsable` protocol.

```swift
// Add support for parsable to UIImage
// This needs a wrapper class which is marked as final to conform to Parsable
final class Image: UIImage, Parsable {
    static func parseData(_ data: Data) throws -> Image {
        guard let image = Image(data: data) else {
            throw MyErrors.ImageConversionFailed
        }

        return image
    }
}
```

#### DataTask
A data task fetches the data of the given request and converts it with the help of the `Parsable` protocol to the data type given as type parameter. 

```swift
let imageEndPoint = Endpoint(baseUrl: "https://picsum.photos", path: "/2048/2048")
let image = try DataTask<Data>(endpoint: imageEndPoint).await()
```

#### DownloadTask
A download task fetches the data of the given request and saves it as a file.

```swift
let imageDownloadTask = DownloadTask(url: "https://picsum.photos/1024/1024")
let fileURL = try imageDownloadTask.await()
```

It is also possible to specify a custom download destination.

```swift
// Download task with custom file URL
let downloadDestinationURL = FileManager.default
    .temporaryDirectory
    .appendingPathComponent("MyImage")
    .appendingPathExtension("jpeg")

try DownloadTask(url: "https://picsum.photos/1024/1024/?random",
                 downloadDestination: downloadDestinationURL).await()

self.imageView.setImageWith(contentsOfFile: downloadDestinationURL)
```

#### UploadTask
Upload task allows to post either a file URL or a data structure to the given `URL` or `Request`.

```swift
// Data upload with JSON response
let data = "Foobar".data(using: .utf8)!

let uploadTask = UploadTask<JSONDictionary>(url: "https://httpbin.org/post", dataToUpload: .data(data))

let jsonResult = try uploadTask.await()
```

#### MultipartFormDataUploadTask

Use this task do execute a multipart file upload request. 

```swift
let multipartRequest = MultipartFormDataRequest(endpoint: multipartEndpoint,
    data: imageData,
    mimeType: "jpeg",
    dataName: "MyImage")

let multipartUploadTask = MultipartFormDataUploadTask<Data>(request: multipartRequest)

let resultData = try multipartUploadTask.await()
```

#### Sequence & Dictionary support
A sequence of tasks can be executed via `.awaitAll()`

#### Support for ProgressReporting 

## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Yggdrasil is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Yggdrasil'
```

## Author

thomas.sempf@stendahls.se

## License

Yggdrasil is available under the MIT license. See the LICENSE file for more info.
