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
    
    //IBOutlets
    @IBOutlet var mapView: MKMapView!
    
    //location vars
    var locationManager: CLLocationManager!
    var postionIsShown: Bool!
    var zoomToPosition: Bool!
    
    override func viewDidLoad() {
        //configure location manager
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 100.0
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.showEnableLocationAlert()
        }
        
        //hint to zoom to the position after the next button press
        self.postionIsShown = false
        self.zoomToPosition = true
        
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
            //sender.isSelected = false
            self.locationManager.stopUpdatingLocation()
            self.mapView.showsUserLocation = false
            self.postionIsShown = false
        } else {
            //sender.isSelected = true
            
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                self.locationManager.startUpdatingLocation()
                self.mapView.showsUserLocation = true
                //sender.highlighted = true
                self.postionIsShown = true
            } else {
                self.showEnableLocationAlert()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.zoomToPosition {
            //zoom to user position
            if let location = locations.last  {
                let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                let currentPosition:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                let region = MKCoordinateRegionMake(currentPosition, span)
                self.mapView.setRegion(region, animated: true)
            }
            self.zoomToPosition = false
        }
        else {
            self.zoomToPosition = true
        }
    }
    
    func showEnableLocationAlert() {
        let alert = UIAlertController(title: "Info", message: "Location Services are not enabled. Your location cannot be shown in the map.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

