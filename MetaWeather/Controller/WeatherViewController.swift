//
//  WeatherViewController.swift
//  MetaWeather
//
//  Created by Saurabh Anand on 7/16/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UITableViewController {

    @IBOutlet weak var navigationItemOutlet: UINavigationItem!
    
    var weatherList = [WeatherDetailModel]()
    
    //setting up the lazy property to call when in use
    lazy var viewModel: WeatherViewModel = {
        return WeatherViewModel()
    }()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItemOutlet?.title = "Weather"
        
        //Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSearch"{
            let destinationVC = segue.destination as! SearchResultsTableViewController
            destinationVC.viewModel = viewModel
            destinationVC.delegate = self
        }
    }
    
    // MARK: - Error Handling
    // If there is an error, then move to Search Screen
    func showAlert(errorMsg: String) {
        let alert = UIAlertController(title: "Alert", message: errorMsg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.performSegue(withIdentifier: "goToSearch", sender: self)
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    
    //MARK: - Get Weather Details
    func getWeatherDetail(woeid: Int){
        viewModel.getWeather(woeid: woeid) { (weatherArray, errorMsg) in
            if errorMsg.count > 0{
                self.showAlert(errorMsg: errorMsg)
            } else {
                self.weatherList = weatherArray
                if let weatherModel = weatherArray.first{
                    self.navigationItemOutlet?.title = weatherModel.locationName
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Search Bar Button Action
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToSearch", sender: self)
    }
    
}

//MARK: - Location Manager Delegate Methods
/***************************************************************/

extension WeatherViewController: CLLocationManagerDelegate{
    
    /// This delegate function returns Longitude details and then calls the service to fetch location details
    /// Get Weather Details, once we get the location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            viewModel.getLocationWithLattitudeAndLongitude(latitude:latitude, longitude: longitude) { (locationArray, errorMsg) in
                if errorMsg.count > 0{
                    self.showAlert(errorMsg: errorMsg)
                } else {
                    if locationArray.count > 0{
                        if let location = locationArray.first{
                            self.getWeatherDetail(woeid: location.locationId)
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(errorMsg: "Couldn't find current location!")
    }
}

//MARK: - Table view delegates
/***************************************************************/

extension WeatherViewController{
    //MARK: - Table view data source
    /***************************************************************/
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return weatherList.count
    }
    
    
    //MARK: - Table view delegates
    /***************************************************************/
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherItemCell", for: indexPath)
        
        let weatherModel = weatherList[indexPath.row]
        
        cell.textLabel?.text = "Dt: \(weatherModel.applicableDate) | T: \(weatherModel.currentTemperature)° | MinT:\(weatherModel.minimumTemperature)° | MaxT: \(weatherModel.maximumTemperature)°"
        
        return cell
    }
}

//MARK: - SearchResultsDelegate
/***************************************************************/

extension WeatherViewController: SearchResultsDelegate{
    
    func getWeather(woeid: Int) {
        getWeatherDetail(woeid: woeid)
    }
    
}
