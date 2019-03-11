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
    
    // MARK: - instance vars
    var school: School!
    var locationManager: CLLocationManager!
    var dataController: DataController!
    
    
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
        self.mapView.addOverlay(self.school.administration!, level: MKOverlayLevel.aboveRoads)
        self.mapView.setVisibleMapRect((self.school.administration?.boundingMapRect)!, animated: true)
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

}

// MARK: - MKMapViewDelegate
extension ReachabilityViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is Administration {
            let renderer = MKPolygonRenderer(polygon: (overlay as! Administration).polygon)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
