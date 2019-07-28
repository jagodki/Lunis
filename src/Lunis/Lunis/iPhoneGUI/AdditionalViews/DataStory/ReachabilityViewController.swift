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
    var maximimumCellValue: Double!
    var minimumCellValue: Double!
    var locationManager: CLLocationManager!
    var dataController: DataController!
    
    
    //MARK: - standard methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up the map view
        self.mapView.delegate = self
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.mapView.register(SchoolMarkerView.self, forAnnotationViewWithReuseIdentifier: "schoolMarker")
        
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
        if self.school.administration?.grid!.cells != nil && self.school.administration?.grid != nil {
            
            self.maximimumCellValue = (self.school.administration?.grid?.maximumCellValue(for: Int(self.school!.localID)))!
            self.minimumCellValue = (self.school.administration?.grid?.minimumCellValue(for: Int(self.school!.localID)))!
            
            let cells = self.school.administration!.grid!.cells!.array as! [Cell]
            for cell in cells {
                let polygon = cell.polygon
                polygon.subtitle = String(format: "%.2f", cell.cellValue(for: Int(self.school!.localID)))
                self.mapView.addOverlay(polygon)
            }
        }
        self.mapView.addOverlay((self.school.administration?.polygon)!)
        self.mapView.addAnnotation(self.school)
        self.mapView.setVisibleMapRect((self.school.administration?.polygon.boundingMapRect)!, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - additional methods
    
    /// This function show an alert, if location services are disabled for this app.
    func showEnableLocationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("INFO", comment: ""), message: NSLocalizedString("LOCATION SERVICES ARE NOT ENABLED. YOUR LOCATION CANNOT BE SHOWN IN THE MAP.", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("GO TO SETTINGS NOW", comment: ""), style: UIAlertAction.Style.default, handler: {
            (alert: UIAlertAction!) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func positionButtonPressed(_ sender: Any) {
        if self.buttonPosition.title == "Position" {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                self.locationManager.startUpdatingLocation()
                self.mapView.showsUserLocation = true
                self.buttonPosition.title = "hide Position"
                self.buttonPosition.image = #imageLiteral(resourceName: "positionUnarrow")
            } else {
                self.showEnableLocationAlert()
            }
        } else {
            self.locationManager.stopUpdatingLocation()
            self.mapView.showsUserLocation = false
            self.buttonPosition.title = "Position"
            self.buttonPosition.image = #imageLiteral(resourceName: "positionArrow")
        }
    }
    
    @IBAction func longPressGestureOnMapView(_ sender: Any) {
        //get the coordinates
        if (sender as AnyObject).state != UIGestureRecognizer.State.began { return }
        let touchLocation = (sender as AnyObject).location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
        
        //remove the old pin
        let oldPins = self.mapView.annotations.filter({$0.coordinate.latitude != self.school.coordinate.latitude && $0.coordinate.longitude != self.school.coordinate.longitude})
        if oldPins.count != 0 {
            self.mapView.removeAnnotations(oldPins)
        }
        
        
        //create a new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        
        //get the distance to the tapped position
        let distanceAtPosition = self.school.administration?.grid?.cellValue(at: locationCoordinate, for: Int(self.school.localID))
        if distanceAtPosition == -99.9 {
            annotation.title = NSLocalizedString("POSITION IS NOT WITHIN THE RASTER", comment: "")
        } else if distanceAtPosition == -99 {
            annotation.title = NSLocalizedString("VALUE FOR THIS POSITION CANNOT BE CALCULATED", comment: "")
        } else {
            annotation.title = String(format: "%.0f m", distanceAtPosition!)
            annotation.subtitle = NSLocalizedString("AVERAGE DISTANCE TO THE SCHOOL", comment: "")
        }
        
        //add the annonation to the map and select it, i.e. show the callout
        self.mapView.addAnnotation(annotation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mapView.selectedAnnotations = [annotation]
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
                renderer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.85)
                renderer.lineWidth = 2
            case "Cell":
                var hue = 0.0
                let cellValue = Double(overlay.subtitle!!)
                
                if self.maximimumCellValue - self.minimumCellValue != 0.0 && cellValue != -99 {
                    let ratio = (cellValue! - self.minimumCellValue) / (self.maximimumCellValue - self.minimumCellValue)
                    hue = (1 / 3) - (ratio * (1 / 3))
                }
                
                renderer.fillColor = UIColor(hue: CGFloat(hue), saturation: 1.0, brightness: 1.0, alpha: 0.35)
                renderer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.75)
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
        } else if annotation is School {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "schoolMarker", for: annotation) as? SchoolMarkerView {
                return annotationView
            } else {
                return nil
            }
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = #colorLiteral(red: 1, green: 0.3647058824, blue: 0, alpha: 1)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view is SchoolMarkerView {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
