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
    
    // MARK: - instance variables
    var administration: CloudKitAdministrationRow!
    var country: String!
    var coreDataController: DataController!
    var cloudKitController: CloudKitController!
    var tableData: [DownloadDetailRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.administration.city
        
        self.cloudKitController.downloadDelegate = self
        
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
            let buttonDelete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteData(sender:)))
            self.navigationItem.rightBarButtonItem = buttonDelete
        } else {
            let buttonSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveData(sender:)))
            self.navigationItem.rightBarButtonItem = buttonSave
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
    
    /// This function checks, if the administration from CloudKit, which is a instance variable of this class, is already downloaded on the device.
    ///
    /// - Returns: true if the administration is already on the device in CoreData, otherwise false
    private func datasetIsAlreadyOnDevice() -> Bool {
        let admins = self.coreDataController.fetchAdministrations()
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
    
    /// This function saves a dataset (administration, schools, grid) on the device.
    ///
    /// - Parameter sender: a UIBarButtonItem, from which the function will be called
    @objc private func saveData(sender: UIBarButtonItem) {
        LoadingIndicator.show(loadingText: "downloading data, please wait...", colour: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), alpha: 0.4)
        DispatchQueue.global(qos: .background).async {
            self.cloudKitController.fetchFileURLsFor(school: self.administration.schoolReference, grid: self.administration.gridReference)
        }
    }
    
    /// This function removes a dataset from the device.
    ///
    /// - Parameter sender: a UIBarButtonItem, from which the function will be called
    @objc private func deleteData(sender: UIBarButtonItem) {
        LoadingIndicator.show(loadingText: "deleting data, please wait...", colour: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), alpha: 0.4)
        
        //get the administation from core data
        DispatchQueue.global(qos: .background).async {
            let request = "country=" + self.country + " AND region=" + self.administration.region + " AND city=" + self.administration.city + " AND x=" + String(self.administration.centroid.longitude) + " AND y=" + String(self.administration.centroid.latitude)
            let coreDataAdministration = self.coreDataController.fetchAdministrations(request: request, groupedBy: "", orderedBy: [], orderedAscending: false).object(at: IndexPath(row: 0, section: 0))
            
            //delete the administation from the device (all other objects, that are connected to this administration, will be deleted cascadetly)
            self.coreDataController.delete(by: coreDataAdministration.objectID)
            
            DispatchQueue.main.async {
                LoadingIndicator.hide()
                self.navigationController?.popViewController(animated: true)

            }
        }
        
    }
    

}

extension DownloadDetailController: DownloadDelegate {
    
    func downloadData(schoolURL: URL, gridURL: URL) {
        self.coreDataController.downloadData(administration: self.administration, schoolFileURL: schoolURL, gridFileURL: gridURL)
        LoadingIndicator.hide()
        self.navigationController?.popViewController(animated: true)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
