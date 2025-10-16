//
//  FileHelper.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import Foundation
import UIKit  // Needed for UIImage

struct FileHelper {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func saveImage(_ image: UIImage, withName name: String) throws -> String {
        let url = documentsDirectory.appendingPathComponent(name)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageSaveError", code: 1, userInfo: nil)
        }
        
        // Specify the options explicitly as Data.WritingOptions
        try data.write(to: url, options: [.atomicWrite, .completeFileProtection])
        return url.path
    }
}
