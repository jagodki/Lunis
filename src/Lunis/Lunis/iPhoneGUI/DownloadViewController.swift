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
    
    //store the filtered datasets
    var searchedDatasets: [DownloadRow] = [DownloadRow]()
    
    //a tableviewontroller to store the search results
    var resultsController: UITableViewController!
    
    // MARK: - instance functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up a searchresultcontroller
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchedDatasetCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        
        //add a search bar to the navigation bar
        let searchController = UISearchController(searchResultsController: self.resultsController)
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Cities"
        super.navigationItem.searchController = searchController
        super.navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        //init GUI-elements
        self.segmentedControlContainer.selectedSegmentIndex = 0
        self.tableView.alpha = 1
        self.mapView.alpha = 0
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adjustSearchBar(showSearchBar: Bool) {
        
    }
    
    // MARK: - IBActions
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.alpha = 1
                self.mapView.alpha = 0
                self.navigationItem.searchController?.searchBar.isHidden  = false
                self.navigationItem.largeTitleDisplayMode = .automatic
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.alpha = 0
                self.mapView.alpha = 1
                self.navigationItem.searchController?.searchBar.isHidden = true
                self.navigationItem.largeTitleDisplayMode = .never
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
            textLabel = self.tableData[indexPath.section].rows[indexPath.row].name
        } else {
            cellIdentifier = "searchedDatasetCell"
            textLabel = self.searchedDatasets[indexPath.row].name
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = textLabel
        
        //mark datasets, that are already downloaded
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView {
            return self.tableData[section].title
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
}

// MARK: - UISearchResultsUpdating Delegate
extension DownloadViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //get the search text
        let searchText: String = searchController.searchBar.text!
        
        //get the rows of all sections
        var allDatasets: [DownloadRow] = [DownloadRow]()
        for section in self.tableData {
            allDatasets.append(contentsOf: section.rows)
        }
        
        //filter all school rows
        self.searchedDatasets = allDatasets.filter({(downloadRow : DownloadRow) -> Bool in
            return downloadRow.name.lowercased().contains(searchText.lowercased())
        })
        
        //reload the table
        self.resultsController.tableView.reloadData()
    }
}

