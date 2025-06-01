//
//  PDFCreateSignature.swift
//  generator
//
//  Created by Матвей on 25.03.2024.
//

import UIKit
import PDFKit

extension PDFCreator {
    
    func pdfCreateSignature(originPoint: CGPoint, context: CGContext, title: String, description: String, data: String) -> CGRect {
        
        let titlePoint = addText(originPoint: originPoint,
                                 text: title,
                                 type: .regular,
                                 size: 10,
                                 color: .black)
        
        _ = addText(originPoint: CGPoint(x: titlePoint.maxX + 120, y: titlePoint.minY + 20),
                                 text: "Дата: " + data,
                                 type: .regular,
                                 size: 10,
                                 color: .black)
        
        let descriptionPoint = addText(originPoint: CGPoint(x: titlePoint.minX, y: titlePoint.maxY + 25),
                                       text: description,
                                       type: .regular,
                                       size: 10,
                                       color: .black)
        
        return descriptionPoint
    }
}
