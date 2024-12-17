//
//  ApiClient.swift
//  WeatherAppAssignment
//
//  Created by Pulkit Arora on 15/12/24.
//

import Foundation

protocol URLSessionProtocol {
    func loadData(request: URLRequest) async -> (data: Data?, response: URLResponse?, error: Error?)
}

extension URLSession: URLSessionProtocol {
    func loadData(request: URLRequest) async -> (data: Data?, response: URLResponse?, error: (any Error)?) {
        do {
            let (data, response) = try await data(for: request)
            return (data, response, nil)
        } catch let error {
            return (nil, nil, error)
        }
    }
    
    static func getInstance() -> URLSession {
        .shared
    }
}

enum APIMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

protocol APIRequest {
    var urlString: String? { get set }
    var method: APIMethod { get set }
    var headers: [String: String]? { get set }
    var queryParams: [String: String]? { get set }
    var bodyParams: [String: String]? { get set }
}

extension APIRequest {
    func urlRequest() -> URLRequest? {
        guard let urlString else {
            return nil
        }
        
        var components = URLComponents(string: urlString)
        var queryItems: [URLQueryItem] = []
        
        queryParams?.forEach({ (key, value) in
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        })
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = getData()
        return request
    }
    
    func getData() -> Data? {
        guard let bodyParams else {
            return nil
        }
        return try? JSONSerialization.data(withJSONObject: bodyParams)
    }
}

protocol ApiClientProtocol: AnyObject {
    static func getInstance(session: URLSessionProtocol) -> ApiClientProtocol
    func getData(request: APIRequest) async -> (data: Data?, response: URLResponse?, error: Error?)
}

enum ApiClientError: Error {
    case badRequest
    case generic
}

final class ApiClient: ApiClientProtocol {
    private let session: URLSessionProtocol
    
    static var shared: ApiClientProtocol!
    private init(session: URLSessionProtocol) {
        self.session = session
    }
    
    static func getInstance(session: URLSessionProtocol) -> ApiClientProtocol {
        if shared == nil {
            shared = ApiClient(session: session)
        }
        return shared
    }
    
    func getData(request: APIRequest) async -> (data: Data?, response: URLResponse?, error: Error?) {
        guard let urlRequest = request.urlRequest() else {
            return (nil, nil, ApiClientError.badRequest)
        }
        
        return await session.loadData(request: urlRequest)
    }
}
