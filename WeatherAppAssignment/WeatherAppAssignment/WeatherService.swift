//
//  CardDataServiceProtocol.swift
//  WeatherAppAssignment
//
//  Created by Pulkit Arora on 15/12/24.
//

import Foundation

struct WeatherResponse: Decodable {
    var location: Location?
    var weatherData: WeatherData?
    
    enum CodingKeys: String, CodingKey {
        case weatherData = "current"
        case location = "location"
    }
}

struct Location: Decodable {
    let name: String
    let region : String
    let country: String
    let lat: Double
    let lon: Double
}

struct Condition: Decodable {
    let icon: String
    let text: String
}
struct WeatherData: Decodable {
    let temp: Double
    let humidity: Double
    let feelsLikeTemp: Double
    let uv: Double
    let condition: Condition
    
    enum CodingKeys: String, CodingKey {
        case temp = "temp_c"
        case humidity = "humidity"
        case feelsLikeTemp = "feelslike_c"
        case uv
        case condition
    }
}

protocol WeatherServiceProtocol {
    func loadData(city: String) async -> Result<WeatherResponse, Error>
}

extension WeatherServiceProtocol {
    
    func getRequest() -> APIRequest {
        var request = WeatherAPIRequest()
        request.queryParams = ["key": Environment.apiKey]
        return request
    }
}

struct WeatherAPIRequest: APIRequest {
    var urlString: String? = "http://api.weatherapi.com/v1/current.json"
    var method: APIMethod = .get
    var headers: [String : String]? = nil
    var bodyParams: [String : String]? = nil
    var queryParams: [String : String]? = nil
}

struct WeatherService: WeatherServiceProtocol {
    
    unowned private let apiClient: ApiClientProtocol
    
    init(apiClient: ApiClientProtocol) {
        self.apiClient = apiClient
    }
    
    func loadData(city: String) async -> Result<WeatherResponse, Error> {
        var request = getRequest()
        let externalQueryParams = ["q": city]
        
        request.queryParams?.merge(externalQueryParams, uniquingKeysWith: { a, b in
            b
        })
        
        let (data, _, error) = await apiClient.getData(request: request)
        if let error {
            return .failure(error)
        } else if let data {
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                debugPrint(json)
                let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
                return .success(response)
            }
            catch let error {
                return .failure(error)
            }
        } else {
            return .failure(ApiClientError.generic)
        }
    }
}

