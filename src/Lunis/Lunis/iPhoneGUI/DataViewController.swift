//
//  DataViewTableController.swift
//  Lunis
//
//  Created by Christoph on 17.10.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit
import CoreData


/// The controller for the data view.
class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //strings for titles of gui elements
    let buttonFavoriteUnmarkTitle = "Unmark as Favorite(s)"
    let buttonFavoriteMarkTitle = "Mark as Favorite(s)"
    let buttonSelectAllTitle = "Select All"
    let buttonDeselectAllTitle = "Deselect All"
    
    
    // MARK: - Outlets
    @IBOutlet var buttonSelect: UIBarButtonItem!
    @IBOutlet var buttonFilter: UIBarButtonItem!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var buttonSelectAll: UIBarButtonItem!
    @IBOutlet var buttonFavorite: UIBarButtonItem!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var tableView: UITableView!
    
    // MARK: - instance variables
    
    //a tableviewontroller to store the search results
    var searchResultsController: UITableViewController!
    
    //store the dimension and position of the toolbar
    var tbRect: CGRect!
    
    //store the searched schools
    var searchedSchools: [SchoolMO] = [SchoolMO]()
    
    //store the selected cell
    var selectedSchool: SchoolMO!
    
    //the data controller for connecting to core data
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<SchoolMO>!
    
    // MARK: - functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide toolbar, store its size and position and show tabbar
        self.tabBarController?.tabBar.isHidden = false
        self.toolbar.isHidden = true
        self.tbRect = CGRect(x: self.toolbar.frame.origin.x   , y: self.toolbar.frame.origin.y + self.toolbar.frame.height, width: self.toolbar.frame.width , height: self.toolbar.frame.height)
        
        //set up a searchresultcontroller
        self.searchResultsController = UITableViewController(style: .plain)
        self.searchResultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchedSchoolsCell")
        self.searchResultsController.tableView.dataSource = self
        self.searchResultsController.tableView.delegate = self
        
        //set up a searchcontroller and add them to the navigationbar
        let searchController: UISearchController = UISearchController(searchResultsController: self.searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search for Schools"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        //init the data controller
        self.dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
        
        //fetch data from core data
        self.segmentedControlChanged((Any).self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.toolbar.isHidden = true
        
        //fetch data from core data
        self.segmentedControlChanged((Any).self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - table view implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return self.fetchedResultsController.sections!.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.fetchedResultsController.sections![section].numberOfObjects
        } else {
            return self.searchedSchools.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String!
        var textLabel: String!
        var insertFavIcon: Bool!
        var mainTable: Bool!
        
        if tableView == self.tableView{
            cellIdentifier = "schoolCell"
            textLabel = self.fetchedResultsController?.object(at: indexPath).name
            insertFavIcon = self.fetchedResultsController?.object(at: indexPath).favorite
            mainTable = true
        } else {
            cellIdentifier = "searchedSchoolsCell"
            textLabel = self.searchedSchools[indexPath.row].name
            insertFavIcon = false
            mainTable = false
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = textLabel
        if insertFavIcon && mainTable {
            cell.imageView?.image = UIImage(named: "favorite")
        } else if mainTable {
            cell.imageView?.image = UIImage(named: "no_favorite")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView {
            return self.fetchedResultsController.sections![section].name
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performe a segue and remove the selection, if the table view is not in editing mode
        if !tableView.isEditing {
            if tableView == self.tableView{
                self.selectedSchool = self.fetchedResultsController?.object(at: indexPath)
            } else {
                self.selectedSchool = self.searchedSchools[indexPath.row]
            }
            
            performSegue(withIdentifier: "showSchoolDetailFromData", sender: self)
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.searchResultsController.tableView.deselectRow(at: indexPath, animated: true)
        } else {
            //adjust the select all button
            if tableView.indexPathsForSelectedRows?.count == self.fetchedResultsController.fetchedObjects?.count && tableView.isEditing && tableView == self.tableView {
                self.buttonSelectAll.title = self.buttonDeselectAllTitle
            }
            
            //enable the mark/unmak as favorite button
            self.adjustFavoriteButton(tableView: tableView)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //disable the mark/unmak as favorite button, whether all rows are deselected
        if tableView.indexPathsForSelectedRows?.count == 0 || tableView.indexPathsForSelectedRows?.count == nil {
            self.buttonFavorite.isEnabled = false
            self.buttonFavorite.title = self.buttonFavoriteMarkTitle
        } else {
            //adjust the select all button
            self.buttonSelectAll.title = self.buttonSelectAllTitle
            
            //enable the mark/unmak as favorite button
            self.adjustFavoriteButton(tableView: tableView)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //define the actions
        let markAsFavorite = UIContextualAction(style: .normal, title: "\u{2605}") {(action, view, completion) in
            self.markFavorite(at: indexPath, with: UITableViewRowAnimation.right)
            completion(true)
        }
        markAsFavorite.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        
        let unmarkAsFavorite = UIContextualAction(style: .normal, title: "\u{2606}") {(action, view, completion) in
            self.unmarkFavorite(at: indexPath, with: UITableViewRowAnimation.right)
            completion(true)
        }
        unmarkAsFavorite.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        
        let showOnMap = UIContextualAction(style: .normal, title: "\u{1F30D}") {(action, view, completion) in
            print("map")
            completion(true)
        }
        showOnMap.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        
        //create an array of actions, depending on the favorite status of the current row
        var actions: [UIContextualAction]
        if self.fetchedResultsController.object(at: indexPath).favorite {
            actions = [unmarkAsFavorite, showOnMap]
        } else {
            actions = [markAsFavorite, showOnMap]
        }
        
        //return only the map action, if the search is active
        if self.tableView == tableView {
            return UISwipeActionsConfiguration(actions: actions)
        } else {
            return UISwipeActionsConfiguration(actions: [showOnMap])
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
        self.segmentedControl.isEnabled = self.tableView.isEditing
        self.buttonFilter.isEnabled = self.tableView.isEditing
        self.tabBarController?.tabBar.isHidden = !self.tableView.isEditing
        self.buttonFavorite.isEnabled = false
        
        //show/hide the toolbar and the tabbar
        UIView.animate(withDuration: 0.2, animations: {
            () -> Void in
            // show/hide toolbar
            if self.toolbar.isHidden {
                self.buttonSelectAll.title = self.buttonSelectAllTitle
                self.toolbar.isHidden = false
                self.toolbar.frame = self.tbRect
            }else {
                let frameRect = CGRect(x: self.toolbar.frame.origin.x , y: self.toolbar.frame.origin.y + self.toolbar.frame.height, width: self.toolbar.frame.width , height: self.toolbar.frame.height)
                self.toolbar.frame = frameRect
                self.toolbar.isHidden = true
            }
        })
        
        //update the editing status and make the tableview editable
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        
        //update the edit select button depending on the editing status
        if self.tableView.isEditing {
            self.buttonSelect.title = "Done"
            self.buttonSelect.style = .done
        } else {
            self.buttonSelect.title = "Select"
            self.buttonSelect.style = .plain
        }
    }
    
    /// This function selects all rows of the table view.
    ///
    /// - Parameter sender: any
    @IBAction private func selectAllButtonPressed(_ sender: Any) {
        //iterate over all sections
        let totalSections = self.tableView.numberOfSections
        for section in 0..<totalSections {
            
            //iterate over all rows of the current section
            let totalRows = self.tableView.numberOfRows(inSection: section)
            for row in 0..<totalRows {
                
                //select or deselect the current row depending on the button title
                if self.buttonSelectAll.title == self.buttonSelectAllTitle {
                    self.tableView.selectRow(at: IndexPath(row: row, section: section), animated: false, scrollPosition: UITableViewScrollPosition.none)
                } else {
                    self.tableView.deselectRow(at: IndexPath(row: row, section: section), animated: true)
                }
            }
        }
        
        //update the appearence of the buttons
        if self.buttonSelectAll.title == self.buttonSelectAllTitle {
            self.buttonSelectAll.title = self.buttonDeselectAllTitle
        } else {
            self.buttonSelectAll.title = self.buttonSelectAllTitle
        }
        self.adjustFavoriteButton(tableView: self.tableView)
    }
    
    /// This function marks or unmarks all selected rows of the table view as favorites.
    /// If at least one row of the selected rows is not already marked as favorite, the selection will be marked as favorites.
    /// Otherwise the whole selection will be unmarked.
    ///
    /// - Parameter sender: any
    @IBAction private func favoriteButtonPressed(_ sender: Any) {
        //get all selected rows
        guard let indexPathsOfSelectedRows = self.tableView.indexPathsForSelectedRows else {
            return
        }
        
        //check the button title and mark or unmark all selected rows
        if self.buttonFavorite.title == self.buttonFavoriteMarkTitle {
            for indexPath in indexPathsOfSelectedRows {
                self.markFavorite(at: indexPath, with: UITableViewRowAnimation.fade)
            }
            self.buttonFavorite.title = self.buttonFavoriteUnmarkTitle
        } else {
            for indexPath in indexPathsOfSelectedRows {
                self.unmarkFavorite(at: indexPath, with: UITableViewRowAnimation.fade)
            }
            self.buttonFavorite.title = self.buttonFavoriteMarkTitle
        }
        
        //disable the button and adjust its title
        self.buttonFavorite.isEnabled = false
        self.buttonFavorite.title = self.buttonFavoriteMarkTitle
        
        //adjust the title of the selection button
        self.buttonSelectAll.title = self.buttonSelectAllTitle
    }
    
    /// This function marks a given row as a favorite, i.e. a favorite icon will be inserted.
    ///
    /// - Parameters:
    ///   - indexPath: the index to find the row
    ///   - animation: the animation for reloading the table row
    private func markFavorite(at indexPath: IndexPath, with animation: UITableViewRowAnimation) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.imageView?.image = UIImage(named: "favorite")
        self.fetchedResultsController?.object(at: indexPath).favorite = true
        self.dataController.saveData()
        self.tableView.reloadRows(at: [indexPath], with: animation)
    }
    
    /// This function unmarkes a given row as favorite.
    ///
    /// - Parameters:
    ///   - indexPath: the index to find the row
    ///   - animation: the animation for reloading the table row
    private func unmarkFavorite(at indexPath: IndexPath, with animation: UITableViewRowAnimation) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.imageView?.image = UIImage(named: "no_favorite")
        self.fetchedResultsController?.object(at: indexPath).favorite = false
        self.dataController.saveData()
        self.tableView.reloadRows(at: [indexPath], with: animation)
    }
    
    /// This function adjust the appearence of the Mark-/Unmark-as-Favorite-Button.
    ///
    /// - Parameter tableView: a UITableView, that content is mandatory to control the appearence of the button
    private func adjustFavoriteButton(tableView: UITableView) {
        //check the table view
        guard tableView.isEditing && tableView == self.tableView else {
            return
        }
        
        //adjust the title of the mark/unmark favorites button
        guard self.tableView.indexPathsForSelectedRows != nil && tableView.indexPathsForSelectedRows?.count != 0 else {
            self.buttonFavorite.isEnabled = false
            self.buttonFavorite.title = self.buttonFavoriteMarkTitle
            return
        }
        self.buttonFavorite.isEnabled = true
        
        //if at least one selection is not favorite, the button shows "mark as favorite"
        for selectedIndexPath in tableView.indexPathsForSelectedRows! {
            if self.fetchedResultsController.object(at: selectedIndexPath).favorite == false {
                self.buttonFavorite.title = self.buttonFavoriteMarkTitle
                return
            }
            self.buttonFavorite.title = self.buttonFavoriteUnmarkTitle
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        //init a variable to store the filter expression
        var request: String = ""
        var filter: Bool = false
        
        switch self.segmentedControl.selectedSegmentIndex {
            case 0:
                request = ""
            case 1:
                request = "favorite == true"
            case 2:
                filter = true
            default:
                break
        }
        
        //fetch data from core data
        if filter {
            self.fetchedResultsController = self.dataController.fetchSchools(filter: true, groupedBy: "schoolType", orderedBy: "name", orderedAscending: true)
        } else {
            self.fetchedResultsController = self.dataController.fetchSchools(request: request, groupedBy: "schoolType", orderedBy: "name", orderedAscending: true)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "showFilterDataView":
                let viewController = segue.destination as! FilterDataViewController
                viewController.delegate = self
                viewController.countryData = self.dataController.distinctValues(for: "country", in: "Administration")
                viewController.countryData.insert("All", at: 0)
                viewController.districtData = self.dataController.distinctValues(for: "region", in: "Administration")
                viewController.districtData.insert("All", at: 0)
                viewController.cityData = self.dataController.distinctValues(for: "city", in: "School")
                viewController.cityData.insert("All", at: 0)
                viewController.schoolTypeData = self.dataController.distinctValues(for: "schoolType", in: "School")
                viewController.schoolTypeData.insert("All", at: 0)
//                viewController.schoolProfileData = self.dataController.distinctValues(for: "schoolSpecialisation", in: "School")
//                viewController.schoolProfileData.insert("All", at: 0)
            
            case "showSchoolDetailFromData":
                let viewController = segue.destination as! SchoolDetailView
                viewController.school = self.selectedSchool
            
            default:
                _ = true
        }
    }
}

// MARK: - implementation of FilterDataViewDelegate
extension DataViewController: FilterDataViewDelegate {
    
    func sendFilterSettings(country: String, district: String, city: String, schoolType: String) {
        self.dataController.filter["Country"] = country
        self.dataController.filter["District"] = district
        self.dataController.filter["City"] = city
        self.dataController.filter["School Type"] = schoolType
        self.segmentedControl.selectedSegmentIndex = 2
        self.tableView.reloadData()
    }
    
    func getCurrentFilterSettings() -> [String: String]! {
        return self.dataController.filter
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension DataViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
         //get the search text
         let searchText: String = searchController.searchBar.text!
         
         //get the rows of all sections
        let allSchoolRows: [SchoolMO] = self.fetchedResultsController.fetchedObjects!
         
         //filter all school rows
         self.searchedSchools = allSchoolRows.filter({(dataViewSchoolCell: SchoolMO) -> Bool in
            return dataViewSchoolCell.name.lowercased().contains(searchText.lowercased())
         })
         
         //reload the table
         self.searchResultsController.tableView.reloadData()
    }
}

// MARK: - implementation of NSFetchedResultsControllerDelegate
extension DataViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
}
