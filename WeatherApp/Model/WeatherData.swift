//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Adithep on 7/29/20.
//  Copyright © 2020 Adithep. All rights reserved.
//

import Foundation

// deal with the data come from JSON format
// decodable and encodable

struct WeatherData: Codable {
    
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let main: String
    let id: Int
}
