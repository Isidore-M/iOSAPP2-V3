//
//  PDFReportGenerator.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import UIKit
import PDFKit

class PDFReportGenerator {
    static func generatePDF(from places: [Place], completion: @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
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
                            let imageRect = CGRect(x: margin, y: yPosition, width: imageWidth, height: imageHeight)
                            uiImage.draw(in: imageRect)
                            yPosition += imageHeight + 12
                        }
                        
                        // Draw text
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
                        """
                        
                        let textRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: pageHeight - yPosition - margin)
                        descriptionText.draw(in: textRect, withAttributes: attrs)
                    }
                })
                DispatchQueue.main.async {
                    completion(pdfURL)
                }
            } catch {
                print("❌ Could not create PDF file: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
