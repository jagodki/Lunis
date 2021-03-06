//
//  DecoderStructs.swift
//  Lunis
//
//  Created by Christoph on 03.05.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

// MARK: - structs for the schools GeoJSON-files

struct SchoolFile: Codable {
    let type: String
    let name: String
    let crs: String
    let features: [SchoolFeature]
}

struct SchoolFeature: Codable {
    let type: String
    let properties: SchoolProperties
    let geometry: PointGeometry
}

struct SchoolProperties: Codable {
    let id: Int
    let name: String
    let school_address: String
    let agency: String
    let school_type: String
    let school_specialisations: String
    let website: String
    let wikipedia: String
    let mail: String
    let telefon: String
}

// MARK: - structs for the administration GeoJSON-files

struct AdministrationFile: Codable {
    let type: String
    let name: String
    let crs: String
    let features: [AdministrationFeature]
}

struct AdministrationFeature: Codable {
    let type: String
    let properties: AdministrationProperties
    let geometry: PolygonGeometry
}

struct AdministrationProperties: Codable {
    let id: Int
    let city: String
    let country: String
    let region: String
    let source: String
    let last_update: String
    let x: Double
    let y: Double
}

// MARK: - structs for the grid GeoJSON-file

struct GridFile: Codable {
    let type: String
    let name: String
    let crs: String
    let features: [GridFeature]
}

struct GridFeature: Codable {
    let type: String
    let properties: GridProperties
    let geometry: PolygonGeometry
}

struct GridProperties: Codable {
    let school_ids: [String]
    let cell_values: [Double]
}

// MARK: - geometries

struct PolygonGeometry: Codable {
    let type: String
    let coordinates: [[[Double]]]
}

struct PointGeometry: Codable {
    let type: String
    let coordinates: [Double]
}

// MARK: - additional structs
//struct CrsStruct: Codable {
//    let type: String
//    let properties: CrsProperties
//}
//
//struct CrsProperties: Codable {
//    let name: String
//}
