//
//  PlacesViewModel.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import SwiftUI
import UIKit
import PDFKit
import CoreLocation
import ImageIO

class PlacesViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var generatedPDFURL: URL? = nil

    private let savePath: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("places.json")
    }()

    init() {
        loadPlaces()
        if places.isEmpty {
            places = samplePlaces
            savePlaces()
        }
    }

    // MARK: - Load / Save Places
    func savePlaces() {
        do {
            let data = try JSONEncoder().encode(places)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("❌ Failed to save places: \(error.localizedDescription)")
        }
    }

    func loadPlaces() {
        do {
            let data = try Data(contentsOf: savePath)
            places = try JSONDecoder().decode([Place].self, from: data)
        } catch {
            places = []
            print("⚠️ No saved places found. Loading sample places.")
        }
    }

    // MARK: - Update Image
    func updateImage(for placeID: UUID, image: UIImage) {
        guard let index = places.firstIndex(where: { $0.id == placeID }) else { return }
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent("\(placeID).jpg")
            do {
                try data.write(to: filename)
                places[index].imagePath = filename.path
                savePlaces()
                print("✅ Image saved for place \(places[index].name)")
            } catch {
                print("❌ Failed to save image: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - PDF Generation
    func generatePDFReport() {
        let pdfMetaData = [
            kCGPDFContextCreator: "Places App",
            kCGPDFContextAuthor: "Eezy",
            kCGPDFContextTitle: "Places Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let fileName = "PlacesReport.pdf"
        let pdfURL = getDocumentsDirectory().appendingPathComponent(fileName)

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        do {
            try renderer.writePDF(to: pdfURL, withActions: { context in
                var placeCounter = 0
                for place in places {
                    if placeCounter % 2 == 0 { context.beginPage() }
                    let yOffset = (placeCounter % 2 == 0) ? 50 : (pageHeight / 2) + 20
                    var yPosition = yOffset

                    if let path = place.imagePath,
                       let uiImage = UIImage(contentsOfFile: path) {
                        let imageRect = CGRect(x: 72, y: yPosition, width: pageWidth - 144, height: 150)
                        uiImage.draw(in: imageRect)
                        yPosition += 160
                    }

                    // GPS from Place model
                    let gpsText: String
                    if let lat = place.latitude, let lon = place.longitude {
                        gpsText = String(format: "Latitude: %.6f\nLongitude: %.6f", lat, lon)
                    } else {
                        gpsText = "Latitude: -\nLongitude: -"
                    }

                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .left
                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 14),
                        .paragraphStyle: paragraphStyle
                    ]

                    let descriptionText = """
                    Name: \(place.name)
                    Location: \(place.location)
                    Description: \(place.description)
                    \(gpsText)
                    """
                    descriptionText.draw(in: CGRect(x: 72, y: yPosition, width: pageWidth - 144, height: 200), withAttributes: attrs)
                    placeCounter += 1
                }
            })
            generatedPDFURL = pdfURL
            print("✅ PDF saved at: \(pdfURL.path)")
        } catch {
            print("❌ Could not create PDF file: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func getLocationFromImage(at path: String) -> CLLocationCoordinate2D? {
        let imageURL = URL(fileURLWithPath: path)
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
              let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
              let gps = metadata[kCGImagePropertyGPSDictionary] as? [CFString: Any],
              let latitude = gps[kCGImagePropertyGPSLatitude] as? Double,
              let latitudeRef = gps[kCGImagePropertyGPSLatitudeRef] as? String,
              let longitude = gps[kCGImagePropertyGPSLongitude] as? Double,
              let longitudeRef = gps[kCGImagePropertyGPSLongitudeRef] as? String
        else { return nil }

        let lat = latitudeRef == "S" ? -latitude : latitude
        let lon = longitudeRef == "W" ? -longitude : longitude
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
