# Swift AWS Lambda CloudFormation
AWS CloudFormation provides a powerful way to model, template, and provision AWS and third-party resources, using a simple template format.
While the templating is very capable in its own, even with code execution via the [Cloud Development Kit](https://aws.amazon.com/cdk/),
the execution of code represented as resources is often an integral part of a complete infrastructure. For this purpose, AWS lambda
is used to represent custom resources and template transforms, extending the capabilities of CloudFormation templating further.

This project, built upon the [Swift AWS Lambda Runtime](https://github.com/swift-server/swift-aws-lambda-runtime), enables the creation
of custom CloudFormation resource and template macros written in Swift, resulting in fast, safe, and reliable custom resources for extending
a system running on Amazon Web Services.

## Project status
This project is in its initial state, actively seeking contributions to achieve stability and a `1.0` version.
Several tests are missing, and this project should be considered non-reliable for production use.

## Getting started
Visit the [swift lambda runtime](https://github.com/swift-server/swift-aws-lambda-runtime) project to familiarize yourself with the
Swift APIs for Lambda.

Create a Swift project and add this project as a dependency.
```swift
// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "my-cfn-resource",
    products: [
        .executable(name: "MyCFNResource", targets: ["MyCFNResource"]),
    ],
    dependencies: [
        .package(url: "https://github.com/davidask/swift-aws-lambda-cfn.git", from: "0.1.0"),
    ],
    targets: [
        .target(name: "MyCFNResurce", dependencies: [
          .product(name: "AWSCloudFormationCustomResource", package: "swift-aws-lambda-cfn"),
        ]),
    ]
)
```
Next, create a main.swift and implement your custom CloudFormation resource.

```swift
AWSCloudFormationCustomResource

struct MyCustomResource: CustomResourceLambdaHandler {

    // A data type representing the incoming resource properties
    // originating from the CloudFormation template.
    struct ResourceProperties: Decodable {
        let property1: String
    }

    // A data type representing the output data of the custom resource,
    // utilized by other resources in the same template via `Fn::GetAtt`.
    struct ResourceData: Encodable {
        let attribute1: String
    }

    func create(context: Lambda.Context, event: CreateEvent, completion: @escaping (Result<ResourceResult, Error>) -> Void) {
        // Create resource
        completion(.success(
            ResourceResult(
                physicalResourceId: "PhysicalResourceID",
                data: ResourceData(attribute1: "Attribute1")
            )
        ))
    }

    func update(context: Lambda.Context, event: UpdateEvent, completion: @escaping (Result<ResourceResult, Error>) -> Void) {
        // Update resource
        completion(.success(
            ResourceResult(
                physicalResourceId: "PhysicalResourceID",
                data: ResourceData(attribute1: "Attribute1")
            )
        ))
    }

    func delete(context: Lambda.Context, event: DeleteEvent, completion: @escaping (Result<Void, Error>) -> Void) {
        // Delete resource
        completion(.success(()))
    }
}

Lambda.run(Resource())
```
You can also create a lambda handler for transforming template fragments.
```swift
import AWSCloudFormationMacro

struct Macro: MacroLambdaHandler {

    enum TransformError: Error {
        case invalidFragment
    }

    // Define an `Encodable` fragment to return
    typealias ReturnFragment = String

    func handle(context: Lambda.Context, event: MacroLambdaEvent, callback: @escaping (Result<ReturnFragment, Error>) -> Void) {
        guard let string = event.fragment.string else {
            callback(.failure(TransformError.invalidFragment))
            return
        }

        callback(.success("MyStringPrefix_" + string))
    }
}
Lambda.run(Macro())
```
The example above prefixes strings passed to this macro with `MyStringPrefix_`.

### Using EventLoops
While the above examples are closure-based, performance sensitive custom resource and macro functions may want to utilize
the more complex EventLoop based API. Use `EventLoopEventLoopCustomResourceLambdaHandler` and `EventLoopMacroLambdaHandler`
for this use-case.


## Deploying to AWS Lambda
Thorough examples can be found in the [lambda runtime](https://github.com/swift-server/swift-aws-lambda-runtime#deploying-to-aws-lambda) documentation.
This project includes helper scripts for building and packaging lambda functions in a Docker container.

From your project, run the following commands to package a target for AWS Lambda.
```sh
./.build/dependencies/swift-aws-lambda-cfn/scripts/build.sh <target>
./.build/dependencies/swift-aws-lambda-cfn/scripts/lambda-package.sh <target>
```
A source bundle zip file will be created in `.build/<target>` for upload to AWS Lambda.

