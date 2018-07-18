//
//  WeatherViewModel.swift
//  MetaWeather
//
//  Created by Saurabh Anand on 7/16/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreData

class WeatherViewModel{

    var searchHistories = [SearchHistory]()
    
    let searchHistoryContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //Constants
    let baseURL = "https://www.metaweather.com/api/location"
    
    var httpHeaders : [String:String] = ["Content-Type" : "application/json", "Accept": "application/json"]

    //MARK: - Get Location using Longitude and Latitude
    /***************************************************************/

    /// This function returns a Location Details for a given longitude and latitude.
    ///
    /// - Warning: Error message is not localized
    ///
    /// Usage:
    ///
    ///     This method is used to fetch location details by using longitude and latitude as parameters
    ///
    /// - Parameter latitude: Latitude passed from Location Manager.
    /// - Parameter longitude: Longitude passed from Location Manager.
    ///
    /// - Returns: Location Details as Array of Locaton Model and Error Message as String

    func getLocationWithLattitudeAndLongitude(latitude: String, longitude: String, completionHandler: @escaping ([LocationModel],String) -> Void) {
        
        Alamofire.request("\(baseURL)/search/?lattlong=\(latitude),\(longitude)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { (response) in
            if response.result.isSuccess{
                
                print(response.result.value!)
                if let responseData = response.result.value! as? [[String:Any]]{
                    var locationList = [LocationModel]()
                    
                    for item in responseData{
                        let locationModel = LocationModel()
                        
                        if let woeid = item["woeid"]  as? Int {
                            locationModel.locationId = woeid
                        }
                        if let locType = item["location_type"]  as? String {
                            locationModel.locationType = locType
                        }
                        if let locTitle = item["title"]  as? String {
                            locationModel.locationTitle = locTitle
                        }
                        
                        locationList.append(locationModel)
                    }
                    
                    completionHandler(locationList,"")
                } else {
                    completionHandler([LocationModel](),(response.error?.localizedDescription)!)
                }
            } else{
                completionHandler([LocationModel](),(response.error?.localizedDescription)!)
            }
        }
    }
    
    
    //MARK: - Get Location using search text
    /***************************************************************/

    /// This function returns a Location Details for a given location name.
    ///
    /// - Warning: Error message is not localized
    ///
    /// Usage:
    ///
    ///     This method is used to fetch location details by using location name as parameters. It will save name and time stamp fr search history in core data.
    ///
    /// - Parameter name: location name passed from Search Screen
    ///
    /// - Returns: Location Details as Array of Locaton Model and Error Message as String
    
    func getLocationWithName(name: String, completionHandler: @escaping ([LocationModel],String) -> Void) {
        
        let searchHistory = SearchHistory(context: searchHistoryContext)
        searchHistory.historyTime = NSDate() as Date
        searchHistory.locationHistory = "name"
        searchHistories.append(searchHistory)
        
        saveContext()

        let encoded = name.addingPercentEncoding(withAllowedCharacters: .alphanumerics)

        Alamofire.request("\(baseURL)/search/?query=\(encoded!)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { (response) in
            if response.result.isSuccess{
                
                print(response.result.value!)
                if let responseData = response.result.value! as? [[String:Any]]{
                    var locationList = [LocationModel]()
                    
                    for item in responseData{
                        let locationModel = LocationModel()
                        if let woeid = item["woeid"]  as? Int {
                            locationModel.locationId = woeid
                        }
                        if let locType = item["location_type"]  as? String {
                            locationModel.locationType = locType
                        }
                        if let locTitle = item["title"]  as? String {
                            locationModel.locationTitle = locTitle
                        }
                        
                        locationList.append(locationModel)
                    }
                    completionHandler(locationList,"")
                } else {
                    completionHandler([LocationModel](),(response.error?.localizedDescription)!)
                }
            } else{
                completionHandler([LocationModel](),(response.error?.localizedDescription)!)
            }
        }
    }
    
    
    //MARK: - Get weather using woeid
    /***************************************************************/

    /// This function returns a Weather Details for a given woeid.
    ///
    /// - Warning: Error message is not localized
    ///
    /// Usage:
    ///
    ///     This method is used to fetch weather details by using woeid as parameters.
    ///
    /// - Parameter woeid: location id once selected from search results screen
    ///
    /// - Returns: Weather Details as Array of Weather Model and Error Message as String
    
    func getWeather(woeid: Int, completionHandler: @escaping ([WeatherDetailModel],String) -> Void) {
        
        Alamofire.request("\(baseURL)/\(woeid)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { (response) in
            if response.result.isSuccess{
                
                print(response.result.value!)
                if let responseData = response.result.value! as? Dictionary<String, Any>{
                    
                    var cityName : String = ""
                    if let locName = responseData["title"] as? String{
                        cityName = locName
                    }
                    var weatherList = [WeatherDetailModel]()
                    
                    for item in (responseData["consolidated_weather"] as? [[String:Any]])!{
                        let weatherModel = WeatherDetailModel()
                        weatherModel.locationName = cityName
                        
                        if let appDate = item["applicable_date"] as? String {
                            weatherModel.applicableDate = appDate
                        }
                        if let currentTemp = item["the_temp"] as? NSNumber {
                            weatherModel.currentTemperature = currentTemp.intValue
                        }
                        if let minTemp = item["min_temp"] as? NSNumber {
                            weatherModel.minimumTemperature = minTemp.intValue
                        }
                        if let maxTemp = item["max_temp"] as? NSNumber {
                            weatherModel.maximumTemperature = maxTemp.intValue
                        }
                        weatherList.append(weatherModel)
                    }
                    completionHandler(weatherList,"")
                } else {
                    completionHandler([WeatherDetailModel](),(response.error?.localizedDescription)!)
                }
            } else{
                completionHandler([WeatherDetailModel](),(response.error?.localizedDescription)!)
            }
        }
    }
    
    //MARK: - Core Data methods
    /***************************************************************/
    
    // Fetching the data from persistent container
    func fetchItem(){
        let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "historyTime", ascending: false)]

        do {
            searchHistories = try searchHistoryContext.fetch(request)
        } catch{
            print("Error fetching data from context \(error)")
        }
    }
    
    // saving the data in manageobject context and then save to persistent layer
    func saveContext(){
        if searchHistoryContext.hasChanges{
            do{
                try searchHistoryContext.save()
            } catch{
                print("Error in saving context \(error)")
                
            }
        }
    }
    
}
