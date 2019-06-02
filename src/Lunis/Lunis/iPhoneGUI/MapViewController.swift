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
    @IBOutlet var buttonHexagons: UIBarButtonItem!
    
    // MARK: - instance variables
    var locationManager: CLLocationManager!
    var postionIsShown: Bool!
    var zoomToPosition: Bool!
    var mapContent: Int!
    var searchController: UISearchController!
    
    //the data controller for connecting to core data
    var dataController: DataController!
    var fetchedResultsControllerSchools: NSFetchedResultsController<School>!
    var fetchedResultsControllerAdministrations: NSFetchedResultsController<Administration>!
    
    //a tableviewontroller to store the search results
    var searchResultsController: UITableViewController!
    
    //store the searched schools
    var searchedSchools: [School] = [School]()
    
    //store information about the hexagonal raster
    var minCellValue: Double! = 99999999999999999999.9
    var polygonColour: UIColor!
    var showHexagonalRaster: Bool! = false
    
    // MARK: - methods
    
    /// Constructor of this class.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "update") && UserDefaults.standard.bool(forKey: "initialView") {
            LoadingIndicator.show(loadingText: "searching for updates", colour: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), alpha: 1)
        }
        
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
        
        //set up the map view
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
        //self.reloadMapContent()
        self.addCoreDataObjectsToTheMap(request: "", zoomToObjects: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //fetch data from core data and add them to the map
        self.reloadMapContent(removeOverlays: false, zoomToObjects: false)
        //self.addCoreDataObjectsToTheMap(request: "", zoomToObjects: false)
        
        //add the hexagonal raster if necessary
        if self.showHexagonalRaster {
            self.showHideHexagons()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView implementation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.dismiss(animated: true, completion: nil)
        self.zoomToSchool(schoolName: self.searchedSchools[indexPath.row].schoolName!, city: self.searchedSchools[indexPath.row].city!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchedSchoolsCell", for: indexPath)
        cell.textLabel?.text = self.searchedSchools[indexPath.row].schoolName
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedSchools.count
    }
    
    // MARK: - additional methods
    /// This function fetches objects from core data and add them to the map view of this class
    ///
    /// - Parameter request: a String representing the request for fetching data
    /// - Parameter zoomToObjects: an indicator whether the map view should be zoomed to the loaded map objects
    private func addCoreDataObjectsToTheMap(request: String, zoomToObjects: Bool) {
        //fetch data from core data
        self.fetchedResultsControllerSchools = self.dataController.fetchSchools(request: request, groupedBy: "", orderedBy: ["schoolType", "schoolName"], orderedAscending: true)
        self.updateMarkerTintColours()
        
        //add the fetched data to the map and zoom to it
        self.mapView.addAnnotations(self.fetchedResultsControllerSchools.fetchedObjects!)
        if zoomToObjects {
            self.mapView.showAnnotations(self.fetchedResultsControllerSchools.fetchedObjects!, animated: true)
        }
    }
    
    /// This function fetches objects from core data and add them to the map view of this class
    ///
    /// - Parameter zoomToObjects: an indicator whether the map view should be zoomed to the loaded map objects
    private func addFilteredCoreDataObjectsToTheMap(zoomToObjects: Bool) {
        //fetch data from core data
        self.fetchedResultsControllerSchools = self.dataController.fetchSchools(filter: true, groupedBy: "", orderedBy: ["schoolType", "schoolName"], orderedAscending: true)
        self.updateMarkerTintColours()
        
        //add the fetched data to the map and zoom to it
        self.mapView.addAnnotations(self.fetchedResultsControllerSchools.fetchedObjects!)
        if zoomToObjects {
            self.mapView.showAnnotations(self.fetchedResultsControllerSchools.fetchedObjects!, animated: true)
        }
    }
    
    /// This function adjusts the variables index and maxIndex of all fetched schools to update their marker tint colors.
    private func updateMarkerTintColours() {
        let countOfFetchedSchools = (self.fetchedResultsControllerSchools.fetchedObjects?.count)!
        if countOfFetchedSchools != 0 {
            for index in 0...(countOfFetchedSchools - 1) {
                self.fetchedResultsControllerSchools.object(at: IndexPath(row: index, section: 0)).index = index
                self.fetchedResultsControllerSchools.object(at: IndexPath(row: index, section: 0)).maxIndex = countOfFetchedSchools
            }
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
                let span:MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let currentPosition:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                let region = MKCoordinateRegion.init(center: currentPosition, span: span)
                self.mapView.setRegion(region, animated: true)
            }
            self.zoomToPosition = false
        }
    }
    
    /// This function show an alert, whether location services are disabled for this app.
    func showEnableLocationAlert() {
        let alert = UIAlertController(title: "Info", message: "Location Services are not enabled. Your location cannot be shown in the map.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: UIAlertAction.Style.default, handler: {
            (alert: UIAlertAction!) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// This function zooms to a school, identified by its name and city.
    ///
    /// - Parameters:
    ///   - schoolName: the name of the school
    ///   - city: the city of the school
    func zoomToSchool(schoolName: String, city: String) {
        let annotationToFocusOn = self.fetchedResultsControllerSchools.fetchedObjects?.filter({
            (fetchedSchool: School) -> Bool in
            return schoolName == fetchedSchool.schoolName && city == fetchedSchool.city
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
            self.reloadMapContent(removeOverlays: true, zoomToObjects: true)
        })
        
        let favoritesAction = UIAlertAction(title: "Favourite schools", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapContent = 1
            self.reloadMapContent(removeOverlays: true, zoomToObjects: true)
        })
        
        let filteredAction = UIAlertAction(title: "Filtered schools", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.mapContent = 2
            self.reloadMapContent(removeOverlays: true, zoomToObjects: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
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
    
    /// This function reloads the map content depending of the layer settings.
    ///
    /// - Parameter removeOverlays: a boolean whether possible overlays should be removed or not
    /// - Parameter zoomToObjects: a boolean whether the map should be zoomed to the loaded objects
    func reloadMapContent(removeOverlays: Bool, zoomToObjects: Bool) {
        //remove the current map content
        self.mapView.removeAnnotations(self.fetchedResultsControllerSchools.fetchedObjects!)
        if removeOverlays {
            self.mapView.removeOverlays(self.mapView.overlays)
            self.setHexagonalButton(to: false)
        }
        //self.mapView.removeAnnotations(self.fetchedResultsControllerAdministrations.fetchedObjects as! [MKAnnotation])
        
        switch self.mapContent {
        case 0:
            //all schools
            self.addCoreDataObjectsToTheMap(request: "", zoomToObjects: zoomToObjects)
        case 1:
            //favourite schools
            self.addCoreDataObjectsToTheMap(request: "favorite=true", zoomToObjects: zoomToObjects)
        case 2:
            //filtered schools
            self.addFilteredCoreDataObjectsToTheMap(zoomToObjects: zoomToObjects)
        default:
            return
        }
    }
    
    @IBAction func buttonHexagonsTapped(_ sender: Any) {
        self.showHexagonalRaster = !self.showHexagonalRaster
        self.showHideHexagons()
    }
    
    /// This function shows or hides the hexagonal raster of the reachebilities.
    private func showHideHexagons() {
        if self.showHexagonalRaster {
            //remove existing overlays
            self.mapView.removeOverlays(self.mapView.overlays)
            
            //adjust the button and the instance var
            if self.fetchedResultsControllerSchools!.fetchedObjects!.count == 0 {
                self.setHexagonalButton(to: false)
            } else {
                self.setHexagonalButton(to: true)
            }
            
            
            //get all visible administrations plus the names and colours of the visible schools
            var administrations: [Administration] = []
            for school in self.fetchedResultsControllerSchools!.fetchedObjects! {
                administrations.append(school.administration!)
            }
            administrations = Array(Set(administrations))
            
            //zoom to the visible administrations
//            self.mapView.setVisibleMapRect((self.school.administration?.polygon.boundingMapRect)!, animated: true)
            
            //iterate over all the administrations
            for administration in administrations {
                
                //add the administration to the map
                self.mapView.addOverlay(administration.polygon)
                
                //get all visible schools of the current administration
                var schoolNamesAndColours: [Int64: UIColor] = [:]
                for school in self.fetchedResultsControllerSchools!.fetchedObjects! {
                    if school.administration == administration {
                        schoolNamesAndColours.updateValue(school.markerTintColor, forKey: school.localID)
                    }
                }
                
                //iterate over all cells
                if administration.grid != nil && administration.grid!.cells != nil {
                    let cells = administration.grid!.cells!.array as! [Cell]
                    for cell in cells {
                        
                        //compare the cellValues
                        let cellValues = cell.cellValues?.allObjects as! [CellValue]
                        for cellValue in cellValues {
                            
                            guard let schoolColour = schoolNamesAndColours[cellValue.localSchoolID] else {
                                continue
                            }
                            
                            if (cellValue.value?.doubleValue)! < (self.minCellValue)! {
                                self.minCellValue = (cellValue.value?.doubleValue)!
                                self.polygonColour = schoolColour.withAlphaComponent(0.35)
                            } else if (cellValue.value?.doubleValue)! == (self.minCellValue)! {
                                self.polygonColour = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
                            }
                        }
                        
                        //add the polygon of the cell to the map
                        self.mapView.addOverlay(cell.polygon)
                        self.minCellValue = 99999999999999999999.9
                    }
                }
            }
            
        } else {
            //adjust the button, the instance var and the map content
            self.setHexagonalButton(to: false)
            self.mapView.removeOverlays(self.mapView.overlays)
        }
    }
    
    /// This function adjusts the appearence of the hexagonal button and the corresponding instance variable.
    ///
    /// - Parameter value: a boolean whether the raster is enabled or not.
    private func setHexagonalButton(to value: Bool) {
        self.showHexagonalRaster = value
        if value {
            self.buttonHexagons.title = "noHex"
        } else {
            self.buttonHexagons.title = "Hexa"
        }
    }
    
    
    // MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "showSchoolDetailFromMap":
                let viewController = segue.destination as! SchoolDetailView
                viewController.school = self.mapView.selectedAnnotations[0] as? School
            
            case "showShortestDistances":
                let viewController = segue.destination as! SchoolDistancesController
                viewController.start = self.locationManager.location?.coordinate
                viewController.destinations = self.fetchedResultsControllerSchools.fetchedObjects
            
            default:
                _ = true
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is School {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "schoolMarker", for: annotation) as? SchoolMarkerView {
                return annotationView
            } else {
                return nil
            }
        } else if annotation is MKUserLocation {
            return nil
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view is SchoolMarkerView {
            performSegue(withIdentifier: "showSchoolDetailFromMap", sender: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            switch overlay.title {
            case "Administration":
                renderer.fillColor = UIColor.black.withAlphaComponent(0)
                renderer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.85)
                renderer.lineWidth = 2
            case "Cell":
                renderer.fillColor = self.polygonColour
                renderer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.75)
                renderer.lineWidth = 1
            case .none:
                renderer.fillColor = UIColor.black.withAlphaComponent(0)
            case .some(_):
                renderer.fillColor = UIColor.black.withAlphaComponent(0)
            }
            
            return renderer
        }
        
        return MKOverlayRenderer()
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension MapViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //get the search text
        let searchText: String = searchController.searchBar.text!
        
        //get the rows of all sections
        let allSchoolRows: [School] = self.fetchedResultsControllerSchools.fetchedObjects!
        
        //filter all school rows
        self.searchedSchools = allSchoolRows.filter({(dataViewSchoolCell : School) -> Bool in
            return dataViewSchoolCell.schoolName!.lowercased().contains(searchText.lowercased())
        })
        
        //reload the table
        self.searchResultsController.tableView.reloadData()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
