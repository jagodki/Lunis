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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.administration.city
        
        //init the table data
        let rowCity = DownloadDetailRow(title: "City", value: self.administration.city!)
        let rowRegion = DownloadDetailRow(title: "Region", value: self.administration.region!)
        let rowCountry = DownloadDetailRow(title: "Country", value: self.administration.country!)
        let rowCount = DownloadDetailRow(title: "Schools", value: String(self.administration.schools.count))
        let rowSize = DownloadDetailRow(title: "Size", value: "xx MB")
        let group = DownloadDetailRow(title: "", rows: [rowCity, rowRegion, rowCountry, rowCount, rowSize])
        
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
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadDetailCell", for: indexPath)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
