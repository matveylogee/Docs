//
//  UserPublic.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

struct UserPublic: Decodable {
    let id: UUID
    let username: String
    let email: String
}
