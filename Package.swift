// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "swift-aws-cfn",
    products: [
        .library(
            name: "AWSCloudFormationLambdaEvents",
            targets: ["AWSCloudFormationLambdaEvents"]),
        .library(
            name: "AWSCloudFormationCustomResource",
            targets: ["AWSCloudFormationCustomResource"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "0.3.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "AWSCloudFormationLambdaEvents",
            dependencies: [
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime"),
            ]),

        .testTarget(
            name: "AWSCloudFormationLambdaEventsTests",
            dependencies: [
                .byName(name: "AWSCloudFormationLambdaEvents")
            ]),

        .target(
            name: "AWSCloudFormationCustomResource",
            dependencies: [
                .byName(name: "AWSCloudFormationLambdaEvents"),
                .product(name: "AWSLambdaRuntimeCore", package: "swift-aws-lambda-runtime"),
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ]),
        .testTarget(
            name: "AWSCloudFormationCustomResourceTests",
            dependencies: [
                .byName(name: "AWSCloudFormationCustomResource"),
                .product(name: "AWSLambdaTesting", package: "swift-aws-lambda-runtime")
            ]),

        .target(
            name: "AWSCloudFormationMacro",
            dependencies: [
                .byName(name: "AWSCloudFormationLambdaEvents"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaRuntimeCore", package: "swift-aws-lambda-runtime")
            ]),
        .testTarget(
            name: "AWSCloudFormationMacroTests",
            dependencies: [
                .byName(name: "AWSCloudFormationMacro")
            ]),

        .target(
            name: "CustomResourceMirrorSample",
            dependencies: ["AWSCloudFormationCustomResource"],
            path: "./Sources/Samples/CustomResourceMirrorSample"
            ),
    ]
)
