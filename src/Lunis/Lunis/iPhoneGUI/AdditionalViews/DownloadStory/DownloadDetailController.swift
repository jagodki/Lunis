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
    var administration: CloudKitAdministrationRow!
    var country: String!
    var coreDataController: DataController!
    var tableData: [DownloadDetailRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.administration.city
        
        //init the table data
        let rowCity = DownloadDetailRow(title: "City", value: self.administration.city)
        let rowRegion = DownloadDetailRow(title: "Region", value: self.administration.region)
        let rowCountry = DownloadDetailRow(title: "Country", value: self.country)
        let rowCount = DownloadDetailRow(title: "Schools", value: String(self.administration.countOfSchools))
        let rowSource = DownloadDetailRow(title: "Source", value: self.administration.source)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let rowLastUpdate = DownloadDetailRow(title: "Last Update", value: dateFormatter.string(from: self.administration.lastUpdate))
        self.tableData = [rowCity, rowRegion, rowCountry, rowSource, rowCount, rowLastUpdate]
        
        //edit the right barbutton
        if self.datasetIsAlreadyOnDevice() {
            self.buttonSaveDelete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteData(sender:)))
        } else {
            self.buttonSaveDelete = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveData(sender:)))
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadDetailCell", for: indexPath)
        cell.textLabel?.text = self.tableData[indexPath.row].title
        cell.detailTextLabel?.text = self.tableData[indexPath.row].value

        return cell
    }
    
    // MARK: - additional functions
    private func datasetIsAlreadyOnDevice() -> Bool {
        let admins = self.coreDataController.fetchAdministations()
        for admin in admins {
            let compareCity = (admin.city == self.administration.city)
            let compareRegion = (admin.region == self.administration.region)
            let compareCountry = (admin.country == self.country)
            
            if compareCity && compareRegion && compareCountry {
                return true
            }
        }
        return false
    }
    
    @objc private func saveData(sender: UIBarButtonItem) {
        
    }
    
    @objc private func deleteData(sender: UIBarButtonItem) {
        
    }
    
    

}
