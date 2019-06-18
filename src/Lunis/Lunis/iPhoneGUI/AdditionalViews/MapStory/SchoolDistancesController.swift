//
//  SchoolDistancesController.swift
//  Lunis
//
//  Created by Christoph on 21.02.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SchoolDistancesController: UITableViewController {
    
    //MARK: - instance variables
    
    var tableDataSchools: [School]! = [School]()
    var tableDataHash: [School: Double]! = [School: Double]()
    var start: CLLocationCoordinate2D!
    var destinations: [School]!
    
    //MARK: - standard methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.start != nil && self.destinations != nil {
            self.calculateShortestDistances()
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableDataSchools.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "distanceSchoolCell", for: indexPath)
        cell.textLabel?.text = self.tableDataSchools[indexPath.row].schoolName
        cell.detailTextLabel?.text = String(format: "%.2f", self.tableDataHash[self.tableDataSchools[indexPath.row]]! / 1000) + " km"
        
        //change the colour of the detail label
        var hue: Double = 1 / 3
        if indexPath.row > 0 && self.tableDataSchools.count > 1 {
            hue = (1 / 3) - (Double(indexPath.row) / Double(self.tableDataSchools.count - 1) * (1 / 3))
        }
        cell.detailTextLabel?.textColor = UIColor(hue: CGFloat(hue), saturation: 1.0, brightness: 0.85, alpha: 1)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetailFromDistance", sender: self)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "distances to the current position"
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDetailFromDistance":
            let viewController = segue.destination as! SchoolDetailView
            viewController.school = self.tableDataSchools[(self.tableView.indexPathForSelectedRow?.row)!]
            
        default:
            _ = true
        }
    }
    
    // MARK: - additional methods
    
    /// This function calculates the shortest distances to each destination of this class. The tableview will be reloaded after each successefull calculation.
    private func calculateShortestDistances() {
        //iterate over all schools/destinations
        for destination in self.destinations {
            
            //set up the routing request
            let directionRequest = MKDirections.Request()
            directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: self.start))
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
            directionRequest.transportType = .any
            
            // calculate the directions
            let directions = MKDirections(request: directionRequest)
            directions.calculate {
                (response, error) -> Void in
                
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    return
                }
                
                //iterate over all routes
                for route in response.routes {
                    if self.tableDataHash.index(forKey: destination) == nil {
                        self.tableDataHash.updateValue(route.distance, forKey: destination)
                    } else {
                        if route.distance < self.tableDataHash[destination]! {
                            self.tableDataHash.updateValue(route.distance, forKey: destination)
                        }
                    }
                }
                
                //insert schools into tableview array, ordered by distance asc
                if self.tableDataSchools.count == 0 {
                    //insert the first school
                    self.tableDataSchools.append(destination)
                } else {
                    //iterate over all schools in the tableview array
                    for (index, school) in self.tableDataSchools.enumerated() {
                        
                        //insert at specific index, if new distance is lower than the current entry
                        if self.tableDataHash[destination]! < self.tableDataHash[school]! {
                            //insert the school before the first school with a higher distance
                            self.tableDataSchools.insert(destination, at: index)
                        }
                        
                        //insert the data set at the end of the structur
                        if index == (self.tableDataSchools.count - 1) {
                            //append the school, if the current distance is the highest
                            self.tableDataSchools.append(destination)
                        }
                        
                        
                    }
                    
                }
                //remove doubled entries
                var indices: [Int] = []
                //find doubled values
                for (index, school) in self.tableDataSchools.enumerated() {
                    if index != 0 {
                        if school.schoolName == self.tableDataSchools[index - 1].schoolName {
                            indices.append(index)
                        }
                    }
                }
                //remove them
                for index in indices.reversed() {
                    self.tableDataSchools.remove(at: index)
                }
                
                self.tableView.reloadData()
                
            }
        }
    }
}
