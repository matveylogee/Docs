//
//  DocumentEndpoint.swift
//  generator
//
//  Created by Матвей on 25.05.2025.
//

import Foundation

enum DocumentEndpoint: Endpoint {
    case list
    case get(id: UUID)
    case download(id: UUID)
    case upload
    case update(id: UUID, request: UpdateDocumentRequest)
    case delete(id: UUID)
    case deleteAll

    var baseURL: URL? { URL(string: "http://127.0.0.1:8080") }
    
    var path: String {
        switch self {
        case .list, .upload, .deleteAll:
            return "/api/v1/documents"
        case .get(let id), .update(let id, _), .delete(let id):
            return "/api/v1/documents/\(id.uuidString)"
        case .download(let id):
            return "/api/v1/documents/\(id.uuidString)/download"
        }
    }
    
    var method: String {
        switch self {
        case .list, .get, .download: return HTTPMethod.get
        case .upload:                return HTTPMethod.post
        case .update:                return HTTPMethod.put
        case .delete, .deleteAll:    return HTTPMethod.delete
        }
    }
    
    var headers: [String:String]? {
        switch self {
        case .update:
            return ["Content-Type":"application/json"]
        case .upload:
            return nil // multipart сам поставит Content-Type
        default:
            return nil
        }
    }

    func encodedBody() throws -> Data? {
        switch self {
        case .update(_, let req):
            return try JSONEncoder().encode(req)
        default:
            return nil
        }
    }
}
