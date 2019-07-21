//
//  PrivacyPolicyViewController.swift
//  Lunis
//
//  Created by Christoph on 17.07.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    let attributesForHeader = [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 16)]
    let attributesForText = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the titel of the navigation controler
        self.navigationItem.title = NSLocalizedString("PRIVACY POLICY", comment: "")
        
        //add the text of the privacy policy to the view
        let ppText = NSMutableAttributedString(attributedString: NSAttributedString(string: NSLocalizedString("GENERAL", comment: ""), attributes: attributesForHeader))
        ppText.append(NSAttributedString(string: "\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("GENERAL TEXT", comment: ""), attributes: attributesForText))
        
        ppText.append(NSAttributedString(string: "\n\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("INFORMATION COLLECTION", comment: ""), attributes: attributesForHeader))
        ppText.append(NSAttributedString(string: "\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("INFORMATION COLLECTION TEXT", comment: ""), attributes: attributesForText))
        
        ppText.append(NSAttributedString(string: "\n\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("SERVICE PROVIDERS", comment: ""), attributes: attributesForHeader))
        ppText.append(NSAttributedString(string: "\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("SERVICE PROVIDERS TEXT", comment: ""), attributes: attributesForText))
        
        ppText.append(NSAttributedString(string: "\n\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("SECURITY", comment: ""), attributes: attributesForHeader))
        ppText.append(NSAttributedString(string: "\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("SECURITY TEXT", comment: ""), attributes: attributesForText))
        
        ppText.append(NSAttributedString(string: "\n\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("LINKS", comment: ""), attributes: attributesForHeader))
        ppText.append(NSAttributedString(string: "\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("LINKS TEXT", comment: ""), attributes: attributesForText))
        
        ppText.append(NSAttributedString(string: "\n\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("CHILDREN", comment: ""), attributes: attributesForHeader))
        ppText.append(NSAttributedString(string: "\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("CHILDREN TEXT", comment: ""), attributes: attributesForText))
        
        ppText.append(NSAttributedString(string: "\n\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("CHANGES", comment: ""), attributes: attributesForHeader))
        ppText.append(NSAttributedString(string: "\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("CHANGES TEXT", comment: ""), attributes: attributesForText))
        
        ppText.append(NSAttributedString(string: "\n\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("CONTACT", comment: ""), attributes: attributesForHeader))
        ppText.append(NSAttributedString(string: "\n"))
        ppText.append(NSAttributedString(string: NSLocalizedString("CONTACT TEXT", comment: ""), attributes: attributesForText))
        
        self.textView.attributedText = ppText
        self.textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }

}
