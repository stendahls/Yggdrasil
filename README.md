# Yggdrasil

[![CI Status](http://img.shields.io/travis/stendahls/Yggdrasil.svg?style=flat)](https://travis-ci.org/stendahls/Yggdrasil)
[![Version](https://img.shields.io/cocoapods/v/Yggdrasil.svg?style=flat)](http://cocoapods.org/pods/Yggdrasil)
[![License](https://img.shields.io/cocoapods/l/Yggdrasil.svg?style=flat)](http://cocoapods.org/pods/Yggdrasil)
[![Platform](https://img.shields.io/cocoapods/p/Yggdrasil.svg?style=flat)](http://cocoapods.org/pods/Yggdrasil)
![Swift](https://img.shields.io/badge/%20in-swift%204.2-orange.svg)

Yggdrasil is a network library which wraps [Taskig](https://github.com/stendahls/Taskig) and [Alamofire](https://github.com/Alamofire/Alamofire) to allow easy to use async/await based network requests. For more information concenring async/await take a look at [Taskig](https://github.com/stendahls/Taskig) which is the underlying async/await library. Yggdrasil is protocol based and modular with some additional structs and classes for convenient usage. 

## Quick Start 

Start a simple download to file task:

```swift
// Download task which will return a file URL to the downloaded data, a picture in this case
let imageDownloadTask = DownloadTask(url: "https://picsum.photos/1024/1024")

// .await() pauses the current thread until the data is retrieved
let fileURL = try imageDownloadTask.await()
```
This starts a download request for the given URL. The request is executed on a background queue and the current thread is paused until the result is retrieved or an error happened. Yggdrasil uses do/catch based error handling which allows to seperate the request code from the error hanlding.

Or download the same as data task:

```swift
// Data task which returns the image as Swift data struct
// You have to define the response type as generic function parameter
let dataTask = DataTask<Data>(url: "https://picsum.photos/1024/1024")
let imageData = try dataTask.await()
```
It is also to straight forward to start an upload tasks:

```swift
// Upload task which does a POST request to the given URL 
// The response is a JSON dictionary
let uploadTask = UploadTask<JSONDictionary>(url: "https://httpbin.org/post", dataToUpload: .data(imageData))
let jsonUpload = try uploadTask.await()
```

## Architecture

Yggdrasil is based on a set of protocols which define requirements for network endpoints, request types and response values. Based on these endpoints Yggdrasil offers convenience structs for easier usage and smaller code footprint. Let's have a look at the underlying protocols. 

### Endpoints
The EndpointType protocol defines the base requirements for request endpoints. This protocol defines the baseUrl, path, method and parameters. The Endpoint convenience struct can be used to define endpoints without the need to define your own enums or structs.

It's easy to define your own network endpoints, for example with the help of an enum:

```swift
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
```
Or if you want to create an endpoint  for usage inside a function you can use the convenience struct Endpoint:

```swift
// Defines an endpoint with parameters
NetworkEndpoint(baseUrl: "https://baconipsum.com",
    path: "/api",
    parameters: ["type": "meat-and-filler"])
```

### Request
Protocol Request defines a network request with headers, parameters, etc., convenience class NetworRequest
    Give example with enum and Request

### Parsable & Return types

### DataTask

### DownloadTask

### UploadTask

### MultipartRequest

### MultipartFormDataUploadTask




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
