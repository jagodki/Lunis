//
//  DataViewTableController.swift
//  Lunis
//
//  Created by Christoph on 17.10.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit

struct DataViewSchoolCell {
    var id: Int
    var name: String
}

struct DataViewSchoolSection {
    var name: String
    var data: [DataViewSchoolCell]
}

/// The controller for the data view.
class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //define testdata for the protoype
    let testData = [
        DataViewSchoolSection(name: "Grundschule", data: [
            DataViewSchoolCell(id: 1, name: "1. Grundschule"),
            DataViewSchoolCell(id: 2, name: "Knabengrundschule")
            ]),
        DataViewSchoolSection(name: "Gymnasium", data: [
            DataViewSchoolCell(id: 1, name: "Lößnitzgymnasium"),
            DataViewSchoolCell(id: 2, name: "Landesanstalt St. Afra")
            ]),
        DataViewSchoolSection(name: "Hochschule", data: [
            DataViewSchoolCell(id: 1, name: "Uniwersytet Wrocławia"),
            DataViewSchoolCell(id: 2, name: "HTW Dresden")
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
    
    // MARK: - instance variables
    
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
    
    //store the filtered schools
    var filteredSchools: [DataViewSchoolCell] = [DataViewSchoolCell]()
    
    // MARK: - functions
    
    override func viewDidLoad() {
        //init the unselected rows var
        self.unselectedRows = 6
        
        super.viewDidLoad()
        
        //hide toolbar, store its size and position and show tabbar
        self.tabBarController?.tabBar.isHidden = false
        self.toolbar.isHidden = true
        self.tbRect = CGRect(x: self.toolbar.frame.origin.x   , y: self.toolbar.frame.origin.y + self.toolbar.frame.height, width: self.toolbar.frame.width , height: self.toolbar.frame.height)
        
        //setup a searchcontroller and add them to the navigationbar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Schools"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.toolbar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - table view implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isFiltering() {
            return 1
        }
        
        return self.testData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering() {
            return self.filteredSchools.count
        }
        
        return self.testData[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath)
        
        if self.isFiltering() {
            cell.textLabel?.text = self.filteredSchools[indexPath.row].name
        } else {
            cell.textLabel?.text = self.testData[indexPath.section].data[indexPath.row].name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !self.isFiltering() {
            return self.testData[section].name
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.unselectedRows = self.unselectedRows - 1
        if self.unselectedRows == 0 {
            self.allSelected = true
            self.buttonSelectAll.title = "Deselect All"
        }
        
        //performe a segue and remove the selection, if the table view is not in editing mode
        if !self.tableview.isEditing {
            performSegue(withIdentifier: "showSchoolDetailFromData", sender: self)
            self.tableview.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.unselectedRows = self.unselectedRows + 1
        self.allSelected = false
        self.buttonSelectAll.title = "Select All"
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let markAsFavorite = UIContextualAction(style: .normal, title: "\u{2605}") {(action, view, completion) in
            print("favorite")
            completion(true)
        }
        markAsFavorite.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        
        let unmarkAsFavorite = UIContextualAction(style: .normal, title: "\u{2606}") {(action, view, completion) in
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
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - IBActions and other functions for the user interaction
    
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
    
    //checks the status of all selected rows to get the information, whether all selected rows are favorites or not
    func checkFavoriteStatusOfSelectedRows() {
        
    }
    
    // MARK: - navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showFilterDataView":
            let viewController = segue.destination as! FilterDataViewController
            viewController.delegate = self
            
        case "showSchoolDetailView":
            let viewController = segue.destination as! SchoolDetailView
            
            //get the school name of the selected row and pass it to the new view controller
            let indexPath: IndexPath! = (self.tableview.indexPathForSelectedRow)!
            viewController.schoolName = (self.tableview.cellForRow(at: indexPath)?.textLabel?.text)!
            
        default:
            _ = true
        }
    }
    
    // MARK: - functions for the implementation of the searchcontroller
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return !(self.navigationItem.searchController!.searchBar.text?.isEmpty)!
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        //get the rows of all sections
        var allSchoolRows: [DataViewSchoolCell] = [DataViewSchoolCell]()
        for section in self.testData {
            allSchoolRows.append(contentsOf: section.data)
        }
        
        //filter all school rows
        filteredSchools = allSchoolRows.filter({(dataViewSchoolCell : DataViewSchoolCell) -> Bool in
            return dataViewSchoolCell.name.lowercased().contains(searchText.lowercased())
        })
        
        //reload the table
        self.tableview.reloadData()
    }
    
    func isFiltering() -> Bool {
        return self.navigationItem.searchController!.isActive && !searchBarIsEmpty()
    }
    
}

// MARK: - implementation of FilterDataViewDelegate
extension DataViewController: FilterDataViewDelegate {
    
    func sendFilterSettings(country: String, district: String, city: String, schoolType: String) {
        self.filter["Country"] = country
        self.filter["District"] = district
        self.filter["City"] = city
        self.filter["School Type"] = schoolType
    }
    
    func getCurrentFilterSettings() -> [String: String]! {
        return self.filter
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension DataViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
