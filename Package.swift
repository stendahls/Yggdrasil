// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Yggdrasil",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "Yggdrasil", targets: ["Yggdrasil"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.7.0"),
        .package(url: "https://github.com/stendahls/Taskig.git", revision: "8e7e5603d5f14bb2a1b262137d9122ec58c8837a")
    ],
    targets: [
        .target(
            name: "Yggdrasil",
            dependencies: ["Alamofire", "Taskig"],
            path: "Yggdrasil/Classes"
        )
    ]
)
