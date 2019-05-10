//
//  Decoder.swift
//  Lunis
//
//  Created by Christoph on 03.05.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

class Decoder: NSObject {
    
    override init() {
        
    }
    
    func parseSchoolFile(from fileURL: URL) -> SchoolFile? {
        do {
            let jsonData = try String(contentsOf: fileURL, encoding: .utf8).data(using: .utf8)
            let decoder = JSONDecoder()
            let schools = try decoder.decode(SchoolFile.self, from: jsonData!)
            return schools
        } catch {
            print("Unexpected error during parsing a schools GeoJSON file: \(error)")
            return nil
        }
    }
    
    func parseAdministrationFile(from fileURL: URL) -> AdministrationFile? {
        do {
            let jsonData = try String(contentsOf: fileURL, encoding: .utf8).data(using: .utf8)
            let decoder = JSONDecoder()
            let administration = try decoder.decode(AdministrationFile.self, from: jsonData!)
            return administration
        } catch {
            print("Unexpected error during parsing an administration GeoJSON file: \(error)")
            return nil
        }
    }
    
    func parseGridFile(from fileURL: URL) -> GridFile? {
        do {
            let jsonData = try String(contentsOf: fileURL, encoding: .utf8).data(using: .utf8)
            let decoder = JSONDecoder()
            let grid = try decoder.decode(GridFile.self, from: jsonData!)
            return grid
        } catch {
            print("Unexpected error during parsing a grid GeoJSON file: \(error)")
            return nil
        }
    }
    
}
