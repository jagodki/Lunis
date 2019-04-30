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
        
        if self.tableData[indexPath.row].title.lowercased() == "source" {
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType: String = self.tableData[indexPath.row].title.lowercased()
        
        //show a message dialog to ask the user, whether the phone number should be called or not
        switch cellType {
        case "source":
            UIApplication.shared.open(URL(string: self.tableData[indexPath.row].value)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            
        default:
            _ = true
        }
        
        //deselect the row
        self.tableView.deselectRow(at: indexPath, animated: true)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
