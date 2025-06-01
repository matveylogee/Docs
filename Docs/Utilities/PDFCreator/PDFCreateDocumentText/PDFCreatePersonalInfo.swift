//
//  PDFCreatePersonalInfo.swift
//  generator
//
//  Created by Матвей on 17.03.2024.
//

import UIKit
import PDFKit

extension PDFCreator {
    
    func pdfCreatePersonalInfo(originPoint: CGPoint) {
        
        guard let photoImage = UIImage(systemName: "phone"),
              let nicknameImage = UIImage(systemName: "envelope") else {
            return
        }
        
        let phonePoint = addPhotoText(originPoint: originPoint,
                                      text: composition,
                                      image: photoImage)
        
        _ = addPhotoText(originPoint: CGPoint(x: phonePoint.x + 20, y: phonePoint.y),
                         text: nickname,
                         image: nicknameImage)
    }
}
