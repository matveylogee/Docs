//
//  PDFAddPhotoText.swift
//  generator
//
//  Created by Матвей on 17.03.2024.
//

import UIKit
import PDFKit

extension PDFCreator {
    
    func addPhotoText(originPoint: CGPoint, text: String, image: UIImage) -> CGPoint {
        
        let imagePoint = addImage(originPoint: originPoint,
                                  image: image,
                                  size: 20)
        
        let textPoint = addText(originPoint: CGPoint(x: imagePoint.maxX + 5, y: originPoint.y),
                                text: text,
                                type: .regular,
                                size: 10,
                                color: .black)
        
        return CGPoint(x: textPoint.maxX,
                       y: textPoint.minY)
    }
}
