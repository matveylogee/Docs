//
//  PDFAddImage.swift
//  generator
//
//  Created by Матвей on 17.03.2024.
//

import UIKit

extension PDFCreator {
    
    func addImage(originPoint: CGPoint, image: UIImage, size: CGFloat) -> CGRect {
        
        let aspectWidth = size / image.size.width
        let aspectHeight = size / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        let scaleWidth = image.size.width * aspectRatio
        let scaleHeight = image.size.height * aspectRatio
        
        let imageRect = CGRect(x: originPoint.x,
                               y: originPoint.y,
                               width: scaleWidth,
                               height: scaleHeight)
        
        image.draw(in: imageRect)
        
        return imageRect
    }
}
