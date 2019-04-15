//
//  DownloadDetailController.swift
//  Lunis
//
//  Created by Christoph on 29.03.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

struct DownloadDetailGroup {
    var title: String
    var rows: [DownloadDetailRow]
}

struct DownloadDetailRow {
    var title: String
    var value: String
}

class DownloadDetailController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var buttonSaveDelete: UIBarButtonItem!
    
    // MARK: - instance variables
    var administration: Administration!
    var tableData: [DownloadDetailRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.administration.city
        
        //init the table data
        let rowCity = DownloadDetailRow(title: "City", value: self.administration.city!)
        let rowRegion = DownloadDetailRow(title: "Region", value: self.administration.region!)
        let rowCountry = DownloadDetailRow(title: "Country", value: self.administration.country!)
        let rowCount = DownloadDetailRow(title: "Schools", value: String(self.administration.schools!.count))
        let rowSize = DownloadDetailRow(title: "Size", value: "xx MB")
        self.tableData = [rowCity, rowRegion, rowCountry, rowCount, rowSize]
        
        //edit the right barbutton
        if self.datasetIsAlreadyOnDevice() {
            self.buttonSaveDelete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteData(sender:)))
        } else {
            self.buttonSaveDelete = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveData(sender:)))
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = self.administration.city
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tableData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadDetailCell", for: indexPath)
        cell.textLabel?.text = self.tableData[indexPath.row].title
        cell.detailTextLabel?.text = self.tableData[indexPath.row].value

        return cell
    }
    
    private func datasetIsAlreadyOnDevice() -> Bool {
        return true
    }
    
    @objc private func saveData(sender: UIBarButtonItem) {
        
    }
    
    @objc private func deleteData(sender: UIBarButtonItem) {
        
    }
    
    

}
