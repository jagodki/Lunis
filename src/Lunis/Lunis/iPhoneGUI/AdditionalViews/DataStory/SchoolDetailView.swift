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
            SchoolDetailRow(title: "Phone", value: "111222333777888999"),
            SchoolDetailRow(title: "Mail", value: "test@example.com"),
            SchoolDetailRow(title: "Homepage", value: "https://www.duckduckgo.com")
            ])
    ]
    
    // MARK: - Outlets
    @IBOutlet var buttonFavorite: UIBarButtonItem!
    
    
    //the name of the current school
    var schoolName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //replace the title of the view with the school name
        //self.navigationController?.navigationBar.titleTextAttributes
        
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
        
        cell.textLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].title
        cell.detailTextLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].value
        
        //change the colour of the strings for the contact section to indicate an action
        if self.tableData[indexPath.section].title == "Contact" {
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData[section].title
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType: String = self.tableData[indexPath.section].rows[indexPath.row].title
        var openStringWithSharedApplication: Bool = false
        
        //show a message dialog to ask the user, whether the phone number should be called or not
        switch cellType {
        case "Phone":
            let alert = UIAlertController(title: "Info", message: "Do you want to call the phone number of this school?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
                (alert: UIAlertAction!) in
                openStringWithSharedApplication = true
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        default:
            openStringWithSharedApplication = true
        }
        
        //open with shared application (depending on the previous step)
        if openStringWithSharedApplication {
            UIApplication.shared.open(URL(string: self.tableData[indexPath.section].rows[indexPath.row].value)!, options: [:], completionHandler: nil)
        }
        
        //deselect the row
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
