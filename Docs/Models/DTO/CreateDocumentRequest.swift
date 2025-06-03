//
//  CreateDocumentRequest.swift
//  generator
//
//  Created by Матвей on 25.05.2025.
//

import Foundation

struct CreateDocumentRequest: Codable {
    let fileType: String
    let createTime: String     
    let artistName: String
    let artistNickname: String
    let compositionName: String
    let price: String
    let comment: String?
    let isFavorite: Bool?
}
