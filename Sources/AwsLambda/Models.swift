import Foundation

public enum InvocationType: String {
    case event = "Event"                        // Asynchronous execution.
    case requestResponse = "RequestResponse"    // Synchronous execution.
    case dryRun = "DryRun"                      // Don't invoke lambda function, perform verification (check if caller is authorized, are inputs valid...).
}

public enum LogType: String {
    case none = "None"              // Don't log anything.
    case tail = "Tail"              // Last 4 KB of log data produced by your Lambda function.
}

public enum FunctionError: String, Codable {
    case handled = "Handled"        // Handled errors are errors that are reported by the function.
    case unhandled = "Unhandled"    // Unhandled errors are those detected and reported by AWS Lambda.
}

public struct InvocationResponse<T: Decodable> {
    public let payload: T?                  // Available only if invocation type is 'requestResponse'.
    public let logResult: String?
    public let functionError: FunctionError?
    public let errorDescription: String?
    
    init(payload: T? = nil, logResult: String? = nil, functionError: FunctionError? = nil, errorDescription: String? = nil) {
        self.payload = payload
        self.logResult = logResult
        self.functionError = functionError
        self.errorDescription = errorDescription
    }
}
