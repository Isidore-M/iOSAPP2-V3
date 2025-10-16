//
//  PlacesViewModel.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import SwiftUI
import UIKit
import PDFKit

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
    
    // MARK: - Save / Load Places
    
    func savePlaces() {
        do {
            let data = try JSONEncoder().encode(places)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
            print("✅ Places saved")
        } catch {
            print("❌ Failed to save places: \(error.localizedDescription)")
        }
    }
    
    func loadPlaces() {
        do {
            let data = try Data(contentsOf: savePath)
            places = try JSONDecoder().decode([Place].self, from: data)
            print("✅ Loaded \(places.count) places")
        } catch {
            places = []
            print("⚠️ No saved places found. Loading sample places.")
        }
    }
    
    // MARK: - Image Handling
    
    func updateImage(for place: Place, image: UIImage) {
        guard let index = places.firstIndex(where: { $0.id == place.id }) else { return }
        do {
            let path = try FileHelper.saveImage(image, withName: "\(place.id).jpg")
            places[index].imagePath = path
            savePlaces()
            print("✅ Image saved for place \(places[index].name)")
        } catch {
            print("❌ Failed to save image: \(error.localizedDescription)")
        }
    }
    
    func removeImage(for place: Place) {
        guard let index = places.firstIndex(where: { $0.id == place.id }) else { return }
        places[index].imagePath = nil
        savePlaces()
        print("🗑 Image removed for place \(places[index].name)")
    }
    
    // MARK: - PDF Generation
    
    func generatePDF() {
        let pdfMetaData = [
            kCGPDFContextCreator: "Places App",
            kCGPDFContextAuthor: "Eezy",
            kCGPDFContextTitle: "Places Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let fileName = "PlacesReport.pdf"
        let pdfURL = FileHelper.documentsDirectory.appendingPathComponent(fileName)
        
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 72
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        do {
            try renderer.writePDF(to: pdfURL, withActions: { context in
                for place in places {
                    context.beginPage()
                    var yPosition: CGFloat = margin
                    
                    // Draw image if exists
                    if let path = place.imagePath,
                       let uiImage = UIImage(contentsOfFile: path) {
                        let maxImageHeight: CGFloat = 200
                        let aspectRatio = uiImage.size.width / uiImage.size.height
                        let imageWidth = min(pageWidth - 2 * margin, maxImageHeight * aspectRatio)
                        let imageHeight = min(maxImageHeight, maxImageHeight / aspectRatio)
                        let imageRect = CGRect(x: (pageWidth - imageWidth)/2, y: yPosition, width: imageWidth, height: imageHeight)
                        uiImage.draw(in: imageRect)
                        yPosition += imageHeight + 12
                    }
                    
                    // Draw text
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .left
                    paragraphStyle.lineBreakMode = .byWordWrapping
                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 14),
                        .paragraphStyle: paragraphStyle
                    ]
                    
                    let descriptionText = """
                    Name: \(place.name)
                    Location: \(place.location)
                    
                    Description:
                    \(place.description)
                    """
                    
                    let textRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: pageHeight - yPosition - margin)
                    descriptionText.draw(in: textRect, withAttributes: attrs)
                }
            })
            
            generatedPDFURL = pdfURL
            print("✅ PDF saved at: \(pdfURL.path)")
            
        } catch {
            print("❌ Could not create PDF: \(error.localizedDescription)")
        }
    }
    
}
