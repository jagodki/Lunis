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
    let features: [SchoolFeature]
}

struct SchoolFeature: Codable {
    let type: String
    let properties: SchoolProperties
    let geometry: PointGeometry
}

struct SchoolProperties: Codable {
    let name: String
    let address: String
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
    let features: [AdministrationFeatures]
}

struct AdministrationFeatures: Codable {
    let type: String
    let properties: AdministrationProperties
    let geometry: PolygonGeometry
}

struct AdministrationProperties: Codable {
    let city: String
    let country: String
    let region: String
    let source: String
    let last_update: Date
    let x: Double
    let y: Double
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
