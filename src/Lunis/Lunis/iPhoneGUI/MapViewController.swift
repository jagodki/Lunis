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
        
        let entityCity = NSEntityDescription.entity(forEntityName: "Administration", in: managedContext)!
        let entitySchools = NSEntityDescription.entity(forEntityName: "School", in: managedContext)!
        
        let city1 = NSManagedObject(entity: entityCity, insertInto: managedContext)
        let city2 = NSManagedObject(entity: entityCity, insertInto: managedContext)
        let school1 = NSManagedObject(entity: entitySchools, insertInto: managedContext)
        let school2 = NSManagedObject(entity: entitySchools, insertInto: managedContext)
        
        city1.setValue("Radebeul", forKeyPath: "city")
        city1.setValue("Sachsen", forKeyPath: "region")
        city1.setValue("Deutschland", forKeyPath: "country")
        city1.setValue("", forKeyPath: "path")
        city1.setValue(NSDate(), forKeyPath: "lastUpdate")
        city1.setValue(51.110218, forKeyPath: "x")
        city1.setValue(13.641750, forKeyPath: "y")
        
        city2.setValue("Meißen", forKeyPath: "city")
        city2.setValue("Sachsen", forKeyPath: "region")
        city2.setValue("Deutschland", forKeyPath: "country")
        city2.setValue("", forKeyPath: "path")
        city2.setValue(NSDate(), forKeyPath: "lastUpdate")
        city2.setValue(51.166734, forKeyPath: "x")
        city2.setValue(13.473048, forKeyPath: "y")
        
        school1.setValue("Lößnitzgymnasium", forKeyPath: "name")
        school1.setValue("Radebeul", forKeyPath: "city")
        school1.setValue("info@test.xyz", forKeyPath: "mail")
        school1.setValue("Steinbachstraﬂe", forKeyPath: "street")
        school1.setValue("21", forKeyPath: "number")
        school1.setValue("", forKeyPath: "path")
        school1.setValue("0351/12345678", forKeyPath: "phone")
        school1.setValue("01445", forKeyPath: "postalCode")
        school1.setValue("sprachlich, k¸nstlerich", forKeyPath: "schoolSpecialisation")
        school1.setValue("Gymnasium", forKeyPath: "schoolType")
        school1.setValue("https://www.loessnitzgymnasium-radebeul.de", forKeyPath: "website")
        school1.setValue("https://de.wikipedia.org/wiki/L%C3%B6%C3%9Fnitzgymnasium", forKeyPath: "wikipedia")
        school1.setValue(51.104209, forKeyPath: "x")
        school1.setValue(13.659038, forKeyPath: "y")
        
        school2.setValue("Sächsisches Landesgymnasium Sankt Afra", forKeyPath: "name")
        school2.setValue("Meißen", forKeyPath: "city")
        school2.setValue("info@test.xyz", forKeyPath: "mail")
        school2.setValue("Freiheit", forKeyPath: "street")
        school2.setValue("13", forKeyPath: "number")
        school2.setValue("", forKeyPath: "path")
        school2.setValue("03521/87654321", forKeyPath: "phone")
        school2.setValue("01662", forKeyPath: "postalCode")
        school2.setValue("sprachlich, k¸nstlerich, naturwissenschaftlich", forKeyPath: "schoolSpecialisation")
        school2.setValue("Gymnasium", forKeyPath: "schoolType")
        school2.setValue("http://www.sankt-afra.de/", forKeyPath: "website")
        school2.setValue("https://de.wikipedia.org/wiki/S%C3%A4chsisches_Landesgymnasium_Sankt_Afra", forKeyPath: "wikipedia")
        school2.setValue(51.163543, forKeyPath: "x")
        school2.setValue(13.467966, forKeyPath: "y")
        
        testDataCities.append(city1)
        testDataCities.append(city2)
        testDataSchools.append(school1)
        testDataSchools.append(school2)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
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

