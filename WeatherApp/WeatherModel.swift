//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Saidac Alexandru on 04.12.2022.
//

import Foundation


struct WeatherModel :Decodable{
    let main:MainModel
    let weather:[WeatherInfoModel]
    
    
    
}

struct MainModel :Decodable{
    let temp: Double
    let humidity: Int
}

struct WeatherInfoModel :Decodable{
    let description: String
    let icon: String
    
}
