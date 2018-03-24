import XCTest
@testable import AwsLambda

class AwsLambdaTests: XCTestCase {
    struct TestPayload: Codable, Equatable {
        let name: String
        let number: Int
        
        static func ==(lhs: TestPayload, rhs: TestPayload) -> Bool {
            return lhs.name == rhs.name && lhs.number == rhs.number
        }
    }
    
    static let key = ProcessInfo.processInfo.environment["AWS_KEY"]!
    static let secret = ProcessInfo.processInfo.environment["AWS_SECRET"]!
    static let host = "https://lambda.eu-west-1.amazonaws.com/"
    
    var lambdaClient: AwsLambda?
    
    override func setUp() {
        super.setUp()
        
        lambdaClient = AwsLambda(host: AwsLambdaTests.host, accessKeyId: AwsLambdaTests.key, secretAccessKey: AwsLambdaTests.secret)
    }
    
    func testInvokeSuccess() {
        let publishExpectation = expectation(description: "InvokeExpectation")
        lambdaClient?.function(named: "AwsLambdaTestSuccess").invoke(completion: { (response: InvocationResponse<String>) in
            XCTAssertNil(response.errorDescription)
            XCTAssertNil(response.logResult)
            XCTAssertNil(response.functionError)
            XCTAssertNotNil(response.payload)
            
            publishExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testInvokeLogging() {
        let publishExpectation = expectation(description: "InvokeExpectation")
        lambdaClient?.function(named: "AwsLambdaTestSuccess").invoke(logType: .tail, completion: { (response: InvocationResponse<String>) in
            XCTAssertNil(response.errorDescription)
            XCTAssertNotNil(response.logResult)
            XCTAssertNil(response.functionError)
            XCTAssertNotNil(response.payload)
            
            publishExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testInvokePayload() {
        let publishExpectation = expectation(description: "InvokeExpectation")
        let payload = TestPayload(name: "Mrvica", number: 666)
        lambdaClient?.function(named: "AwsLambdaTestPayload").invoke(payload: payload, completion: { (response: InvocationResponse<TestPayload>) in
            XCTAssertNil(response.errorDescription)
            XCTAssertNil(response.logResult)
            XCTAssertNil(response.functionError)
            XCTAssert(response.payload == payload)
            
            publishExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testInvokeFailed() {
        let publishExpectation = expectation(description: "InvokeExpectation")
        lambdaClient?.function(named: "AwsLambdaTestFailed").invoke(completion: { (response: InvocationResponse<String>) in
            XCTAssertNotNil(response.errorDescription)
            XCTAssertNil(response.logResult)
            XCTAssert(response.functionError == .handled)
            XCTAssertNil(response.payload)
            
            publishExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    static var allTests = [
        ("testInvokeSuccess", testInvokeSuccess),
        ("testInvokeLogging", testInvokeLogging),
        ("testInvokePayload", testInvokePayload),
        ("testInvokeFailed", testInvokeFailed),
    ]
}
