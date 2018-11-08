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

class FilterDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //table data
    let tableData = [
        Section(title: " ", rows: [
            Row(name: "Country", value: "All"),
            Row(name: "District", value: "All"),
            Row(name: "City", value: "All"),
            Row(name: "School Type", value: "All")
        ])
    ]
    
    //array for storing picker data
    var countryData: [String]! = ["Deutschland", "Polska"]
    var districtData: [String]! = ["Sachsen", "Dolnoslaskie"]
    var cityData: [String]! = ["Dresden", "Radebeul", "Breslau"]
    var schoolTypeData: [String]! = ["Grundschule", "Gymnasium", "Hochschule"]
    var pickerData: [String]! = ["---"]
    
    //store the index of the current/selected table row
    var currentCell: UITableViewCell!
    
    // MARK: - Outlets
    @IBOutlet var buttonDone: UIBarButtonItem!
    @IBOutlet var buttonCancel: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init the picker view
//        self.pickerView.dataSource = self
//        self.pickerView.delegate = self
        
        //init the currentCell-var
        self.currentCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //typeLabel.text = self.pickerView[row]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentCell.detailTextLabel?.text = self.pickerData[row]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        
        //set the text content
        cell.textLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].name
        cell.detailTextLabel?.text = self.tableData[indexPath.section].rows[indexPath.row].value
        
        //edit the text colours
        cell.textLabel?.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        cell.detailTextLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData[section].title
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
        cell?.detailTextLabel?.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        
        //change the data for the picker
        switch cell?.textLabel?.text {
            case "Country":
                self.pickerData = self.countryData
            case "District":
                self.pickerData = self.districtData
            case "City":
                self.pickerData = self.cityData
            case "School Type":
                self.pickerData = self.schoolTypeData
            default:
                print("default")
        }
        
        //deselect the current row
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
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
