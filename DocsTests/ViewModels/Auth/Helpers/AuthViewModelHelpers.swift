import XCTest
@testable import Docs

// MARK: - Мок для NetworkServiceProtocol
final class NetworkServiceMock: NetworkServiceProtocol {
    
    var nextTokenResponse: TokenResponse?
    var nextError: Error?

    func request<Req: Encodable, Res: Decodable>(endpoint: Endpoint, requestDTO: Req) async throws -> Res {
        if let error = nextError { throw error }
        if let tokenResp = nextTokenResponse as? Res {
            return tokenResp
        }

        fatalError("NetworkServiceMock: unexpected return type \(Res.self)")
    }

    func uploadDocument(fileURL: URL, metadata: CreateDocumentRequest) async throws -> DocumentDTO {
        fatalError("Not used")
    }
    func listDocuments() async throws -> [DocumentDTO] {
        fatalError("Not used")
    }
    func getDocument(id: UUID) async throws -> DocumentDTO {
        fatalError("Not used")
    }
    func updateDocument(id: UUID, update: UpdateDocumentRequest) async throws -> DocumentDTO {
        fatalError("Not used")
    }
    func deleteDocument(id: UUID) async throws {
        fatalError("Not used")
    }
    func deleteAllDocuments() async throws {
        fatalError("Not used")
    }
    func downloadDocument(id: UUID) async throws -> URL {
        fatalError("Not used")
    }
}

// MARK: - Мок для TokenProviderProtocol
final class TokenProviderVMMock: TokenProviderProtocol {
    
    private(set) var token: String?

    func save(token: String) {
        self.token = token
    }
}

// MARK: - Мок для KeychainServiceProtocol
final class KeychainServiceMock: KeychainServiceProtocol {
    
    private var storage: [KeychainKey: String] = [:]
    var nextError: Error?

    func save(_ value: String, for key: KeychainKey) throws {
        if let err = nextError {
            throw err
        }
        storage[key] = value
    }

    func fetch(_ key: KeychainKey) throws -> String? {
        if let err = nextError {
            throw err
        }
        return storage[key]
    }

    func delete(_ key: KeychainKey) throws {
        if let err = nextError {
            throw err
        }
        storage.removeValue(forKey: key)
    }
}
