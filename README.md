# Yggdrasil

[![CI Status](http://img.shields.io/travis/stendahls/Yggdrasil.svg?style=flat)](https://travis-ci.org/stendahls/Yggdrasil)
[![Version](https://img.shields.io/cocoapods/v/Yggdrasil.svg?style=flat)](http://cocoapods.org/pods/Yggdrasil)
[![License](https://img.shields.io/cocoapods/l/Yggdrasil.svg?style=flat)](http://cocoapods.org/pods/Yggdrasil)
[![Platform](https://img.shields.io/cocoapods/p/Yggdrasil.svg?style=flat)](http://cocoapods.org/pods/Yggdrasil)
![Swift](https://img.shields.io/badge/%20in-swift%204.2-orange.svg)

Yggdrasil is a network library which uses [Taskig](https://github.com/stendahls/Taskig) and [Alamofire](https://github.com/Alamofire/Alamofire) to create convenient and easy to use network tasks. Network tasks follow the async/await pattern for easy usage and to avoid common prolbems like pyramids of completion handlers. For more information concenring async/await take a look at [Taskig](https://github.com/stendahls/Taskig) which is the underlying async/await library. 
Yggdrasil is protocol based and modular with some additional classes for convenient usage. 

## Features

Start a simple download task:

```swift
// Download task which will return a file URL to the downloaded data
let fileURL = try DownloadTask(url: "https://picsum.photos/1024/1024").await()
```
This starts a network download request for the given URL. The request is executed on a background queue and the current thread is paused until the result is retrieved or an error happened. Yggdrasil uses do/catch based error handling which allows to seperate the network request from the error hanlding. 

### Endpoint
Protocol Endpoint, base to define API endpoints, convenience class NetworkEndpoint for direct usage
    Give example with enum and Endpoint
    
### Request
Protocol Request defines a network request with headers, parameters, etc., convenience class NetworRequest
    Give example with enum and Request

### DataTask

### DownloadTask

### UploadTask

### MultipartRequest

### MultipartFormDataUploadTask

### Parsable


## Example

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
