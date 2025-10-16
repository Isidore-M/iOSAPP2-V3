//
//  PDFKitView.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFDocumentWrapper: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    var url: URL

    init(url: URL) { self.url = url }
    init(configuration: ReadConfiguration) throws { fatalError("Reading not supported") }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: url, options: .immediate)
    }
}

struct PDFKitView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss
    @State private var showExporter = false

    var body: some View {
        NavigationView {
            PDFKitRepresentedView(url: url)
                .navigationBarTitle("PDF Report", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Save Report") { showExporter = true }
                            .fileExporter(
                                isPresented: $showExporter,
                                document: PDFDocumentWrapper(url: url),
                                contentType: .pdf,
                                defaultFilename: "PlacesReport"
                            ) { result in
                                switch result {
                                case .success(let url):
                                    print("Saved to: \(url)")
                                case .failure(let error):
                                    print("Failed: \(error.localizedDescription)")
                                }
                            }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Dismiss") { dismiss() }
                    }
                }
        }
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.backgroundColor = .systemBackground
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
