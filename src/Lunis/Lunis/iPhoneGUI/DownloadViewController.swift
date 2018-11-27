//
//  DownloadViewController.swift
//  Lunis
//
//  Created by Christoph on 02.06.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var segmentedControlContainer: UISegmentedControl!
    @IBOutlet var containerList: UIView!
    @IBOutlet var containerMap: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentedControlContainer.selectedSegmentIndex = 0
        self.containerList.alpha = 1
        self.containerMap.alpha = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.containerList.alpha = 1
                self.containerMap.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.containerList.alpha = 0
                self.containerMap.alpha = 1
            })
        }
    }
    
}

