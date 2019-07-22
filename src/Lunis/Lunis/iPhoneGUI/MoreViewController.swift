//
//  MoreViewControllerTableViewController.swift
//  Lunis
//
//  Created by Christoph on 15.07.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        switch cell?.reuseIdentifier {
        case "sourceCode":
            let urlString = "https://github.com/jagodki/Lunis"
            let cleanedUpUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            UIApplication.shared.open(URL(string: cleanedUpUrl!)!)
        case "icons":
            let urlString = "https://icons8.com/"
            let cleanedUpUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            UIApplication.shared.open(URL(string: cleanedUpUrl!)!)
        default:
            return
        }
    }

}
