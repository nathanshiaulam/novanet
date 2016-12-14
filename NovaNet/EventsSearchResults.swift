//
//  EventsSearchResults.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/21/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse
import GoogleMaps

protocol LocateOnTheMap{
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String)
}

class EventsSearchResults: TableViewController {
    var searchResults: [String]!
    var delegate: LocateOnTheMap!
    
    override func viewDidLoad() {
        self.searchResults = Array()
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "resultCell");
    }
    

    func reloadDataWithArray(_ array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    
    /* TABLEVIEW DELEGATE METHODS */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        
        cell.textLabel?.text = self.searchResults[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil);
        
        let correctedAddress:String = self.searchResults[(indexPath as NSIndexPath).row]
        var urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false"
        urlString = urlString.addingPercentEscapes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        print(urlString)
        let url = URLRequest(url: URL(string: urlString as String)!)

        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) -> Void in
            do {
                if data != nil{
                    let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    if let result = json["results"] as? NSArray {
                        if let values = result[0] as? NSDictionary {
                            if let geometry = values["geometry"] as? NSDictionary {
                                if let location = geometry["location"] as? NSDictionary {
                                    let latitude = location["lat"] as! Double
                                    let longitude = location["lng"] as! Double
                                    self.delegate.locateWithLongitude(longitude, andLatitude: latitude, andTitle: self.searchResults[(indexPath as NSIndexPath).row] )
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error")
            }
        }) 
        task.resume();
    }


}
