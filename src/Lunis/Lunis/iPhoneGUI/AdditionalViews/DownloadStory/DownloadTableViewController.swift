//
//  DownloadTableViewController.swift
//  Lunis
//
//  Created by Christoph on 28.11.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit
import CoreData

struct DownloadSection {
    var title: String
    var rows: [DownloadRow]
}

struct DownloadRow {
    var name: String
}

class DownloadTableViewController: UITableViewController {
    
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
    
    override func viewDidLoad() {
        //add a search bar to the navigation bar
        let searchController = UISearchController(searchResultsController: nil)
        super.navigationItem.searchController = searchController
        super.navigationItem.hidesSearchBarWhenScrolling = true
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadTableCell", for: indexPath)
        cell.textLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].name
        
        //change the colour to gray, if the dataset is already downloaded
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData[section].title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //download the selected dataset
        
        //deselect the current row
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
