//
//  PDFKitView.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import SwiftUI
import PDFKit
import UIKit

// MARK: - PDFKitView
struct PDFKitView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss
    
    @State private var showDocumentPicker = false
    @State private var showSavedAlert = false
    
    var body: some View {
        NavigationView {
            PDFKitRepresentedView(url: url)
                .navigationBarTitle("PDF Report", displayMode: .inline)
                .toolbar {
                    // Left: Save Report
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Save Report") {
                            showDocumentPicker = true
                        }
                    }
                    // Right: Dismiss
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Dismiss") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showDocumentPicker) {
                    PDFDocumentPicker(url: url) {
                        showSavedAlert = true
                        showDocumentPicker = false
                    }
                }
                .alert("PDF Saved", isPresented: $showSavedAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Your PDF report has been saved to Files.")
                }
        }
    }
}

// MARK: - PDFKitRepresentedView
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
        pdfView.isUserInteractionEnabled = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - PDFDocumentPicker
struct PDFDocumentPicker: UIViewControllerRepresentable {
    let url: URL
    var completion: (() -> Void)? = nil
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [url])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var completion: (() -> Void)?
        
        init(completion: (() -> Void)?) {
            self.completion = completion
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            completion?()
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            completion?()
        }
    }
}
