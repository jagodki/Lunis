//
//  MapViewController.swift
//  Lunis
//
//  Created by Christoph on 29.05.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    //location vars
    var locationManager: CLLocationManager!
    var postionIsShown: Bool!
    var zoomToPosition: Bool!
    
    override func viewDidLoad() {
        //enable location manager
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 250.0        //250m
        } else {
            // create the alert
            let alert = UIAlertController(title: "UIAlertController", message: "Location Services are not allowed. Your location cannot be shown in the map", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
        //control the users position
        postionIsShown = false
        zoomToPosition = true
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showHideSearchBar(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func showUserPosition(_ sender: Any) {
        //check status of the button
        if self.postionIsShown {
            sender.isSelected = false
            self.locationManager.stopUpdatingLocation()
            //sender.highlighted = false
            self.postionIsShown = false
            self.zoomToPosition = true
        } else {
            sender.isSelected = true
            
            //check the authorization status for location
            if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
            } else {
                self.locationManager.startUpdatingLocation()
            }
            
            //sender.highlighted = true
            self.postionIsShown = true
            self.zoomToPosition = false
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last {
            
            //zoom to user position
            if self.zoomToPosition {
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDealta: 0.0001, longitudeDelta: 0.0001))
                self.map.setRegion(region, animated: true)
                self.map.userTrackingMode.set(.follow)
            }
            
            //insert marker at user position
            self.map.showsUserLocation.set(true)
            self.map.userTrackingMode.set(.none)
        }
    }
}

