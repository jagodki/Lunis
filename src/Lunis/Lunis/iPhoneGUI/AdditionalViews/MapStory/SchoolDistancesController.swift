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
    
    var tableDataSchools: [SchoolMO]!
    var tableDataHash: [SchoolMO: Double]!
    var start: CLLocation!
    var destinations: [SchoolMO]!
    
    //MARK: - standard methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tableDataSchools.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "distanceSchoolCell", for: indexPath)
        cell.textLabel?.text = self.tableDataSchools[indexPath.row].name
        cell.detailTextLabel?.text = String(format: "%.0f", self.tableDataHash[self.tableDataSchools[indexPath.row]]!)
        
        //change the colour of the detail label
        cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)

        return cell
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetailFromDistance", sender: self)
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
    
    func calculateRoutes() {
        
    }
    
    private func shortestDistance(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        //set up the routing request
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        directionRequest.transportType = .any
        
        //set up the return variable
        var shortestDistance = 999999999999.99
        
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
                if route.distance < shortestDistance {
                    shortestDistance = route.distance
                }
            }
        }
        
        return shortestDistance
    }
}
