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

/// The controller for the data view.
class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FilterDataViewDelegate {
    
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
            TestStructure(id: 1, name: "Uniwersytet Wrocławia"),
            TestStructure(id: 2, name: "HTW Dresden")
            ])
    ]
    
    // MARK: - Outlets
    @IBOutlet var buttonSelect: UIBarButtonItem!
    @IBOutlet var buttonFilter: UIBarButtonItem!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var buttonSelectAll: UIBarButtonItem!
    @IBOutlet var buttonFavorite: UIBarButtonItem!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var tableview: UITableView!
    
    //a variable to store, whether all rows are selected or not
    var allSelected: Bool! = false
    
    //a variable to store the count of unselected rows
    var unselectedRows: Int!
    
    //a variable to store, whether all rows are favorites or not
    var allFavorites: Bool! = false
    
    //store the dimension and position of the toolbar
    var tbRect: CGRect!
    
    //store the filter
    var filter: [String: String]! = ["Country":"All", "District":"All", "City":"All","School Type":"All"]
    
    //define a variable for the delegation with FilterDataViewController
    var filterDataViewController: FilterDataViewController?
    
    override func viewDidLoad() {
        //add a search bar to the navigation bar
        let searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
        //hide toolbar, store its size and position and show tabbar
        self.tabBarController?.tabBar.isHidden = false
        self.toolbar.isHidden = true
        self.tbRect = CGRect(x: self.toolbar.frame.origin.x   , y: self.toolbar.frame.origin.y + self.toolbar.frame.height, width: self.toolbar.frame.width , height: self.toolbar.frame.height)
        
        //init the unselected rows var
        self.unselectedRows = 6
        
        //init the delegation var
        self.filterDataViewController = FilterDataViewController()
        self.filterDataViewController?.delegate = self
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.testData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.testData[section].data.count
    }
    
    
    /// This function sets the table view in edit mode,
    /// i.e. that rows will be selectable, unneeded buttons and segmented controls will be diabled
    /// and the tabbar will be replaced by a toolbar.
    ///
    /// - Parameter sender: any
    @IBAction private func selectButtonPressed(_ sender: Any) {
        //enable and disable UI-elements depending on the editing status
        self.segmentedControl.isEnabled = self.tableview.isEditing
        self.buttonFilter.isEnabled = self.tableview.isEditing
        self.tabBarController?.tabBar.isHidden = !self.tableview.isEditing
        
        //show/hide the toolbar and the tabbar
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            // show/hide toolbar
            if self.toolbar.isHidden {
                self.buttonSelectAll.title = "Select All"
                self.toolbar.isHidden = false
                self.toolbar.frame = self.tbRect
            }else {
                let frameRect = CGRect(x: self.toolbar.frame.origin.x   , y: self.toolbar.frame.origin.y + self.toolbar.frame.height, width: self.toolbar.frame.width , height: self.toolbar.frame.height)
                self.toolbar.frame = frameRect
                self.toolbar.isHidden = true
            }
        })
        
        //update the editing status and make the tableview editable
        self.tableview.setEditing(!self.tableview.isEditing, animated: true)
        
        //update the edit select button depending on the editing status
        if self.tableview.isEditing {
            self.buttonSelect.title = "Done"
            self.buttonSelect.style = .done
            self.allSelected = false
        } else {
            self.buttonSelect.title = "Select"
            self.buttonSelect.style = .plain
        }
        
        //update the vars to store the selection status
        self.unselectedRows = 6
        self.allSelected = false
    }
    
    /// This function selects all rows of the table view.
    ///
    /// - Parameter sender: any
    @IBAction private func selectAllButtonPressed(_ sender: Any) {
        //iterate over all sections
        let totalSections = self.tableview.numberOfSections
        for section in 0..<totalSections {
            
            //iterate over all rows of the current section
            let totalRows = self.tableview.numberOfRows(inSection: section)
            for row in 0..<totalRows {
                
                //select or deselect the current row
                if self.allSelected {
                    self.tableview.deselectRow(at: IndexPath(row: row, section: section), animated: true)
                } else {
                    self.tableview.selectRow(at: IndexPath(row: row, section: section), animated: false, scrollPosition: UITableViewScrollPosition.none)
                }
            }
        }
        
        //update the appearence of the buttons
        if self.allSelected {
            self.buttonSelectAll.title = "Select All"
        } else {
            self.buttonSelectAll.title = "Deselect All"
        }
        
        //update the variables to store the selection status
        self.allSelected = !self.allSelected
        if self.allSelected {
            self.unselectedRows = 0
        } else {
            self.unselectedRows = 6
        }
    }
    
    /// This function marks or unmarks all selected rows of the table view as favorites.
    /// If at least one row of the selected rows is not already marked as favorite, the selection will be marked as favorites.
    /// Otherwise the whole selection will be unmarked.
    ///
    /// - Parameter sender: any
    @IBAction private func favoriteButtonPressed(_ sender: Any) {
        //iterate over all sections and mark or unmark them as favorites
        let indexPathsOfSelectedRows = self.tableview.indexPathsForSelectedRows
        if indexPathsOfSelectedRows != nil {
            if self.allFavorites {
                for indexPath in indexPathsOfSelectedRows! {
                    self.unmarkFavorite(section: indexPath.section, row: indexPath.row)
                }
            } else {
                for indexPath in indexPathsOfSelectedRows! {
                    self.markFavorite(section: indexPath.section, row: indexPath.row)
                }
            }
            
            //update the appearence of the buttons
            if self.allFavorites {
                self.buttonFavorite.title = "Mark Favorites"
            } else {
                self.buttonFavorite.title = "Unmark Favorites"
            }
            
            //change the status of the variable to store, whether all selected rows are favorites or not
            self.allFavorites = !self.allFavorites
        }
    }
    
    /// This function marks a given row as a favorite, i.e. a favorite icon will be inserted.
    ///
    /// - Parameters:
    ///   - section: the index of the section, where the row can be found
    ///   - row: the index of the row in the given section
    private func markFavorite(section: Int, row: Int) {
        let cell = self.tableview.cellForRow(at: NSIndexPath(row: row, section: section) as IndexPath)
        cell?.imageView?.image = UIImage(named: "favorite")
        //self.tableview.reloadData()
    }
    
    /// This function unmarkes a given row as favorite.
    ///
    /// - Parameters:
    ///   - section: the index of the section, where the row can be found
    ///   - row: the index of the row in the given section
    private func unmarkFavorite(section: Int, row: Int) {
        let cell = self.tableview.cellForRow(at: NSIndexPath(row: row, section: section) as IndexPath)
        cell?.imageView?.image = UIImage(named: "no_favorite")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath)
        cell.textLabel?.text = self.testData[indexPath.section].data[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.testData[section].name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.unselectedRows = self.unselectedRows - 1
        if self.unselectedRows == 0 {
            self.allSelected = true
            self.buttonSelectAll.title = "Deselect All"
        }
        
        //remove the selection if the table view is not in editing mode, i.e. a schoolDetailView was called
        if !self.tableview.isEditing {
            self.tableview.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.unselectedRows = self.unselectedRows + 1
        self.allSelected = false
        self.buttonSelectAll.title = "Select All"
    }
    
    //checks the status of all selected rows to get the information, whether all selected rows are favorites or not
    func checkFavoriteStatusOfSelectedRows() {
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let markAsFavorite = UIContextualAction(style: .normal, title: "★") {(action, view, completion) in
            print("favorite")
            completion(true)
        }
        markAsFavorite.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        
        let unmarkAsFavorite = UIContextualAction(style: .normal, title: "☆") {(action, view, completion) in
            print("no favorite")
            completion(true)
        }
        unmarkAsFavorite.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        
        let showOnMap = UIContextualAction(style: .normal, title: "\u{1F30D}") {(action, view, completion) in
            print("map")
            completion(true)
        }
        showOnMap.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        
        if self.allFavorites {
            return UISwipeActionsConfiguration(actions: [unmarkAsFavorite, showOnMap])
        } else {
            return UISwipeActionsConfiguration(actions: [markAsFavorite, showOnMap])
        }
    }

//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return UITableViewCellEditingStyle.delete;
//    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func sendFilterSettings(country: String, district: String, city: String, schoolType: String) {
        self.filter["Country"] = country
        self.filter["District"] = district
        self.filter["City"] = city
        self.filter["School Type"] = schoolType
    }
    
    func getCurrentFilterSettings() -> [String: String]! {
        return self.filter
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showFilterDataView":
            let viewController = segue.destination as! FilterDataViewController
            viewController.delegate = self
        case "showSchoolDetailView":
            let viewController = segue.destination as! SchoolDetailView
            viewController.schoolName = ""
        default:
            print("default segue")
        }
        
        if segue.identifier == "showFilterDataView" {
            let viewController = segue.destination as! FilterDataViewController
            viewController.delegate = self
        }
    }
    
}
