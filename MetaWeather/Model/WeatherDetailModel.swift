//
//  WeatherDetailModel.swift
//  MetaWeather
//
//  Created by Saurabh Anand on 7/16/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import UIKit

class WeatherDetailModel{
    var minimumTemperature : Int
    var maximumTemperature : Int
    var currentTemperature : Int
    var applicableDate : String
    var locationName : String

    init() {
        minimumTemperature = 0
        maximumTemperature = 0
        currentTemperature = 0
        applicableDate = ""
        locationName = ""
    }
    
    init(minTemp: Int, maxTemp: Int, currentTemp: Int, applDate: String, locName:String) {
        minimumTemperature = minTemp
        maximumTemperature = maxTemp
        currentTemperature = currentTemp
        applicableDate = applDate
        locationName = locName
    }
}
