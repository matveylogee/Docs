//
//  UserEndpoint.swift
//  generator
//
//  Created by Матвей on 27.05.2025.
//

import Foundation
enum UserEndpoint: Endpoint {
    case me
    case update(request: UpdateUserDTO)

    var baseURL: URL? { URL(string: "http://127.0.0.1:8080") }

    var path: String {
        switch self {
        case .me:      return "/api/v1/users/me"
        case .update:  return "/api/v1/users"
        }
    }

    var method: String {
        switch self {
        case .me:      return HTTPMethod.get
        case .update:  return HTTPMethod.put
        }
    }

    var headers: [String: String]? {
        switch self {
        case .me:
            return nil
        case .update:
            return ["Content-Type": "application/json"]
        }
    }

    func encodedBody() throws -> Data? {
        switch self {
        case .me:
            return nil
        case .update(let dto):
            return try JSONEncoder().encode(dto)
        }
    }
}
