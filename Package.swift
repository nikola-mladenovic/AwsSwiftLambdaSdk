// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AwsLambda",
    products: [.library(name: "AwsLambda", targets: ["AwsLambda"])],
    dependencies: [.package(url: "https://github.com/nikola-mladenovic/AwsSwiftSign.git", from: "0.1.0")],
    targets: [.target(name: "AwsLambda", dependencies: ["AwsSign"]),
              .testTarget(name: "AwsLambdaTests",dependencies: ["AwsLambda"])]
)
