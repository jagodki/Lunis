//
//  DataViewTableController.swift
//  Lunis
//
//  Created by Christoph on 17.10.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit

struct TestStructure {
    var id : Int
    var name : String
}

struct TestSection {
    var name : String
    var data : [TestStructure]
}

class DataViewTableController: UITableViewController {
    
    //define testdata for the protoype
    let testData = [
        TestSection(name: "Grundschule", data: [
            TestStructure(id: 1, name: "1. Grundschule"),
            TestStructure(id: 2, name: "Knabengrundschule")
            ]),
        TestSection(name: "Gymnasium", data: [
            TestStructure(id: 1, name: "Lößnitzgymnasium"),
            TestStructure(id: 2, name: "Landesanstalt St. Afra")
            ]),
        TestSection(name: "Hochschule", data: [
            TestStructure(id: 1, name: "TU Dresden"),
            TestStructure(id: 2, name: "HTW Dresden")
            ])
    ]
    
    //outlets
    @IBOutlet var buttonSelect: UIBarButtonItem!
    @IBOutlet var buttonFilter: UIBarButtonItem!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        //add a search bar to the navigation bar
        let searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
        //allow multiple selection during editing
        //self.tableView.allowsMultipleSelectionDuringEditing = true
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.testData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.testData[section].data.count
    }
    
    @IBAction func selectButtonPress(_ sender: Any) {
        if self.tableView.isEditing == true {
            self.tableView.setEditing(false, animated: true)
            self.buttonSelect.title = "Select"
            self.buttonSelect.style = .plain
            self.buttonFilter.isEnabled = true
            self.segmentedControl.isEnabled = true
            //self.navigationItem.searchController?.isActive = true
        } else {
            self.tableView.setEditing(true, animated: true)
            self.buttonSelect.title = "Done"
            self.buttonSelect.style = .done
            self.buttonFilter.isEnabled = false
            self.segmentedControl.isEnabled = false
            //self.navigationItem.searchController?.isActive = false
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath)
        cell.textLabel?.text = self.testData[indexPath.section].data[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.testData[section].name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete;
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
