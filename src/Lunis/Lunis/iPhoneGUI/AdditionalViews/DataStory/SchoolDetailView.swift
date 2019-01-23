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

/// This class is the controller for the detail view of every schools.
class SchoolDetailView: UITableViewController {
    
    //the data of the tabel, will be edited in the constructor via delegation
    var tableData: [SchoolDetailGroup] = [
//        SchoolDetailGroup(title: "Adress", rows: [
//            SchoolDetailRow(title: "Name", value: ""),
//            SchoolDetailRow(title: "Street", value: ""),
//            SchoolDetailRow(title: "City", value: "")
//        ]),
//        SchoolDetailGroup(title: "School Type", rows: [
//            SchoolDetailRow(title: "Type", value: ""),
//            SchoolDetailRow(title: "Profile", value: "")
//            ]),
//        SchoolDetailGroup(title: "Contact", rows: [
//            SchoolDetailRow(title: "Phone", value: "111222333777888999"),
//            SchoolDetailRow(title: "Mail", value: "test@example.com"),
//            SchoolDetailRow(title: "Homepage", value: "www.duckduckgo.com")
//            ])
    ]
    
    // MARK: - Outlets
    @IBOutlet var buttonFavorite: UIBarButtonItem!
    
    //the name of the current school
    var school: SchoolMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //replace the title of the view with the school name
        self.navigationItem.title = self.school.name
        
        //init the table data array
        let rowName = SchoolDetailRow(title: "Name", value: self.school.name)
        let rowStreet = SchoolDetailRow(title: "Street", value: self.school.street + " " + self.school.number)
        let rowCity = SchoolDetailRow(title: "City", value: self.school.postalCode + " - " + self.school.city)
        let groupAdress = SchoolDetailGroup(title: "Adress", rows: [rowName, rowStreet, rowCity])
        
        let rowType = SchoolDetailRow(title: "Type", value: self.school.schoolType)
        let rowProfile = SchoolDetailRow(title: "Profile", value: self.school.schoolSpecialisation)
        let groupSchoolType = SchoolDetailGroup(title: "School Type", rows: [rowType, rowProfile])
        
        let rowPhone = SchoolDetailRow(title: "Phone", value: self.school.phone)
        let rowMail = SchoolDetailRow(title: "Mail", value: self.school.mail)
        let rowHomepage = SchoolDetailRow(title: "Homepage", value: self.school.website)
        let groupContact = SchoolDetailGroup(title: "Adress", rows: [rowPhone, rowMail, rowHomepage])
        
        let rowWiki = SchoolDetailRow(title: "Wikipedia", value: self.school.wikipedia)
        let groupOther = SchoolDetailGroup(title: "Other", rows: [rowWiki])
        
        self.tableData = [groupAdress, groupSchoolType, groupContact, groupOther]
    }
    
    // MARK: - methods
    
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
        
        //change the colour of the text label
        cell.textLabel?.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        //change the colour of the strings for the contact section to indicate an action
        if (self.tableData[indexPath.section].title == "Contact") || (self.tableData[indexPath.section].rows[indexPath.row].title == "Wikipedia") {
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData[section].title
    }
    
    /// This function sets the favorite attribute of the current school to true or false.
    ///
    /// - Parameter sender: any
    @IBAction func favoriteButtonPressed(_ sender: Any) {
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType: String = self.tableData[indexPath.section].rows[indexPath.row].title
        
        //show a message dialog to ask the user, whether the phone number should be called or not
        switch cellType {
            case "Phone":
                UIApplication.shared.open(URL(string: "telprompt://" + self.tableData[indexPath.section].rows[indexPath.row].value)!, options: [:], completionHandler: nil)
            
            case "Mail":
                UIApplication.shared.open(URL(string: "mailto://" + self.tableData[indexPath.section].rows[indexPath.row].value)!, options: [:], completionHandler: nil)
            
            case "Homepage":
                UIApplication.shared.open(URL(string: "https://" + self.tableData[indexPath.section].rows[indexPath.row].value)!, options: [:], completionHandler: nil)
            
            default:
                _ = true
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
