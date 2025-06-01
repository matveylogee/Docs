//
//  PDFCreateInfo.swift
//  generator
//
//  Created by Матвей on 17.03.2024.
//

import UIKit
import PDFKit

extension PDFCreator {
    
    func pdfCreateInfo(originPoint: CGPoint, context: CGContext, title: String, description: String) -> CGRect {
        
        let titlePoint = addText(originPoint: originPoint,
                                 text: title,
                                 type: .bold,
                                 size: 10,
                                 color: .black)
        
        let descriptionPoint = addText(originPoint: CGPoint(x: titlePoint.minX, y: titlePoint.maxY),
                                       text: description,
                                       type: .regular,
                                       size: 10,
                                       color: .black)
        
        return descriptionPoint
    }
}
