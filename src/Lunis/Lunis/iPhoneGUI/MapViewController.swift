//
//  MapViewController.swift
//  Lunis
//
//  Created by Christoph on 29.05.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        //prepare search bar
        self.searchBar.bounds.origin.y = self.view.bounds.origin.y - self.searchBar.bounds.height / 2
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showHideSearchBar(_ sender: Any) {
        if(self.searchBar.isHidden) {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.transitionCurlDown, animations: {
                self.searchBar.isHidden = false
                //self.searchBar.center.y = self.navigationBar.bounds.minY + self.searchBar.bounds.height / 2
                self.searchBar.center.y = self.navigationBar.center.y + (self.searchBar.bounds.height - self.navigationBar.bounds.height)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.transitionCurlUp, animations: {
                self.searchBar.center.y = self.view.bounds.origin.y + self.searchBar.bounds.height / 2
                self.searchBar.isHidden = true
            }, completion: nil)
        }
    }
}

