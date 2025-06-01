//
//  NetworkError.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case serverError(status: Int, message: String?)
    case decodingError
    case unknown
}
