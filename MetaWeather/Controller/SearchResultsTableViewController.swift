//
//  SearchResultsTableViewController.swift
//  MetaWeather
//
//  Created by Saurabh Anand on 7/16/18.
//  Copyright © 2018 Saurabh Anand. All rights reserved.
//

import UIKit

protocol SearchResultsDelegate {
    func getWeather(woeid: Int)
}

class SearchResultsTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    var locationList = [LocationModel]()

    var delegate : SearchResultsDelegate?
    
    var viewModel : WeatherViewModel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This method is to fetch search history from core data
        viewModel.fetchItem()
    }
    
    // MARK: - Error Handling
    func showAlert(errorMsg: String) {
        let alert = UIAlertController(title: "Alert", message: errorMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

//MARK: - Table view data source and delegates
/***************************************************************/

extension SearchResultsTableViewController{
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locationList.count
    }
    
    
    //MARK: - Table view delegates
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsItemCell", for: indexPath)
        
        let locationModel = locationList[indexPath.row]
        
        cell.textLabel?.text = "\(locationModel.locationTitle) | Type:\(locationModel.locationType) | ID: \(locationModel.locationId)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //If we have a delegate set, call the method getWeather
        let locationModel = locationList[indexPath.row]
    
        delegate?.getWeather(woeid: locationModel.locationId)
    
        //dismiss the Search Results View Controller to go back to the WeatherViewController
        navigationController?.popToRootViewController(animated: true)
    }
}


//MARK: - UISearchResultsUpdating
/***************************************************************/

extension SearchResultsTableViewController: UISearchBarDelegate{
    
    /// Calls the service to fetch location details, once search button clicked

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text{
            
            viewModel.getLocationWithName(name: searchText) { (locationArray, errorMsg) in
                if errorMsg.count > 0{
                    self.showAlert(errorMsg: errorMsg)
                } else {
                    self.locationList = locationArray
                    self.tableView.reloadData()
                }
            }
        }
    }
}
