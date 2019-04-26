//
//  DownloadViewController.swift
//  Lunis
//
//  Created by Christoph on 02.06.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit
import MapKit
import CloudKit
import CoreLocation


class DownloadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableData: [CloudKitAdministrationSection] = []
    
    // MARK: - Outlets
    @IBOutlet var segmentedControlContainer: UISegmentedControl!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    //store the filtered datasets
    var searchedDatasets: [CloudKitAdministrationRow] = [CloudKitAdministrationRow]()
    
    //a tableviewontroller to store the search results
    var resultsController: UITableViewController!
    
    //a variable to the selected administration
    var selectedAdministration: Administration!
    
    //the controller for connecting to CloudKit
    var ckController: CloudKitController!
    
    //a controller to handle asynchronious actions
    var refreshControl: UIRefreshControl!
    
    //an acitivity indicator, that should be shown during fetching data from CloudKit
    var alert: UIAlertController!
    
    // MARK: - instance functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up a searchresultcontroller
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchedDatasetCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        
        //add a search bar to the navigation bar
        self.adjustSearchBar(showSearchBar: true)
        
        //init GUI-elements
        self.segmentedControlContainer.selectedSegmentIndex = 0
        self.tableView.alpha = 1
        self.mapView.alpha = 0
        
        //set up the map view
        self.mapView.delegate = self
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        
        //init the alert controller to show an activity indicator while fetching data from CloudKit
        self.alert = UIAlertController(title: "Fetching data", message: "please wait...", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: self.alert.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        indicator.style = .gray
        self.alert.view.addSubview(indicator)
        
        //init the CloudKit controller
        self.ckController = (UIApplication.shared.delegate as! AppDelegate).cloudKitController
        self.ckController.delegate = self
        
        // Set up a refresh control
        self.refreshControl = UIRefreshControl()
        
        //get all administrations from CloudKit and show an activity indicator
        self.fetchData()
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        self.fetchData()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// This function fetches all administrations from CloudKit and presents an activity indicator.
    func fetchData() {
        self.present(self.alert, animated: true, completion: nil)
        self.ckController.queryAllAdministrations(sortBy: "country", ascending: true)
    }
    
    func adjustSearchBar(showSearchBar: Bool) {
        if showSearchBar {
            let searchController = UISearchController(searchResultsController: self.resultsController)
            searchController.searchResultsUpdater = self as UISearchResultsUpdating
            searchController.obscuresBackgroundDuringPresentation = true
            searchController.searchBar.placeholder = "Search Cities"
            super.navigationItem.searchController = searchController
            super.navigationItem.hidesSearchBarWhenScrolling = true
            definesPresentationContext = true
            self.navigationItem.largeTitleDisplayMode = .automatic
        } else {
            self.navigationItem.searchController = nil
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.alpha = 1
                self.mapView.alpha = 0
                self.adjustSearchBar(showSearchBar: true)
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.alpha = 0
                self.mapView.alpha = 1
                self.adjustSearchBar(showSearchBar: false)
            })
        }
    }
    
    // MARK: - TableView implementation
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.tableData[section].rows.count
        } else {
            return self.searchedDatasets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String!
        var textLabel: String!
        
        if tableView == self.tableView{
            cellIdentifier = "downloadTableCell"
            textLabel = self.tableData[indexPath.section].rows[indexPath.row].city
        } else {
            cellIdentifier = "searchedDatasetCell"
            textLabel = self.searchedDatasets[indexPath.row].city
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = textLabel
        
        //add subtitle
        if cellIdentifier == "downloadTableCell" {
            cell.detailTextLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].region
        }
        
        //mark datasets, that are already downloaded
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView {
            return self.tableData[section].country
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //download the selected dataset
        
        //deselect the current row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return self.tableData.count
        } else {
            return 1
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDownloadDetail":
            let viewController = segue.destination as! DownloadDetailController
            viewController.administration = self.selectedAdministration
            
            
        default:
            _ = true
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension DownloadViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //get the search text
        let searchText: String = searchController.searchBar.text!
        
        //get the rows of all sections
        var allDatasets: [CloudKitAdministrationRow] = [CloudKitAdministrationRow]()
        for section in self.tableData {
            allDatasets.append(contentsOf: section.rows)
        }
        
        //filter all school rows
        self.searchedDatasets = allDatasets.filter({(row : CloudKitAdministrationRow) -> Bool in
            return row.city.lowercased().contains(searchText.lowercased())
        })
        
        //reload the table
        self.resultsController.tableView.reloadData()
    }
}

// MARK: - ModelDelegate
extension DownloadViewController: CloudKitDelegate {
    
    func modelUpdated() {
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
        for section in self.tableData {
            self.mapView.addAnnotations(section.rows.map({(value: CloudKitAdministrationRow) -> MKPointAnnotation in
                let annotation = MKPointAnnotation()
                annotation.coordinate = value.centroid
                annotation.title = value.city
                annotation.subtitle = value.region
                return annotation
            }))
        }
        self.alert.dismiss(animated: true, completion: nil)
    }
    
    func errorUpdating(_ error: NSError) {
        let message: String
        if error.code == 1 {
            message = "Log into iCloud on your device."
        } else {
            message = error.localizedDescription
        }
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateTableData(with data: [CloudKitAdministrationSection]) {
        self.tableData = data
    }
    
}

// MARK: - MKMapViewDelegate
extension DownloadViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView!.animatesDrop = false
            pinView!.pinTintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "showDownloadDetail", sender: self)
        }
    }
}

