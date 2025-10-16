//
//  Place.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import Foundation
import CoreLocation

struct Place: Identifiable, Codable, Hashable {
    var id = UUID()
        var name: String
        var description: String
        var location: String
        var imagePath: String? = nil
        var latitude: Double? = nil
        var longitude: Double? = nil
}
