//
//  FirstViewController.swift
//  Lunis
//
//  Created by Christoph on 29.05.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var viewGrayOverlay: UIView!
    
    /*@IBAction func infoButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showMapInfo", sender: self)
    }*/
    
    override func viewDidLoad() {
        //prepare gray overlay
        self.viewGrayOverlay.removeFromSuperview()
        self.viewGrayOverlay.alpha = 0.0
        
        //prepare container view
        self.viewContainer.removeFromSuperview()
        //self.viewContainer.center = self.view.center.x - self.view.bounds.height
        self.viewContainer.layer.cornerRadius = 10
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showContainer(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {self.viewGrayOverlay.removeFromSuperview()
            self.view.addSubview(self.viewGrayOverlay)
            self.viewGrayOverlay.alpha = 0.3
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions.transitionCurlUp, animations: {self.view.addSubview(self.viewContainer)}, completion: nil)
        
    }
    
    
}

