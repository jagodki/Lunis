//
//  SchoolDetailView.swift
//  Lunis
//
//  Created by Christoph on 19.11.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit

struct SchoolDetailGroup {
    var title: String
    var rows: [SchoolDetailRow]
}

struct SchoolDetailRow {
    var title: String
    var value: String
}

class SchoolDetailView: UITableViewController {
    
    //the data of the tabel, will be edited in the constructor via delegation
    var tableData = [
        SchoolDetailGroup(title: "Adress", rows: [
            SchoolDetailRow(title: "Street", value: ""),
            SchoolDetailRow(title: "City", value: "")
        ]),
        SchoolDetailGroup(title: "School Type", rows: [
            SchoolDetailRow(title: "Type", value: ""),
            SchoolDetailRow(title: "Profile", value: "")
            ]),
        SchoolDetailGroup(title: "Contact", rows: [
            SchoolDetailRow(title: "Phone", value: ""),
            SchoolDetailRow(title: "Mail", value: ""),
            SchoolDetailRow(title: "Homepage", value: "")
            ])
    ]
    
    // MARK: - Outlets
    @IBOutlet var buttonFavorite: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //replace the title of the view with the school name
        
        
        //edit the table data
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.tableData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tableData[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolDetailCell", for: indexPath)
        
        cell.detailTextLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].title
        cell.textLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].value
        
        //make the values clickable for the contact section
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData[section].title
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
