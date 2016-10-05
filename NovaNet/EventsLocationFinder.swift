
//
//  EventsLocationFinder.swift
//  NovaNet
//
//  Created by Nathan Lam on 11/21/15.
//  Copyright © 2015 Nova. All rights reserved.
//

import Foundation
import Bolts
import Parse
import GoogleMaps
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class EventsLocationFinder: ViewController, UISearchBarDelegate, LocateOnTheMap {
    let placesClient = GMSPlacesClient()
    var selectedLocation:GMSMarker!
    
    @IBOutlet weak var setEventButton: UIButton!
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    

    @IBAction func showSearchController(_ sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        searchController.searchBar.setValue("CANCEL", forKey:"_cancelButtonText")

        self.present(searchController, animated: true, completion: nil)
    }

    @IBAction func setEventPressed(_ sender: UIButton) {
        if let currentLocation = googleMapsView.selectedMarker {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "saveNewLocation"), object: currentLocation)
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            let errorString = "We're sorry, but your location has not been set yet."
            let alert = UIAlertController(title: "Submission Failure", message: errorString as String, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    var searchResultController:EventsSearchResults!
    var resultsArray = [String]()
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true

        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setEventButton.layer.cornerRadius = 5.0
        searchResultController = EventsSearchResults()
        searchResultController.delegate = self
        
        if selectedLocation == nil {
            centerOnSelf()
        } else {
            let placeMark = MKPlacemark(coordinate: selectedLocation.position, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placeMark)
            mapItem.name = selectedLocation.title
            centerOnItem(mapItem)
        }
    }
    
    func centerOnSelf() {
        PFGeoPoint.geoPointForCurrentLocation {
            (geoPoint: PFGeoPoint?, error: Error?) -> Void in
            if error == nil && geoPoint != nil {
                let camera = GMSCameraPosition.camera(withLatitude: geoPoint!.latitude, longitude: geoPoint!.longitude, zoom: 15)
                self.googleMapsView.camera = camera
                
            } else {
                print(error)
            }
        }
    }
    func centerOnItem(_ item:MKMapItem) {
        
        let marker:GMSMarker = GMSMarker()
        marker.position = item.placemark.coordinate
        marker.map = self.googleMapsView
        marker.title = item.name
        
        let lat = item.placemark.coordinate.latitude
        let lon = item.placemark.coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15)
        
        self.googleMapsView.camera = camera
        marker.map = self.googleMapsView
        self.googleMapsView.selectedMarker = marker
        
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)

            let camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15)
            self.googleMapsView.camera = camera
            
            marker?.title = title
            marker?.map = self.googleMapsView
            self.googleMapsView.selectedMarker = marker
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        let visibleRegion = self.googleMapsView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.nearLeft, coordinate: visibleRegion.nearRight)
        
        placesClient.autocompleteQuery(searchText, bounds: bounds, filter: nil) { (
            results, error:Error?) -> Void in
            self.resultsArray.removeAll()
            if results == nil {
                print(error)
                return
            }
            for result in results!{
                self.googleMapsView.clear()
                if let result = result as? GMSAutocompletePrediction{
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        }
    }
    
    func searchBarSearchButtonClicked (_ searchBar: UISearchBar) {
       
        self.dismiss(animated: true, completion: nil)
        let searchRequest:MKLocalSearchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        searchRequest.region = MKCoordinateRegionMake(self.googleMapsView.camera.target, MKCoordinateSpanMake(0.075, 0.075))
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start {
            (searchResponse, error) -> Void in
            if (searchResponse != nil && error == nil) {
                self.googleMapsView.clear()
                var threshold = 0
                if searchResponse?.mapItems.count > 10 {
                    threshold = 10
                } else {
                    threshold = searchResponse!.mapItems.count
                }
                if let firstItem = searchResponse?.mapItems[0] {
                    self.centerOnItem(firstItem)
                }

                for i in 0..<threshold {
                    let item = searchResponse?.mapItems[i]
                    
                    let marker:GMSMarker = GMSMarker()
                    marker.position = item!.placemark.coordinate
//                    marker.icon = UIImage(named: "mapAnnotationUp")
                    marker.map = self.googleMapsView
                    marker.title = item!.name
                }
            } else {
                print(error)
            }
        }
    }
    
}
