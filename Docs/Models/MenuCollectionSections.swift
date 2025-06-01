//
//  MenuCollectionSections.swift
//  generator
//
//  Created by Матвей on 18.03.2025.
//

import Foundation

enum SetionType {
    case mainLicense, banner
    
    var title: String {
        switch self {
        case .mainLicense:
            return "Main Licences"
        case .banner:
            return "Information"
        }
    }
}

struct MenuCollectionSections {
    let type: SetionType
    let item: [CollectionItem]
    
    static func mockData() -> [MenuCollectionSections] {
        let mainLicenseItems: [CollectionItem] = [
            CollectionItem(image: "info.circle.fill", header: "Mp3", type: .mp3, description: "Leasing" ),
            CollectionItem(image: "info.circle.fill", header: "Wav", type: .wav, description: "Leasing"),
            CollectionItem(image: "ellipsis", header: "Trackout", type: .trackout, description: "Leasing"),
            CollectionItem(image: "ellipsis.circle", header: "Exсlusive", type: .exclusive, description: "Timeless"),
        ]
        
        let bannerItems: [CollectionItem] = [
            CollectionItem(image: "banner", header: "General information on license agreements", type: .exclusive, description: "A music license agreement is between the Licensor and the Licensee regarding copyright and publishing rights. Use this template to outline yours.")
        ]
        
        return [
            MenuCollectionSections(type: .mainLicense, item: mainLicenseItems),
            MenuCollectionSections(type: .banner, item: bannerItems)
        ]
    }
}

struct CollectionItem {
    let image: String
    var header: String? = nil
    let type: DocumentType
    var description: String? = nil
}
