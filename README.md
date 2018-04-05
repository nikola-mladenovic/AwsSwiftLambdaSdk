# AwsSwiftLambdaSdk
Swift library which enables you to invoke AWS Lambda programmatically. More details on this are available from the [AWS Lambda docmentation](https://aws.amazon.com/documentation/lambda/).

<p>
<a href="https://travis-ci.org/nikola-mladenovic/AwsSwiftLambdaSdk" target="_blank">
<img src="https://travis-ci.org/nikola-mladenovic/AwsSwiftLambdaSdk.svg?branch=master">
</a>
<a href="https://developer.apple.com/swift/" target="_blank">
<img src="https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat" alt="Swift 4.1">
</a>
<a href="https://developer.apple.com/swift/" target="_blank">
<img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-4E4E4E.svg?colorA=EF5138" alt="Platforms iOS | macOS | watchOS | tvOS | Linux">
</a>
<a href="https://github.com/apple/swift-package-manager" target="_blank">
<img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorB=64A5DE" alt="SPM compatible">
</a>
</p>

## Quick Start

To use AwsLambda, modify the Package.swift file and add following dependency:

``` swift
.package(url: "https://github.com/nikola-mladenovic/AwsSwiftLambdaSdk", .branch("master"))
```

Then import the `AwsLambda` library into the swift source code:

``` swift
import AwsLambda
```

## Usage

To use library first initialize the `AwsLambda` instance with your credentials and host. After that initialize `AwsLambdaFunction` instance:
``` swift
let awsLambda = AwsLambda(host: "https://dynamodb.us-west-2.amazonaws.com", accessKeyId: "OPKASPJPOAS23IOJS", secretAccessKey: "232(I(%$jnasoijaoiwj2919109233")
let testFunction = awsLambda.function(named: "test-function")
```
To invoke the function use the  `invoke` method of the `AwsLambdaFunction` instance:
``` swift
testFunction.invoke(completion: { (response: InvocationResponse<String>) in
    // Do some work
    ...
})
```
