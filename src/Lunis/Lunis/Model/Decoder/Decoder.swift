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
    
    func parseSchoolFile(from fileURL: URL) -> SchoolFile {
        let jsonData = String(contentsOf: fileURL, encoding: .utf8)
        let decoder = JSONDecoder()
        do {
            let schools = decoder.decode(SchoolFile.self, from: jsonData)
            return schools
        } catch {
            print("Unexpected error during parsing a schools GeoJSON file: \(error)")
        }
        return
    }
    
    func parseAdministrationFile(from fileURL: URL) -> AdministrationFile {
        let jsonData = String(contentsOf: fileURL, encoding: .utf8)
        let decoder = JSONDecoder()
        do {
            let administration = decoder.decode(AdministrationFile.self, from: jsonData)
            return administration
        } catch {
            print("Unexpected error during parsing an administration GeoJSON file: \(error)")
        }
        return
    }
    
    func parseGridFile(from fileURL: URL) -> GridFile {
        let jsonData = String(contentsOf: fileURL, encoding: .utf8)
        let decoder = JSONDecoder()
        do {
            let grid = decoder.decode(GridFile.self, from: jsonData)
            return grid
        } catch {
            print("Unexpected error during parsing a grid GeoJSON file: \(error)")
        }
        return
    }
    
}
