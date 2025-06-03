//
//  NetworkService.swift
//  generator
//
//  Created by Матвей on 24.05.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<Req: Encodable, Res: Decodable>(endpoint: Endpoint, requestDTO: Req) async throws -> Res

    func uploadDocument(fileURL: URL, metadata: CreateDocumentRequest) async throws -> DocumentDTO
    func listDocuments() async throws -> [DocumentDTO]
    func getDocument(id: UUID) async throws -> DocumentDTO
    
    func updateDocument(id: UUID, update: UpdateDocumentRequest) async throws -> DocumentDTO
    func deleteDocument(id: UUID) async throws
    func deleteAllDocuments() async throws
    func downloadDocument(id: UUID) async throws -> URL
}

final class NetworkService: NetworkServiceProtocol {
    
    private let session: URLSessionProtocol
    private let tokenProvider: TokenProviderProtocol

    init(session: URLSessionProtocol = URLSession.shared,
         tokenProvider: TokenProviderProtocol
    ) {
        self.session = session
        self.tokenProvider = tokenProvider
    }

    // MARK: - Generic Request
    func request<Req: Encodable, Res: Decodable>(endpoint: Endpoint, requestDTO: Req) async throws -> Res {
        /// строим URL
        guard let base = endpoint.baseURL else { throw NetworkError.invalidURL }
        
        var comps = URLComponents(url: base, resolvingAgainstBaseURL: false)
        comps?.path = endpoint.path
        guard let url = comps?.url else { throw NetworkError.invalidURL }

        /// настраиваем URLRequest
        var req = URLRequest(url: url)
        req.httpMethod = endpoint.method

        /// заголовки эндпоинта
        endpoint.headers?.forEach { key, val in
            req.setValue(val, forHTTPHeaderField: key)
        }
        /// подмешиваем токен
        if let token = tokenProvider.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        /// тело запроса (если endpoint.encodedBody() возвращает non‐nil)
        if let body = try endpoint.encodedBody() {
            req.httpBody = body
        }

        /// отправляем и проверяем статус
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        guard (200..<300).contains(http.statusCode) else {
            if let apiErr = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw NetworkError.serverError(status: http.statusCode, message: apiErr.reason)
            }
            throw NetworkError.serverError(
                status: http.statusCode,
                message: String(data: data, encoding: .utf8) ?? "Unknown error"
            )
        }

        /// декодируем тело
        do {
            return try JSONDecoder().decode(Res.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    // MARK: - Upload Document (multipart/form-data)
    func uploadDocument(fileURL: URL, metadata: CreateDocumentRequest) async throws -> DocumentDTO {
        guard let base = DocumentEndpoint.upload.baseURL else { throw NetworkError.invalidURL }
        var comps = URLComponents(url: base, resolvingAgainstBaseURL: false)!
        comps.path = DocumentEndpoint.upload.path
        var req = URLRequest(url: comps.url!)
        req.httpMethod = DocumentEndpoint.upload.method

        // авторизация
        if let token = tokenProvider.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // multipart boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // собрать тело
        var body = Data()
        let filename = fileURL.lastPathComponent
        let fileData = try Data(contentsOf: fileURL)

        // 1) PDF‐часть
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: application/pdf\r\n\r\n")
        body.append(fileData)
        body.appendString("\r\n")

        // 2) JSON‐метаданные
        let jsonData = try JSONEncoder().encode(metadata)
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"data\"; filename=\"data.json\"\r\n")
        body.appendString("Content-Type: application/json\r\n\r\n")
        body.append(jsonData)
        body.appendString("\r\n--\(boundary)--\r\n")

        req.httpBody = body

        // отправка и чтение ответа
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NetworkError.serverError(
                status: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                message: String(data: data, encoding: .utf8) ?? "Unknown"
            )
        }
        return try JSONDecoder().decode(DocumentDTO.self, from: data)
    }
    
    // MARK: - Get List of Documents
    func listDocuments() async throws -> [DocumentDTO] {
        try await request(endpoint: DocumentEndpoint.list, requestDTO: EmptyRequest())
    }

    // MARK: - Get One Document (metadata)
    func getDocument(id: UUID) async throws -> DocumentDTO {
        try await request(endpoint: DocumentEndpoint.get(id: id), requestDTO: EmptyRequest())
    }

    // MARK: - Update Comment / isFavorite
    func updateDocument(id: UUID, update: UpdateDocumentRequest) async throws -> DocumentDTO {
        try await request(endpoint: DocumentEndpoint.update(id: id, request: update), requestDTO: update)
    }

    // MARK: - Delete One Document
    func deleteDocument(id: UUID) async throws {
        // 1) build URL
        guard let base = DocumentEndpoint.delete(id: id).baseURL else {
            throw NetworkError.invalidURL
        }
        var comps = URLComponents(url: base, resolvingAgainstBaseURL: false)!
        comps.path = DocumentEndpoint.delete(id: id).path
        
        // 2) configure request
        var req = URLRequest(url: comps.url!)
        req.httpMethod = DocumentEndpoint.delete(id: id).method
        if let token = tokenProvider.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 3) fire & validate
        let (_, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NetworkError.serverError(
                status: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                message: "Failed to delete document"
            )
        }
    }

    // MARK: - Delete All Documents
    func deleteAllDocuments() async throws {
        guard let base = DocumentEndpoint.deleteAll.baseURL else {
            throw NetworkError.invalidURL
        }
        var comps = URLComponents(url: base, resolvingAgainstBaseURL: false)!
        comps.path = DocumentEndpoint.deleteAll.path
        
        var req = URLRequest(url: comps.url!)
        req.httpMethod = DocumentEndpoint.deleteAll.method
        if let token = tokenProvider.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NetworkError.serverError(
                status: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                message: "Failed to delete all documents"
            )
        }
    }

    // MARK: - Download PDF-Fail (return URL of local-fail)
    func downloadDocument(id: UUID) async throws -> URL {
        guard let base = DocumentEndpoint.download(id: id).baseURL else {
            throw NetworkError.invalidURL
        }
        var comps = URLComponents(url: base, resolvingAgainstBaseURL: false)!
        comps.path = DocumentEndpoint.download(id: id).path

        var req = URLRequest(url: comps.url!)
        req.httpMethod = DocumentEndpoint.download(id: id).method
        if let token = tokenProvider.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (fileURL, _) = try await session.download(for: req)
        return fileURL
    }
}

private extension Data {
    mutating func appendString(_ str: String) {
        append(Data(str.utf8))
    }
}
