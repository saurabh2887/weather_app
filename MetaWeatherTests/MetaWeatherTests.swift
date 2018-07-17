//
//  MetaWeatherTests.swift
//  MetaWeatherTests
//
//  Created by Saurabh Anand on 7/17/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import XCTest

@testable import MetaWeather

class MetaWeatherTests: XCTestCase {
    
    var testViewModel: WeatherViewModel!
    
    override func setUp() {
        super.setUp()
        
        testViewModel = WeatherViewModel()        
    }
    
    override func tearDown() {
        testViewModel = nil
        super.tearDown()
    }
    
    func test_getLocationWithLattitudeAndLongitude(){
        
        var isFetched = false
        
        testViewModel.getLocationWithLattitudeAndLongitude(latitude: "50.068", longitude: "-5.316") { (locationArray, errorMsg) in
            if errorMsg.count == 0{
                isFetched = true
            }
        }
        
        XCTAssertFalse(isFetched)
    }
    
    func test_getLocationWithName(){
        
        var isFetched = false
        
        testViewModel.getLocationWithName(name: "San Fran") { (locationArray, errorMsg) in
            if errorMsg.count == 0{
                isFetched = true
            }
        }
        
        XCTAssertFalse(isFetched)
    }

    
    func test_getWeather(){
        var isAbleToFetch = false
        
        testViewModel.getWeather(woeid: 2487956) { (weatherArray, errorMsg) in
            if errorMsg.count == 0{
                isAbleToFetch = true
            }
        }

        XCTAssertFalse(isAbleToFetch)
    }
    
}
