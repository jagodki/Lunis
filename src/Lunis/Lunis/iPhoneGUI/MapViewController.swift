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
import CoreData


/// This class is the controller for the first view of the map tab.
class MapViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    
    // MARK: - instance variables
    var locationManager: CLLocationManager!
    var postionIsShown: Bool!
    var zoomToPosition: Bool!
    var mapContent: Int!
    
    // MARK: - methods
    
    /// Constructor of this class.
    override func viewDidLoad() {
        //configure location manager
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 25.0      //25 meter
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.showEnableLocationAlert()
        }
        
        //hint to zoom to the position after the next button press
        self.postionIsShown = false
        self.zoomToPosition = true
        
        //init the map content
        self.mapContent = 0
        
        
        //write test data to coredata
        var testDataCities: [NSManagedObject] = []
        var testDataSchools: [NSManagedObject] = []
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entityCity = NSEntityDescription.entity(forEntityName: "City", in: managedContext)!
        let entitySchools = NSEntityDescription.entity(forEntityName: "School", in: managedContext)!
        
        let city = NSManagedObject(entity: entityCity, insertInto: managedContext)
        let school1 = NSManagedObject(entity: entityCity, insertInto: managedContext)
        let school2 = NSManagedObject(entity: entityCity, insertInto: managedContext)
        
        city.setValue("Radebeul", forKeyPath: "name")
        city.setValue("Sachsen", forKeyPath: "region")
        city.setValue("Deutschland", forKeyPath: "country")
        city.setValue("Deutschland", forKeyPath: "path")
        city.setValue("Deutschland", forKeyPath: "lastUpdate")
        city.setValue(51.110218, forKeyPath: "x")
        city.setValue(13.641750, forKeyPath: "y")
        
        school1.setValue("Radebeul", forKeyPath: "name")
        school1.setValue("Radebeul", forKeyPath: "city")
        school1.setValue("Radebeul", forKeyPath: "mail")
        school1.setValue("Radebeul", forKeyPath: "street")
        school1.setValue("Radebeul", forKeyPath: "number")
        school1.setValue("Radebeul", forKeyPath: "path")
        school1.setValue("Radebeul", forKeyPath: "phone")
        school1.setValue("Radebeul", forKeyPath: "postalCode")
        school1.setValue("Radebeul", forKeyPath: "schoolSpecialisation")
        school1.setValue("Radebeul", forKeyPath: "schoolType")
        school1.setValue("Radebeul", forKeyPath: "website")
        school1.setValue("Radebeul", forKeyPath: "wikipedia")
        school1.setValue("Radebeul", forKeyPath: "x")
        school1.setValue("Radebeul", forKeyPath: "y")
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// This function sets the searchbar as visible or hidden.
    ///
    /// - Parameter sender: any
    @IBAction func showHideSearchBar(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    /// This function shows the current position of the user in the map view.
    ///
    /// - Parameter sender: any
    @IBAction func showUserPosition(_ sender: Any) {
        //check status of the button
        if self.postionIsShown {
            self.locationManager.stopUpdatingLocation()
            self.mapView.showsUserLocation = false
            self.postionIsShown = false
            self.zoomToPosition = true
        } else {
            //sender.isSelected = true
            
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                self.locationManager.startUpdatingLocation()
                self.mapView.showsUserLocation = true
                self.postionIsShown = true
            } else {
                self.showEnableLocationAlert()
            }
        }
    }
    
    /// This function zooms the map view to the last user position in the given array of user positions.
    ///
    /// - Parameters:
    ///   - manager: the CLLocationManager
    ///   - locations: an array of the positions
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
    }
    
    /// This function show an alert, whether location services are disabled for this app.
    func showEnableLocationAlert() {
        let alert = UIAlertController(title: "Info", message: "Location Services are not enabled. Your location cannot be shown in the map.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// This function creates and displays an alert controller to let the user choose the data content of the map view.
    ///
    /// - Parameter sender: any
    @IBAction func selectMapContent(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Map Content", message: "Choose Map Content", preferredStyle: .actionSheet)
        
        //define the actions
        let allAction = UIAlertAction(title: "All schools", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("all schools")
            self.mapContent = 0
        })
        
        let filteredAction = UIAlertAction(title: "Filtered schools", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("filtered schools")
            self.mapContent = 1
        })
        
        let favoritesAction = UIAlertAction(title: "Favorite schools", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("canceled")
            self.mapContent = 2
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("canceled")
        })
        
        //add the checkmark to the current selection
        let image = UIImage(named: "checkmark")
        switch self.mapContent {
        case 0:
            allAction.setValue(image, forKey: "image")
        case 1:
            filteredAction.setValue(image, forKey: "image")
        case 2:
            favoritesAction.setValue(image, forKey: "image")
        default:
            break
        }
        
        //add actions to the action sheet
        actionSheet.addAction(allAction)
        actionSheet.addAction(filteredAction)
        actionSheet.addAction(favoritesAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func showHideIsodistances(_ sender: Any) {
    }
    
}

