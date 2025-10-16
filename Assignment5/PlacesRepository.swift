//
//  PlacesRepository.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import Foundation
import Foundation

class PlacesRepository {
    private let savePath = FileHelper.documentsDirectory.appendingPathComponent("places.json")
    
    func loadPlaces() -> [Place] {
        do {
            let data = try Data(contentsOf: savePath)
            let loadedPlaces = try JSONDecoder().decode([Place].self, from: data)
            print("✅ Loaded \(loadedPlaces.count) places")
            return loadedPlaces
        } catch {
            print("⚠️ No saved places found. Loading sample places.")
            return samplePlaces
        }
    }
    
    func savePlaces(_ places: [Place]) {
        do {
            let data = try JSONEncoder().encode(places)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("❌ Failed to save places: \(error.localizedDescription)")
        }
    }
}
