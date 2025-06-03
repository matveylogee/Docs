//
//  DocumentDTO.swift
//  generator
//
//  Created by Матвей on 25.05.2025.
//

import Foundation

struct DocumentDTO: Codable, Hashable {
    let id: UUID
    let fileName: String
    let fileURL: String
    let fileType: String
    let createTime: String
    let comment: String?
    let isFavorite: Bool
    let artistName: String
    let artistNickname: String
    let compositionName: String
    let price: String
}
