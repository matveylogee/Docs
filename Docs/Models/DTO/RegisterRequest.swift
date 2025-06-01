//
//  RegisterRequest.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

struct RegisterRequest: Encodable {
    let username: String
    let email: String
    let password: String
}
