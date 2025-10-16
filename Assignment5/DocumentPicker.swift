//
//  DocumentPicker.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-16.
//

import SwiftUI
import UIKit

struct DocumentPicker: UIViewControllerRepresentable {
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
