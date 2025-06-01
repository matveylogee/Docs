//
//  PDFAddLine.swift
//  generator
//
//  Created by Матвей on 17.03.2024.
//

import UIKit
import UIKit

extension PDFCreator {
    
    func addLine(originPoint: CGPoint, drawContext: CGContext) {
        
        drawContext.saveGState()
        
        drawContext.setStrokeColor(UIColor.black.cgColor)
        drawContext.setAlpha(0.5)
        
        drawContext.move(to: originPoint)
        drawContext.addLine(to: CGPoint(x: currentPageRect.width / 3 - originPoint.x * 2,
                                        y: originPoint.y))
        drawContext.strokePath()
        drawContext.restoreGState()
    }
}

