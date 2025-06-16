// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Yggdrasil",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "Yggdrasil", targets: ["Yggdrasil"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.7.0"),
        .package(url: "https://github.com/stendahls/Taskig.git", from: "0.2.5")
    ],
    targets: [
        .target(
            name: "Yggdrasil",
            dependencies: ["Alamofire", "Taskig"],
            path: "Yggdrasil/Classes"
        )
    ]
)
