
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

class EventsLocationFinder: ViewController, UISearchBarDelegate, LocateOnTheMap {
    let placesClient = GMSPlacesClient()
    var selectedLocation:GMSMarker!;
    
    @IBOutlet weak var setEventButton: UIButton!
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    
    @IBAction func centerSelfPressed(sender: AnyObject) {
        centerOnSelf();
    }
    @IBAction func showSearchController(sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.presentViewController(searchController, animated: true, completion: nil)
    }

    @IBAction func setEventPressed(sender: UIButton) {
        if let currentLocation = googleMapsView.selectedMarker {
            NSNotificationCenter.defaultCenter().postNotificationName("saveNewLocation", object: currentLocation);

            self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
        } else {
            let errorString = "We're sorry, but your location has not been set yet."
            let alert = UIAlertController(title: "Submission Failure", message: errorString as String, preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title:"Ok", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil);
            
        }
    }
    @IBAction func backPressed(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
    }
    var searchResultController:EventsSearchResults!
    var resultsArray = [String]()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setEventButton.layer.cornerRadius = 5.0
        searchResultController = EventsSearchResults()
        searchResultController.delegate = self
        self.navigationController?.navigationBar.barTintColor = Utilities().UIColorFromHex(0xFC6706, alpha: 1.0)
        if selectedLocation == nil {
            centerOnSelf();
        } else {
            let placeMark = MKPlacemark(coordinate: selectedLocation.position, addressDictionary: nil);
            let mapItem = MKMapItem(placemark: placeMark);
            mapItem.name = selectedLocation.title;
            centerOnItem(mapItem);
        }
    }
    
    func centerOnSelf() {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil && geoPoint != nil {
                let camera = GMSCameraPosition.cameraWithLatitude(geoPoint!.latitude, longitude: geoPoint!.longitude, zoom: 15);
                self.googleMapsView.camera = camera;
                
            } else {
                print(error);
            }
        }
    }
    func centerOnItem(item:MKMapItem) {
        
        let marker:GMSMarker = GMSMarker();
        marker.position = item.placemark.coordinate;
//        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = self.googleMapsView;
        marker.title = item.name;
        
        let lat = item.placemark.coordinate.latitude;
        let lon = item.placemark.coordinate.longitude
        
        let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 15);
        
        self.googleMapsView.camera = camera
        marker.map = self.googleMapsView
        self.googleMapsView.selectedMarker = marker
        
    }
    
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            
            let camera  = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 15)
            self.googleMapsView.camera = camera
            
            
            marker.title = title
            marker.map = self.googleMapsView
            self.googleMapsView.selectedMarker = marker
        }
    }
    

    /* SEARCHBAR DELEGATE METHODS */
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        
        let visibleRegion = self.googleMapsView.projection.visibleRegion();
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.nearLeft, coordinate: visibleRegion.nearRight)
        
        placesClient.autocompleteQuery(searchText, bounds: bounds, filter: nil) { (
            results, error:NSError?) -> Void in
            self.resultsArray.removeAll()
            if results == nil {
                print(error);
                return
            }
            for result in results!{
                self.googleMapsView.clear();
                if let result = result as? GMSAutocompletePrediction{
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        }
    }
    
    func searchBarSearchButtonClicked (searchBar: UISearchBar) {
       
        self.dismissViewControllerAnimated(true, completion: nil);
        let searchRequest:MKLocalSearchRequest = MKLocalSearchRequest();
        searchRequest.naturalLanguageQuery = searchBar.text;
        
        searchRequest.region = MKCoordinateRegionMake(self.googleMapsView.camera.target, MKCoordinateSpanMake(0.075, 0.075));
        
        let search = MKLocalSearch(request: searchRequest);
        
        search.startWithCompletionHandler {
            (searchResponse, error) -> Void in
            if (searchResponse != nil && error == nil) {
                self.googleMapsView.clear();
                var threshold = 0;
                if searchResponse?.mapItems.count > 10 {
                    threshold = 10;
                } else {
                    threshold = searchResponse!.mapItems.count;
                }
                if let firstItem = searchResponse?.mapItems[0] {
                    self.centerOnItem(firstItem);
                }

                for i in 0..<threshold {
                    let item = searchResponse?.mapItems[i];
                    
                    let marker:GMSMarker = GMSMarker();
                    marker.position = item!.placemark.coordinate;
//                    marker.appearAnimation = kGMSMarkerAnimationPop;
                    marker.map = self.googleMapsView;
                    marker.title = item!.name;
                }
            } else {
                print(error);
            }
        }
    }
    
}
