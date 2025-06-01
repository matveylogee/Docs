//
//  PDFFileManager.swift
//  generator
//
//  Created by Матвей on 28.03.2024.
//

import UIKit

extension FileManager {
    static var pdfLibraryURL: URL {
        let docs = Self.default.urls(for: .documentDirectory,
                                     in: .userDomainMask).first!
        let dir  = docs.appendingPathComponent("PDFLibrary", isDirectory: true)
        try? Self.default.createDirectory(at: dir,
                                          withIntermediateDirectories: true)
        return dir
    }
}
