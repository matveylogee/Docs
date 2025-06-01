//
//  AuthEndpoint.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

enum AuthEndpoint: Endpoint {
    case register(request: RegisterRequest)
    case login(email: String, password: String)

    var baseURL: URL? { URL(string: "http://127.0.0.1:8080") }
    
    var path: String {
        switch self {
        case .register: return "/api/v1/auth/register"
        case .login:    return "/api/v1/auth/login"
        }
    }
    
    var method: String { HTTPMethod.post }
    
    var headers: [String: String]? {
        switch self {
        case .register:
            return ["Content-Type": "application/json"]
        case .login(let email, let pass):
            let cred = "\(email):\(pass)"
            let b64  = Data(cred.utf8).base64EncodedString()
            return ["Authorization": "Basic \(b64)"]
        }
    }

    func encodedBody() throws -> Data? {
        switch self {
        case .register(let req):
            return try JSONEncoder().encode(req)
        case .login:
            return nil
        }
    }
}
