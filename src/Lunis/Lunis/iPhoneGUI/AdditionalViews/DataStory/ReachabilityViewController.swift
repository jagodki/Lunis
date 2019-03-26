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
                self.cellValue = cell.cellValue(for: self.school.schoolName!)
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
    
    @IBAction func longPressGestureOnMapView(_ sender: Any) {
        //get the coordinates
        if (sender as AnyObject).state != UIGestureRecognizer.State.began { return }
        let touchLocation = (sender as AnyObject).location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
        
        //remove all old annotations
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        //create a new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        //get the distance to the tapped position
        let distanceAtPosition = self.school.administration?.grid?.cellValue(at: locationCoordinate, for: self.school.schoolName!)
        if distanceAtPosition == -99.9 {
            annotation.title = "Position is not within the raster"
            annotation.subtitle = String(format: "Coordinates: %.5f, %.5f", [locationCoordinate.longitude, locationCoordinate.latitude])
        } else {
            annotation.title = String(format: "Average distance to the position: %.0f m", distanceAtPosition!)
        }
        
        //add the annonation to the map and select it, i.e. show the callout
        self.mapView.addAnnotation(annotation)
        self.mapView.selectedAnnotations = self.mapView.annotations
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
                if (self.school.administration?.grid!.maximumCellValue(for: self.school.schoolName!))! - (self.school.administration?.grid!.minimumCellValue(for: self.school.schoolName!))! != 0.0 {
                    ratio = (self.cellValue - (self.school.administration?.grid!.minimumCellValue(for: self.school.schoolName!))!) / ((self.school.administration?.grid!.maximumCellValue(for: self.school.schoolName!))! - (self.school.administration?.grid!.minimumCellValue(for: self.school.schoolName!))!)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
