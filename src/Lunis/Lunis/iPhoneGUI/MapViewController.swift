//
//  MapViewController.swift
//  Lunis
//
//  Created by Christoph on 29.05.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit

extension MapViewController: InfoTableViewDelegate {
    func hideContainer(sender: InfoTableViewController) {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.transitionCurlUp, animations: {
            self.viewContainer.center.x = self.view.center.x
            self.viewContainer.center.y = self.view.bounds.height + self.viewContainer.bounds.height / 2
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.viewOverlay.alpha = 0.0
        }, completion: nil)
        
    }
}

class MapViewController: UIViewController {
    
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var infoContainerView: InfoContainerView!
    @IBOutlet var viewOverlay: UIView!
    
    override func viewDidLoad() {
        //prepare overlay
        self.viewOverlay.alpha = 0.0
        
        //prepare container view
        self.viewContainer.removeFromSuperview()
        self.viewContainer.center.x = self.view.center.x
        self.viewContainer.center.y = self.view.bounds.height + self.viewContainer.bounds.height / 2
        self.viewContainer.layer.cornerRadius = 10
        
        //prepare search bar
        self.searchBar.center.y = self.view.bounds.origin.y + self.searchBar.bounds.height / 2
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showContainer(_ sender: Any) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.viewOverlay.alpha = 0.3
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.transitionCurlUp, animations: {
            self.view.addSubview(self.viewContainer)
            self.viewContainer.center = self.view.center
        }, completion: nil)
        
    }
    
    @IBAction func showHideSearchBar(_ sender: Any) {
        if(self.searchBar.isHidden) {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.transitionCurlDown, animations: {
                self.searchBar.isHidden = false
                self.searchBar.center.y = self.navigationBar.bounds.height + self.searchBar.bounds.height / 2
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.transitionCurlUp, animations: {
                self.searchBar.center.y = self.view.bounds.origin.y + self.searchBar.bounds.height / 2
                self.searchBar.isHidden = true
            }, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueContainerViewInfoTable" {
            let embededViewController = segue.destination as! InfoTableViewController
            embededViewController.delegate = self
        }
    }
}

