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
class MapViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    
    // MARK: - instance variables
    var locationManager: CLLocationManager!
    var postionIsShown: Bool!
    var zoomToPosition: Bool!
    var mapContent: Int!
    var searchController: UISearchController!
    
    //the data controller for connecting to core data
    var dataController: DataController!
    var fetchedResultsControllerSchools: NSFetchedResultsController<SchoolMO>!
    var fetchedResultsControllerAdministrations: NSFetchedResultsController<AdministrationMO>!
    
    //a tableviewontroller to store the search results
    var searchResultsController: UITableViewController!
    
    //store the searched schools
    var searchedSchools: [SchoolMO] = [SchoolMO]()
    
    // MARK: - methods
    
    /// Constructor of this class.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init the searchresultcontroller
        self.searchResultsController = UITableViewController(style: .plain)
        self.searchResultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchedSchoolsCell")
        self.searchResultsController.tableView.dataSource = self
        self.searchResultsController.tableView.delegate = self
        
        //set up a searchcontroller and add them to the navigationbar
        searchController = UISearchController(searchResultsController: self.searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search for Schools"
        searchController.searchBar.delegate = self
        //self.navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //set the map view
        self.mapView.delegate = self
        self.mapView.register(SchoolMarkerView.self, forAnnotationViewWithReuseIdentifier: "schoolMarker")
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        
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
        
        //init the data controller
        self.dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
        
        //fetch data from core data and add them to the map
        self.addCoreDataObjectsToTheMap(request: "", zoomToObjects: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //fetch data from core data and add them to the map
        self.addCoreDataObjectsToTheMap(request: "", zoomToObjects: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView implementation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.dismiss(animated: true, completion: nil)
        self.zoomToSchool(schoolName: self.searchedSchools[indexPath.row].name, city: self.searchedSchools[indexPath.row].city)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchedSchoolsCell", for: indexPath)
        cell.textLabel?.text = self.searchedSchools[indexPath.row].name
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedSchools.count
    }
    
    // MARK: - additional methods
    /// This function fetches objects from core data and add them to the map view of this class.an indic
    ///
    /// - Parameter request: a String representing the request for fetching data
    /// - Parameter zoomToObjects: an indicator whether the map view should be zoomed to the loaded map objects
    private func addCoreDataObjectsToTheMap(request: String, zoomToObjects: Bool) {
        //fetch data from core data
        self.fetchedResultsControllerSchools = self.dataController.fetchSchools(request: request, groupedBy: "", orderedBy: "name", orderedAscending: true)
        //self.fetchedResultsControllerAdministrations = self.dataController.fetchAdministations(request: request, groupedBy: "", orderedBy: "city", orderedAscending: true)
        
        //add the fetched data to the map and zoom to it
        self.mapView.addAnnotations(self.fetchedResultsControllerSchools.fetchedObjects!)
        if zoomToObjects {
            self.mapView.showAnnotations(self.fetchedResultsControllerSchools.fetchedObjects!, animated: true)
        }
    }
    
    /// This function fetches objects from core data and add them to the map view of this class.an indic
    ///
    /// - Parameter zoomToObjects: an indicator whether the map view should be zoomed to the loaded map objects
    private func addFilteredCoreDataObjectsToTheMap(zoomToObjects: Bool) {
        //fetch data from core data
        self.fetchedResultsControllerSchools = self.dataController.fetchSchools(filter: true, groupedBy: "", orderedBy: "name", orderedAscending: true)
        
        //add the fetched data to the map and zoom to it
        self.mapView.addAnnotations(self.fetchedResultsControllerSchools.fetchedObjects!)
        if zoomToObjects {
            self.mapView.showAnnotations(self.fetchedResultsControllerSchools.fetchedObjects!, animated: true)
        }
    }
    
    /// This function sets the searchbar as visible or hidden.
    ///
    /// - Parameter sender: any
    @IBAction func showHideSearchBar(_ sender: Any) {
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
    
    func zoomToSchool(schoolName: String, city: String) {
        let annotationToFocusOn = self.fetchedResultsControllerSchools.fetchedObjects?.filter({
            (fetchedSchool: SchoolMO) -> Bool in
            return schoolName == fetchedSchool.name && city == fetchedSchool.city
        })
        self.mapView.showAnnotations(annotationToFocusOn!, animated: true)
    }
    
    /// This function creates and displays an alert controller to let the user choose the data content of the map view.
    ///
    /// - Parameter sender: any
    @IBAction func selectMapContent(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Map Content", message: "Choose Map Content", preferredStyle: .actionSheet)
        
        //define the actions
        let allAction = UIAlertAction(title: "All schools", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapContent = 0
            self.reloadMapContent()
        })
        
        let favoritesAction = UIAlertAction(title: "Favourite schools", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapContent = 1
            self.reloadMapContent()
        })
        
        let filteredAction = UIAlertAction(title: "Filtered schools", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapContent = 2
            self.reloadMapContent()
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
                favoritesAction.setValue(image, forKey: "image")
            case 2:
                filteredAction.setValue(image, forKey: "image")
            default:
                break
        }
        
        //add actions to the action sheet
        actionSheet.addAction(allAction)
        actionSheet.addAction(favoritesAction)
        actionSheet.addAction(filteredAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func reloadMapContent() {
        //remove the current map content
        self.mapView.removeAnnotations(self.fetchedResultsControllerSchools.fetchedObjects!)
        //self.mapView.removeAnnotations(self.fetchedResultsControllerAdministrations.fetchedObjects as! [MKAnnotation])
        
        switch self.mapContent {
        case 0:
            //all schools
            self.addCoreDataObjectsToTheMap(request: "", zoomToObjects: true)
        case 1:
            //favourite schools
            self.addCoreDataObjectsToTheMap(request: "favorite=true", zoomToObjects: true)
        case 2:
            //filtered schools
            self.addFilteredCoreDataObjectsToTheMap(zoomToObjects: true)
        default:
            return
        }
    }
    
    // MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "showSchoolDetailFromMap":
                let viewController = segue.destination as! SchoolDetailView
                viewController.school = self.mapView.selectedAnnotations[0] as! SchoolMO
            
            default:
                _ = true
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "schoolMarker", for: annotation) as? SchoolMarkerView {
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view is SchoolMarkerView {
            performSegue(withIdentifier: "showSchoolDetailFromMap", sender: self)
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension MapViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //get the search text
        let searchText: String = searchController.searchBar.text!
        
        //get the rows of all sections
        let allSchoolRows: [SchoolMO] = self.fetchedResultsControllerSchools.fetchedObjects!
        
        //filter all school rows
        self.searchedSchools = allSchoolRows.filter({(dataViewSchoolCell : SchoolMO) -> Bool in
            return dataViewSchoolCell.name.lowercased().contains(searchText.lowercased())
        })
        
        //reload the table
        self.searchResultsController.tableView.reloadData()
    }
}
