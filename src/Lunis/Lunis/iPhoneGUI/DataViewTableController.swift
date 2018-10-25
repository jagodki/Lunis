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
    @IBOutlet var buttonSelectAll: UIBarButtonItem!
    @IBOutlet var buttonFavorite: UIBarButtonItem!
    
    //a variable to store, whether all rows are selected or not
    var allSelected: Bool! = false
    
    //a variable to store the count of unselected rows
    var unselectedRows: Int!
    
    //a variable to store, whether all rows are favorites or not
    var allFavorites: Bool! = false
    
    override func viewDidLoad() {
        //add a search bar to the navigation bar
        let searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
        //hide toolbar and change its position
        self.navigationController?.toolbar.isHidden = true
        self.navigationController?.toolbar.center = (self.tabBarController?.tabBar.center)!
        
        //init the unselected rows var
        self.unselectedRows = 6
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
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
    
    @IBAction func selectPressed(_ sender: Any) {
        //enable and disable UI-elements depending on the editing status
        self.segmentedControl.isEnabled = self.isEditing
        self.buttonFilter.isEnabled = self.isEditing
        self.navigationController?.setToolbarHidden(self.isEditing, animated: true)
        self.tabBarController?.tabBar.isHidden = !self.isEditing
        self.setEditing(!self.isEditing, animated: true)
        
        //update the edit select button depending on the editing status
        if self.isEditing {
            self.buttonSelect.title = "Done"
            self.buttonSelect.style = .done
            self.allSelected = false
        } else {
            self.buttonSelect.title = "Select"
            self.buttonSelect.style = .plain
        }
        
    }
    
    @IBAction func selectAllButtonPressed(_ sender: Any) {
        //iterate over all sections
        let totalSections = self.tableView.numberOfSections
        for section in 0..<totalSections {
            
            //iterate over all rows of the current section
            let totalRows = self.tableView.numberOfRows(inSection: section)
            for row in 0..<totalRows {
                
                //select or deselect the current row
                if self.allSelected {
                    self.tableView.deselectRow(at: NSIndexPath(row: row, section: section) as IndexPath, animated: true)
                } else {
                    self.tableView.selectRow(at: NSIndexPath(row: row, section: section) as IndexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
                }
            }
        }
        
        //update the appearence of the buttons
        if self.allSelected {
            self.buttonSelectAll.title = "Deselect All"
        } else {
            self.buttonSelectAll.title = "Select All"
        }
        
        //update the instance variable to store the selection status
        self.allSelected = !self.allSelected
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        //iterate over all sections
        let totalSections = self.tableView.numberOfSections
        for section in 0..<totalSections {
            
            //iterate over all rows of the current section
            let totalRows = self.tableView.numberOfRows(inSection: section)
            for row in 0..<totalRows {
                
                //remove or add the favorite
                if self.allFavorites {
                    self.unmarkFavorite(section: section, row: row)
                } else {
                    self.markFavorite(section: section, row: row)
                }
                
            }
        }
        
        //update the appearence of the buttons
        if self.allFavorites {
            self.buttonFavorite.title = "Unmark Favorites"
        } else {
            self.buttonFavorite.title = "Mark Favorites"
        }
        
        //update the instance variable to store the selection status
        self.allFavorites = !self.allFavorites
    }
    
    func markFavorite(section: Int, row: Int) {
        let cell = tableView.cellForRow(at: NSIndexPath(row: row, section: section) as IndexPath)
        cell?.imageView?.image = UIImage(named: "favorite")
    }
    
    func unmarkFavorite(section: Int, row: Int) {
        let cell = tableView.cellForRow(at: NSIndexPath(row: row, section: section) as IndexPath)
        cell?.imageView?.image = UIImage(named: "no_favorite")
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
        cell.imageView?.image = UIImage(named: "favorite")
//        cell.accessoryType = .checkmark
    }
//
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)!
//        cell.accessoryType = .none
//    }

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
