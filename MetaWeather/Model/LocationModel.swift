//
//  LocationModel.swift
//  MetaWeather
//
//  Created by Saurabh Anand on 7/16/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import Foundation

class LocationModel{
    var locationId : Int
    var locationType : String
    var locationTitle : String
    
    init() {
        locationId = 0
        locationType = ""
        locationTitle = ""
    }
    
    init(locId: Int, locType: String, locTitle: String) {
        locationId = locId
        locationType = locType
        locationTitle = locTitle
    }
}
