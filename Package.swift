// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "AwsLambda",
    products: [.library(name: "AwsLambda", targets: ["AwsLambda"])],
    dependencies: [.package(url: "https://github.com/nikola-mladenovic/AwsSwiftSign.git", from: "0.2.0")],
    targets: [.target(name: "AwsLambda", dependencies: ["AwsSign"]),
              .testTarget(name: "AwsLambdaTests",dependencies: ["AwsLambda"])],
    swiftLanguageVersions: [.v4_2]
)
