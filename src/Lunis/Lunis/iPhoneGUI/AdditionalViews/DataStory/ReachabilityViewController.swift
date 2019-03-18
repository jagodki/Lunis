//
//  ReachabilityViewController.swift
//  Lunis
//
//  Created by Christoph on 27.02.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ReachabilityViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var buttonPosition: UIBarButtonItem!
    
    // MARK: - instance vars
    var school: School!
    var locationManager: CLLocationManager!
    var dataController: DataController!
    var cellValue: Double! = 0.0
    
    
    //MARK: - standard methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up the map view
        self.mapView.delegate = self
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        
        //configure location manager
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 25.0      //25 meter
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.showEnableLocationAlert()
        }
        
        //init the datacontroller to fetch from coredata
        self.dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
        
        //add the geo-objects to the map
        //self.mapView.addOverlays((self.school.administration?.grid!.cells!.array as! [Cell]).map({$0.polygon}))
        if self.school.administration?.grid!.cells != nil {
            for cell in self.school.administration?.grid!.cells!.array as! [Cell] {
                self.cellValue = cell.cellValue(for: self.school.name!)
                self.mapView.addOverlay(cell.polygon)
            }
        }
        self.mapView.addOverlay((self.school.administration?.polygon)!)
        self.mapView.setVisibleMapRect((self.school.administration?.polygon.boundingMapRect)!, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - additional methods
    
    /// This function show an alert, whether location services are disabled for this app.
    func showEnableLocationAlert() {
        let alert = UIAlertController(title: "Info", message: "Location Services are not enabled. Your location cannot be shown in the map.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: UIAlertAction.Style.default, handler: {
            (alert: UIAlertAction!) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func positionButtonPressed(_ sender: Any) {
        if self.buttonPosition.title == "Position" {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                self.locationManager.startUpdatingLocation()
                self.mapView.showsUserLocation = true
                self.buttonPosition.title = "hide Position"
            } else {
                self.showEnableLocationAlert()
            }
        } else {
            self.locationManager.stopUpdatingLocation()
            self.mapView.showsUserLocation = false
            self.buttonPosition.title = "Position"
        }
    }
    

}

// MARK: - MKMapViewDelegate
extension ReachabilityViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            switch overlay.title {
            case "Administration":
                renderer.fillColor = UIColor.black.withAlphaComponent(0)
                renderer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4971372003)
                renderer.lineWidth = 2
            case "Cell":
                var ratio: Double = self.cellValue
                if (self.school.administration?.grid!.maximumCellValue(for: self.school.name!))! - (self.school.administration?.grid!.minimumCellValue(for: self.school.name!))! != 0.0 {
                    ratio = (self.cellValue - (self.school.administration?.grid!.minimumCellValue(for: self.school.name!))!) / ((self.school.administration?.grid!.maximumCellValue(for: self.school.name!))! - (self.school.administration?.grid!.minimumCellValue(for: self.school.name!))!)
                }
                let hue = (1 / 3) - (ratio * (1 / 3))
                renderer.fillColor = UIColor(hue: CGFloat(hue), saturation: 1.0, brightness: 0.85, alpha: 0.25)
                renderer.strokeColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 0.4952910959)
                renderer.lineWidth = 1
            case .none:
                renderer.fillColor = UIColor.black.withAlphaComponent(0)
            case .some(_):
                renderer.fillColor = UIColor.black.withAlphaComponent(0)
            }
            
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
