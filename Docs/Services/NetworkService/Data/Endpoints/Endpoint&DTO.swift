//
//  Endpoint&DTO.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

protocol Endpoint {
    var baseURL: URL? { get }
    var path:    String { get }
    var method:  String { get }
    var headers: [String:String]? { get }
    
    /// Данные для тела запроса (JSON или multipart и т.п.)
    func encodedBody() throws -> Data?
}

extension Endpoint {
    func encodedBody() throws -> Data? { nil }
}
