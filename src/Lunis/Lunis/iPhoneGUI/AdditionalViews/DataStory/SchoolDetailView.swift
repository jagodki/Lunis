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
    var tableData: [SchoolDetailGroup] = []
    
    // MARK: - Outlets
    @IBOutlet var buttonFavorite: UIBarButtonItem!
    
    //the current school object
    var school: School!
    
    //the data controller to edit values of the school object
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init the data controller
        self.dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
        
        //replace the title of the view with the school name
        self.navigationItem.title = self.school.schoolName
        
        //edit the appearence of the button
        self.updateFavoriteButton()
        
        //init the table data array
        let rowName = SchoolDetailRow(title: NSLocalizedString("NAME", comment: ""), value: self.school.schoolName!)
        let rowStreet = SchoolDetailRow(title: NSLocalizedString("STREET", comment: ""), value: self.school.street! + " " + self.school.number!)
        let rowCity = SchoolDetailRow(title: NSLocalizedString("CITY", comment: ""), value: self.school.postalCode! + " - " + self.school.city!)
        let groupAdress = SchoolDetailGroup(title: NSLocalizedString("ADRESS", comment: ""), rows: [rowName, rowStreet, rowCity])
        
        let rowType = SchoolDetailRow(title: NSLocalizedString("TYPE", comment: ""), value: self.school.schoolType!)
        let rowProfile = SchoolDetailRow(title: NSLocalizedString("PROFILE", comment: ""), value: self.school.schoolSpecialisation!)
        let groupSchoolType = SchoolDetailGroup(title: NSLocalizedString("SCHOOL TYPE", comment: ""), rows: [rowType, rowProfile])
        
        let rowPhone = SchoolDetailRow(title: NSLocalizedString("PHONE", comment: ""), value: self.school.phone!)
        let rowMail = SchoolDetailRow(title: NSLocalizedString("MAIL", comment: ""), value: self.school.mail!)
        let rowHomepage = SchoolDetailRow(title: NSLocalizedString("HOMEPAGE", comment: ""), value: self.school.website!)
        let groupContact = SchoolDetailGroup(title: NSLocalizedString("CONTACT", comment: ""), rows: [rowPhone, rowMail, rowHomepage])
        
        let rowWiki = SchoolDetailRow(title: NSLocalizedString("WIKIPEDIA", comment: ""), value: self.school.wikipedia!)
        let rowAgency = SchoolDetailRow(title: NSLocalizedString("AGENCY", comment: ""), value: self.school.agency!)
        let groupOther = SchoolDetailGroup(title: NSLocalizedString("OTHER", comment: ""), rows: [rowWiki, rowAgency])
        
        let rowReachability = SchoolDetailRow(title: NSLocalizedString("REACHABILITY", comment: ""), value: NSLocalizedString("SHOW REACHABILITY OF THIS SCHOOL", comment: ""))
        let groupReachability = SchoolDetailGroup(title: NSLocalizedString("REACHABILITY", comment: ""), rows: [rowReachability])
        
        self.tableData = [groupAdress, groupSchoolType, groupContact, groupOther, groupReachability]
        self.tableView.sizeToFit()
        self.tableView.rowHeight = UITableView.automaticDimension 
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = self.school.schoolName
    }
    
    // MARK: - methods
    
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
        //check, which kind of cell prototype should be used
        guard self.tableData[indexPath.section].title != NSLocalizedString("REACHABILITY", comment: "") else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "schoolReachabilityCell", for: indexPath)
            cell.textLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].value
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolDetailCell", for: indexPath)
        
        cell.textLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].title
        cell.detailTextLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].value
        
        //change the height of the detail text
        if indexPath.section == 1 && indexPath.row == 1 {
            cell.detailTextLabel?.numberOfLines = 0
        }
        
        //change the colour of the text label
        //cell.textLabel?.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        //change the colour of the strings for the contact section to indicate an action
        if indexPath.section == 2 || (indexPath.section == 3 && indexPath.row == 0) {
            cell.detailTextLabel?.textColor = #colorLiteral(red: 1, green: 0.3647058824, blue: 0, alpha: 1)
            cell.detailTextLabel?.lineBreakMode = .byTruncatingTail
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard self.tableData[section].title != NSLocalizedString("REACHABILITY", comment: "") else {
            return ""
        }
        return self.tableData[section].title
    }
    
    /// This function sets the favorite attribute of the current school to true or false.
    ///
    /// - Parameter sender: any
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        //edit the data of the school object and save it in core data
        self.school.favorite = !self.school.favorite
        self.dataController.saveData()
        
        //edit the appearence of the button
        self.updateFavoriteButton()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType: String = self.tableData[indexPath.section].rows[indexPath.row].title
        
        //show a message dialog to ask the user, whether the phone number should be called or not
        switch cellType {
            case NSLocalizedString("PHONE", comment: ""):
                let cleanedUpNumber = self.tableData[indexPath.section].rows[indexPath.row].value.unicodeScalars.filter({CharacterSet.decimalDigits.contains($0)})
                UIApplication.shared.open(URL(string: "telprompt://" + String(cleanedUpNumber))!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            
            case NSLocalizedString("MAIL", comment: ""):
                let cleanedUpMail = self.tableData[indexPath.section].rows[indexPath.row].value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                UIApplication.shared.open(URL(string: "mailto://" + cleanedUpMail!)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            
            case NSLocalizedString("HOMEPAGE", comment: ""):
                let cleanedUpHomepage = self.tableData[indexPath.section].rows[indexPath.row].value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                UIApplication.shared.open(URL(string: cleanedUpHomepage!)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            
            case NSLocalizedString("WIKIPEDIA", comment: ""):
                let cleanedUpWikipedia = self.tableData[indexPath.section].rows[indexPath.row].value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                UIApplication.shared.open(URL(string: cleanedUpWikipedia!)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            
        //case "Reachability":
            //performSegue(withIdentifier: "", sender: self)
            
            default:
                _ = true
        }
        
        //deselect the row
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    private func updateFavoriteButton() {
        if self.school.favorite {
            self.buttonFavorite.image = #imageLiteral(resourceName: "star")
        } else {
            self.buttonFavorite.image = #imageLiteral(resourceName: "unstar")
        }
    }
    
    // MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showReachability":
            let viewController = segue.destination as! ReachabilityViewController
            viewController.school = self.school            
        default:
            _ = true
        }
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
