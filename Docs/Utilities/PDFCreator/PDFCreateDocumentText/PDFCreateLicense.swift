//
//  PDFCreateLicense.swift
//  generator
//
//  Created by Матвей on 17.03.2024.
//

import UIKit
import PDFKit

extension PDFCreator {
    
    func pdfCreateLicense(context: CGContext) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        
        let expInt = experience.intValue

        guard let titleLeasing = Resources.TitleTypeOfLeasing(rawValue: expInt),
              let performanceRights = Resources.PerformanceRights(rawValue: expInt),
              let synchronizationRights = Resources.SynchronizationRights(rawValue: expInt)
        else {
            print("⚠️ Не добавлен case .exclusive в Resources-enums /(titleLeasing)")
            return
        }
        
        var originalStringConsideration = Resources.Consideration.description.rawValue
        if let range = originalStringConsideration.range(of: "(price)") {
            let modifiedString = originalStringConsideration.replacingCharacters(in: range, with: String(price))
            
            originalStringConsideration = modifiedString
        }
        
        var originalStringMechanicalRights = Resources.MechanicalRights.description.rawValue
        if let range = originalStringMechanicalRights.range(of: "(price)") {
            let modifiedString = originalStringMechanicalRights.replacingCharacters(in: range, with: String(price))
            
            originalStringMechanicalRights = modifiedString
        }
        
//        let storage: ProducerUserDefaultsProtocol = ProducerUserDefaults()
//        let producerName = storage.string(forKey: .producerName)
        
        let documementOriginPoint = CGPoint(x: 10, y: 10)
        
        let titlePoint = pdfCreateTitle(originPoint: documementOriginPoint)
        
        let masterUsePoint = pdfCreateInfo(originPoint: CGPoint(x: documementOriginPoint.x, y: titlePoint.y + 15),
                                           context: context,
                                           title: Resources.LicenceTitles.masterUse.rawValue,
                                           description: Resources.MasterUse.description.rawValue)
        
        let mechanicalRightsPoint = pdfCreateInfo(originPoint: CGPoint(x: documementOriginPoint.x, y: masterUsePoint.maxY + 15),
                                                  context: context,
                                                  title: Resources.LicenceTitles.mechanicalRights.rawValue,
                                                  description: originalStringMechanicalRights)
        
        let performanceRightsPoint = pdfCreateInfo(originPoint: CGPoint(x: documementOriginPoint.x, y: mechanicalRightsPoint.maxY + 15),
                                                   context: context,
                                                   title: Resources.LicenceTitles.performanceRights.rawValue,
                                                   description: performanceRights.description)
        
        let synchronizationRightsPoint = pdfCreateInfo(originPoint: CGPoint(x: documementOriginPoint.x, y: performanceRightsPoint.maxY + 15),
                                                       context: context,
                                                       title: Resources.LicenceTitles.synchronizationRights.rawValue,
                                                       description: synchronizationRights.description)
        
        let сonsiderationPoint = pdfCreateInfo(originPoint: CGPoint(x: documementOriginPoint.x, y: synchronizationRightsPoint.maxY + 15),
                                               context: context,
                                               title: Resources.LicenceTitles.consideration.rawValue,
                                               description: originalStringConsideration)
        
        let deliveryPoint = pdfCreateInfo(originPoint: CGPoint(x: documementOriginPoint.x, y: сonsiderationPoint.maxY + 15),
                                               context: context,
                                               title: Resources.LicenceTitles.delivery.rawValue,
                                               description: Resources.Delivery.description.rawValue)
        
        let audioSamplesPoint = pdfCreateInfo(originPoint: CGPoint(x: documementOriginPoint.x, y: deliveryPoint.maxY + 15),
                                               context: context,
                                               title: Resources.LicenceTitles.audioSamples.rawValue,
                                               description: Resources.AudioSamples.description.rawValue)
        
        let governingLawPoint = pdfCreateInfo(originPoint: CGPoint(x: documementOriginPoint.x, y: audioSamplesPoint.maxY + 15),
                                               context: context,
                                               title: Resources.LicenceTitles.governingLaw.rawValue,
                                               description: Resources.GoverningLaw.description.rawValue)
        
        // подписи
        
        _ = pdfCreateSignature(originPoint: CGPoint(x: governingLawPoint.minX, y: governingLawPoint.maxY + 15),
                                                context: context,
                                                title: "Лицензиар:",
                                                description: "\(producerName)",
                                                data: dateString)
        
        _ = pdfCreateSignature(originPoint: CGPoint(x: governingLawPoint.minX + currentPageRect.width / 2 - 20,
                                                                             y: governingLawPoint.maxY + 15),
                                                context: context,
                                                title: "Лицензиат:",
                                                description: name + " - Артист",
                                                data: "")
    }
}
