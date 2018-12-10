//
//  DownloadViewController.swift
//  Lunis
//
//  Created by Christoph on 02.06.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit
import MapKit

struct DownloadSection {
    var title: String
    var rows: [DownloadRow]
}

struct DownloadRow {
    var name: String
}

class DownloadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table Data
    var tableData = [
        DownloadSection(title: "Sverige", rows: [
            DownloadRow(name: "Stockholm"),
            DownloadRow(name: "Malmö")
        ]),
        DownloadSection(title: "Polska", rows: [
            DownloadRow(name: "Warszawa")
        ]),
        DownloadSection(title: "Deutschland", rows: [
            DownloadRow(name: "Radebeul"),
            DownloadRow(name: "Meißen")
        ])
    ]
    
    // MARK: - Outlets
    @IBOutlet var segmentedControlContainer: UISegmentedControl!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add a search bar to the navigation bar
        let searchController = UISearchController(searchResultsController: nil)
        super.navigationItem.searchController = searchController
        super.navigationItem.hidesSearchBarWhenScrolling = true
        
        self.segmentedControlContainer.selectedSegmentIndex = 0
        self.tableView.alpha = 1
        self.mapView.alpha = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.alpha = 1
                self.mapView.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.alpha = 0
                self.mapView.alpha = 1
                //self.navigationItem.searchController.is
            })
        }
    }
    
    // MARK: - TableView implementation
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadTableCell", for: indexPath)
        cell.textLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].name
        
        //mark datasets, that are already downloaded
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //download the selected dataset
        
        //deselect the current row
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.count
    }
    
}

