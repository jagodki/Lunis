//
//  FilterDataViewController.swift
//  Lunis
//
//  Created by Christoph on 08.11.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit

struct Section {
    var title: String
    var rows: [Row]
}

struct Row {
    var name: String
    var value: String
}

/// The controller for the filter view of the data view.
class FilterDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //table data
    var tableData = [
        Section(title: " ", rows: [
            Row(name: "COUNTRY", value: "All"),
            Row(name: "DISTRICT", value: "All"),
            Row(name: "CITY", value: "All"),
            Row(name: "SCHOOL TYPE", value: "All"),
            Row(name: "AGENCY", value: "All")
//            Row(name: "School Profile", value: "All")
        ])
    ]
    
    // MARK: - instance variables
    
    //array for storing picker data
    var countryData: [String]! = []
    var districtData: [String]! = []
    var cityData: [String]! = []
    var schoolTypeData: [String]! = []
    var agencyData: [String]! = []
//    var schoolProfileData: [String]! = ["All", "künstlerisch", "naturwissenschaftlich"]
    var pickerData: [String]! = ["---"]
    
    //a delegate to send the filter settings to the parent view
    weak var delegate: FilterDataViewDelegate?
    
    //store the index of the current/selected table row
    var currentCell: UITableViewCell!
    
    // MARK: - Outlets
    @IBOutlet var buttonDone: UIBarButtonItem!
    @IBOutlet var buttonCancel: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!
    
    // MARK: - methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adjust the view
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        
        //init the currentCell-var
        self.currentCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        
        //get the current filter settings from the parent view via delegation and adjust the detail labels of the table view
        var filterSettings: [String: String]! = self.delegate?.getCurrentFilterSettings()
        self.tableData[0].rows[0].value = filterSettings["Country"]!
        self.tableData[0].rows[1].value = filterSettings["District"]!
        self.tableData[0].rows[2].value = filterSettings["City"]!
        self.tableData[0].rows[3].value = filterSettings["School Type"]!
        self.tableData[0].rows[4].value = filterSettings["Agency"]!
//        self.tableData[0].rows[4].value = filterSettings["School Profile"]!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - picker view imeplementation
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentCell.detailTextLabel?.text = self.pickerData[row]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - table view implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        
        //set the text content
        cell.textLabel?.text = NSLocalizedString(self.tableData[indexPath.section].rows[indexPath.row].name, comment: "")
        cell.detailTextLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].value
        
        //edit the text colours
        cell.textLabel?.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        cell.detailTextLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString(self.tableData[section].title, comment: "")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //remove the colour from the previous selection
        if self.currentCell != nil {
            self.currentCell.detailTextLabel?.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }

        //get the cell and store them
        let cell = self.tableView.cellForRow(at: indexPath)
        self.currentCell = cell
        
        //adjust the colour of the detail text
        cell?.detailTextLabel?.textColor = #colorLiteral(red: 1, green: 0.3647058824, blue: 0, alpha: 1)
        
        //change the data for the picker
        switch cell?.textLabel?.text {
            case NSLocalizedString("COUNTRY", comment: ""):
                self.pickerData = self.countryData
                self.pickerView.reloadAllComponents()
            case NSLocalizedString("DISTRICT", comment: ""):
                self.pickerData = self.districtData
                self.pickerView.reloadAllComponents()
            case NSLocalizedString("CITY", comment: ""):
                self.pickerData = self.cityData
                self.pickerView.reloadAllComponents()
            case NSLocalizedString("SCHOOL TYPE", comment: ""):
                self.pickerData = self.schoolTypeData
                self.pickerView.reloadAllComponents()
            case NSLocalizedString("AGENCY", comment: ""):
                self.pickerData = self.agencyData
                self.pickerView.reloadAllComponents()
//            case "School Profile":
//                self.pickerData = self.schoolProfileData
//                self.pickerView.reloadAllComponents()
            default:
                print("default")
        }
        
        //change the selected item of the picker view
        let filterValue: String! = cell!.detailTextLabel?.text
        for (index, currentPickerValue) in self.pickerData.enumerated() {
            if filterValue == currentPickerValue {
                self.pickerView.selectRow(index, inComponent: 0, animated: true)
                break
            }
        }
        
        //update the view of the picker view
        self.pickerView.reloadAllComponents()
        
        //deselect the current row
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - IBActions
    
    /// This function closes the view without further actions.
    ///
    /// - Parameter sender: any
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// This functions sends the current filter settings via delegation to the parent view controller and closes the filter view.
    ///
    /// - Parameter sender: any
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.delegate?.sendFilterSettings(country: (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text)!,
                                          district: (self.tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.detailTextLabel?.text)!,
                                          city: (self.tableView.cellForRow(at: IndexPath(row: 2, section: 0))?.detailTextLabel?.text)!,
                                          schoolType: (self.tableView.cellForRow(at: IndexPath(row: 3, section: 0))?.detailTextLabel?.text)!,
                                          agency: (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0))?.detailTextLabel?.text)!)
//                                          schoolProfile: (self.tableView.cellForRow(at: IndexPath(row: 4, section: 0))?.detailTextLabel?.text)!)
        self.dismiss(animated: true, completion: nil)
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
