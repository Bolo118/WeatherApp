//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Adithep on 7/29/20.
//  Copyright © 2020 Adithep. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=a90c476c0fa0933f71c18412d16d300c&units=metric"
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        // Networking
        // 1. create a URL
        // 2. create a URLSession
        // 3. give the session a task
        // 4. start the task
        
        // 1. Create a URL
        if let url = URL(string: urlString) {
            
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // 4. start the task
            task.resume()
        }
    }
    
    // fetch data from API
    func parseJSON(weatherData: Data) -> WeatherModel? {
        // take data from JSON format through WeatherData structure
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let main = decodedData.weather[0].main
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, description: main)
            
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func setBackground() -> String {
        let randomNumber = Int.random(in: 1...6)
        
        switch randomNumber {
        case 1:
            return "sun"
        case 2:
            return "buildings"
        case 3:
            return "colorful cloud"
        case 4:
            return "green cloud"
        case 5:
            return "pinkandbluecloud"
        default:
            return "mountain"
        }
    }
}
