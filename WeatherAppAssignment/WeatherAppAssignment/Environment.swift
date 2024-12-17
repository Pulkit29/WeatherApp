//
//  Environment.swift
//  WeatherAppAssignment
//
//  Created by Pulkit Arora on 15/12/24.
//

import Foundation

protocol EnvironmentProtocol {
    static var apiKey: String { get }
}

struct AppEnvironment: EnvironmentProtocol {
    static var apiKey: String {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Weather_Api") as? String
        return apiKey ?? ""
    }
}
