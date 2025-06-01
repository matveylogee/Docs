//
//  TokenResponse.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

struct TokenResponse: Decodable {
    let id: UUID
    let value: String
    let user: UserID
}

struct UserID: Decodable {
    let id: UUID
}
