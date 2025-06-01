//
//  PDFCreator.swift
//  generator
//
//  Created by Матвей on 15.03.2024.
//

import UIKit
import PDFKit

final class PDFCreator {
    let producerName: String
    let name: String
    let nickname: String
    let composition: String
    let price: String
    let experience: DocumentType
    
    var currentPageRect = CGRect()
    
    init(producerName: String, name: String, nickname: String, composition: String, price: String, experience: DocumentType) {
        self.producerName = producerName
        self.name = name
        self.nickname = nickname
        self.composition = composition
        self.price = price
        self.experience = experience
    }
}

extension PDFCreator {
    
    public func pdfCreateData(fileName: String) -> Data {
        
        let pdfMetaData = [
            kCGPDFContextCreator: "logee",
            kCGPDFContextAuthor: "Borodin Matvey",
            kCGPDFContextTitle: fileName]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String : Any]
        
        let pageWidth = 8.5 * 72
        let pageHeight = 11.0 * 72
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        currentPageRect = pageRect
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            pdfCreateLicense(context: context.cgContext)
        }
        
        return data
    }
}
