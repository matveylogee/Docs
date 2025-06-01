//
//  APIErrorResponse.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

struct APIErrorResponse: Decodable {
    let error: Bool
    let reason: String
}
