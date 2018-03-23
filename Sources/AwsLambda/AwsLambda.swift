import Foundation
import AwsSign

public class AwsLambda {
    
    static fileprivate let jsonEncoder = JSONEncoder()
    static fileprivate let jsonDecoder = JSONDecoder()
    
    fileprivate let host: String
    fileprivate let session: URLSession
    fileprivate let accessKeyId: String
    fileprivate let secretAccessKey: String
    
    /// Initializes a new AwsLambda client, using the specified host, session, and access credentials.
    ///
    /// - Parameters:
    ///   - host: The host for the Lambda, e.g `https://lambda.eu-west-1.amazonaws.com/`
    ///   - session: Optional parameter, specifying a `URLSession` to be used for all Lambda related requests. If not provided, `URLSession(configuration: .default)` will be used.
    ///   - accessKeyId: The access key for using the Lambda.
    ///   - secretAccessKey: The secret access key for using the Lambda.
    public init(host: String, session: URLSession = URLSession(configuration: .default), accessKeyId: String, secretAccessKey: String) {
        var normalizedHost = host
        if normalizedHost.hasSuffix("/") {
            normalizedHost.remove(at: String.Index(encodedOffset: normalizedHost.count - 1))
        }
        
        self.host = normalizedHost
        self.session = session
        self.accessKeyId = accessKeyId
        self.secretAccessKey = secretAccessKey
    }
    
    /// Initializes `AwsLambdaFunction` instance for given function name.
    ///
    /// - Parameter name: The name of the function.
    /// - Returns: `AwsLambdaFunction` instance.
    public func function(with name: String) -> AwsLambdaFunction {
        return AwsLambdaFunction(name: name, awsLambda: self)
    }
    
}

public class AwsLambdaFunction {
    
    private let name: String
    private let awsLambda: AwsLambda
    
    fileprivate init(name: String, awsLambda: AwsLambda) {
        self.name = name
        self.awsLambda = awsLambda
    }
    
    /// Use this method to invoke lambda function.
    ///
    /// - Parameters:
    ///   - function: String that represents functions name or ARN.
    ///   - invocationType: Invocation type
    ///   - logType: Log Type
    ///   - payload: Object that conforms to 'Encodable' protocol. This object will be passed to lambda function as input value/event.
    ///   - completion: Closure that will be called after request finishes.
    public func invoke<T>(invocationType: InvocationType = .requestResponse, logType: LogType = .none, payload: Encodable? = nil, completion: @escaping (InvocationResponse<T>) -> Void) {
        let headerFields = [ "X-Amz-Invocation-Type" : invocationType.rawValue,
                             "X-Amz-Log-Type" : logType.rawValue,
                             "X-Amz-Client-Context" : "{}".data(using: .utf8)?.base64EncodedString() ?? ""]
        
        let request: URLRequest
        do {
            request = try self.request(path: "2015-03-31/functions/\(name)/invocations", headerFields: headerFields, body: payload)
        } catch {
            completion(InvocationResponse<T>(errorDescription: error.localizedDescription))
            return
        }
        
        awsLambda.session.dataTask(with: request, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse, response.statusCode <= 299, error == nil else {
                let errorDescripiton: String
                if let data = data, let message = String(data: data, encoding: .utf8) {
                    errorDescripiton = message
                } else {
                    errorDescripiton = error?.localizedDescription ?? "Something went wrong."
                }
                completion(InvocationResponse<T>(errorDescription: errorDescripiton))
                return
            }
            
            // Make sure all keys in http header dictionary are lowercased (keys can have different case depending on a platform on which binary is executed).
            var headerFields = [AnyHashable : Any]()
            response.allHeaderFields.forEach { key, value in
                if let key = key as? String {
                    headerFields[key.lowercased()] = value
                } else {
                    headerFields[key] = value
                }
            }

            var log: String? = nil
            if let base64Log = headerFields["x-amz-log-result"] as? String,
                let data = Data(base64Encoded: base64Log),
                let logText = String(data: data, encoding: .utf8) {
                log = logText
            }
            
            var functionError: FunctionError? = nil
            var errorDescription: String? = nil
            var payload: T? = nil
            if let functionErrorText = headerFields["x-amz-function-error"] as? String,
                let functionErrorValue = FunctionError(rawValue: functionErrorText) {
                functionError = functionErrorValue
                
                if let data = data, let errorDescriptionText = String(data: data, encoding: .utf8) {
                    errorDescription = errorDescriptionText
                }
            } else if let data = data {
                do {
                    if T.self == String.self, let payloadText = String(data: data, encoding: .utf8) {
                        payload = payloadText as? T
                    } else {
                        payload = try T.decodeJSON(from: data)
                    }
                } catch {
                    completion(InvocationResponse<T>(errorDescription: error.localizedDescription))
                    return
                }
            }
            
            completion(InvocationResponse<T>(payload: payload, logResult: log, functionError: functionError, errorDescription: errorDescription))
        }).resume()
    }
    
    private func request(path: String, urlParams: [String : String?] = [:], headerFields: [String : String] = [:], body: Encodable? = nil) throws -> URLRequest {
        var formattedPath = path
        if formattedPath.hasSuffix("/") {
            formattedPath.remove(at: String.Index(encodedOffset: path.count - 1))
        }
        var urlComponents = URLComponents(string: "\(awsLambda.host)/\(formattedPath)")!
        urlComponents.queryItems = urlParams.filter { $0.value != nil && $0.value?.isEmpty == false }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        headerFields.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        if let body = body {
            urlRequest.httpBody = try? body.encodeJSON()
        }
        
        try urlRequest.sign(accessKeyId: awsLambda.accessKeyId, secretAccessKey: awsLambda.secretAccessKey)
        
        return urlRequest
    }
    
}

extension Encodable {
    func encodeJSON() throws -> Data {
        return try AwsLambda.jsonEncoder.encode(self)
    }
}

extension Decodable {
    static func decodeJSON(from data: Data) throws -> Self {
        return try AwsLambda.jsonDecoder.decode(Self.self, from: data)
    }
}
