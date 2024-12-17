//
//  CardListViewModel.swift
//  WeatherAppAssignment
//
//  Created by Pulkit Arora on 15/12/24.
//

import Foundation
import SwiftUI

enum ViewState {
    case noCity
    case loading
    case noData
    case error
    case typeAheadSearch
    case detail
}

protocol HomeViewModelProtocol: AnyObject {
    func loadData() async
    func saveSelectedCity(_ city: String?)
    func setState(_ state: ViewState) async
    func getFeelsLike() -> String
    func getUV() -> String
    func getHumidity() -> String
    func getTemperature() -> String
    func getWeatherIcon() -> String
    func getCityName() -> String
    func noCitySubText() -> String
    func noCityText() -> String
}

final class HomeViewModel: ObservableObject, HomeViewModelProtocol {
    
    static let cityKey = "selectedCity"
    
    @Published var state: ViewState = .noCity
    @Published private var response: WeatherResponse?
    
    private var searchWorkItem: DispatchWorkItem?
    
    var selectedCity: String = "" {
        didSet {
            if oldValue != selectedCity {
                fetchWeather()
            }
        }
    }
    
    private let service: WeatherServiceProtocol
    
    init(service: WeatherServiceProtocol) {
        self.service = service
        self.selectedCity = UserDefaults.standard.value(forKey: HomeViewModel.cityKey) as? String ?? ""
        self.state = selectedCity.isEmpty ? .noCity : .loading
        
        Task {
            await loadData()
        }
    }
    
    private func fetchWeather() {
        debugPrint("fetchWeather")
        searchWorkItem?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            Task {
                debugPrint("Task Initiated")
                await self.loadData()
            }
            debugPrint("Task Completed")
        }
        searchWorkItem = task
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.searchWorkItem?.isCancelled == false {
                debugPrint("Task Performing")
                task.perform()
            } else {
                debugPrint("Task Cancelled")
            }
        }
    }
    
    func loadData() async {
        guard selectedCity.count > 3 else {
            await MainActor.run {
                self.state = .noCity
                self.response = nil
            }
            return
        }
        
        await MainActor.run {
            self.state = .loading
        }
        
        let result = await service.loadData(city: selectedCity)
        
        switch result {
        case .success(let data):
            await MainActor.run {
                self.response = data
                self.state = .typeAheadSearch
                debugPrint(data)
            }
        case .failure(let error):
            await MainActor.run {
                self.response = nil
                self.state = .noData
                debugPrint(error)
            }
        }
    }
    
    func setState(_ state: ViewState) async {
        await MainActor.run {
            self.state = state
        }
    }
    
    func setSelectedCity(_ city: String) {
        self.selectedCity = city
        self.response = nil
    }
    
    func saveSelectedCity(_ city: String?) {
        if let city {
            UserDefaults.standard.set(city, forKey: HomeViewModel.cityKey)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.removeObject(forKey: HomeViewModel.cityKey)
        }
    }
    
    func noCityText() -> String {
        "No City Selected"
    }
    
    func noCitySubText() -> String {
        "Please search for a city"
    }
    
    func getCityName() -> String {
        response?.location?.name ?? ""
    }
    
    func getWeatherIcon() -> String {
        let res = response?.weatherData?.condition.icon ?? ""
        return "http:" + res
    }
    
    func getTemperature() -> String {
        let res = response?.weatherData?.temp ?? 0.0
        return String(res)
    }
    
    func getHumidity() -> String {
        let res = response?.weatherData?.humidity ?? 0.0
        return String(res)
    }
    
    func getUV() -> String {
        let res = response?.weatherData?.uv ?? 0.0
        return String(res)
    }
    
    func getFeelsLike() -> String {
        let res = response?.weatherData?.feelsLikeTemp ?? 0.0
        return String(res)
    }
    
    static func getInstance() -> HomeViewModel {
        return HomeViewModel(service: WeatherService(apiClient: ApiClient.getInstance(session: URLSession.shared)))
    }
}
