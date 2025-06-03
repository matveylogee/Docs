import XCTest
@testable import Docs

// MARK: - Мок для NetworkServiceProtocol
final class DocumentNetworkMock: NetworkServiceProtocol {
    var nextUserPublic: UserPublic?
    var nextUploadedDocument: DocumentDTO?
    var nextError: Error?

    func request<Req: Encodable, Res: Decodable>(endpoint: Endpoint,requestDTO: Req) async throws -> Res {
        if let error = nextError { throw error }
        if let user = nextUserPublic as? Res {
            return user
        }
        fatalError("DocumentNetworkMock: unexpected return type \(Res.self)")
    }

    func uploadDocument(fileURL: URL, metadata: CreateDocumentRequest) async throws -> DocumentDTO {
        if let error = nextError {
            throw error
        }
        if let dto = nextUploadedDocument {
            return dto
        }
        fatalError("DocumentNetworkMock: nextUploadedDocument not set")
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

// MARK: - Мок для CurrentDateProtocol
final class CurrentDateMock: CurrentDateProtocol {

    private let fixedTimestamp: String

    init(_ fixedTimestamp: String) {
        self.fixedTimestamp = fixedTimestamp
    }

    func pdfCreateData() -> String {
        return ""
    }

    func pdfCreateTimestamp() -> String {
        return fixedTimestamp
    }

    func pdfDisplayDate(from dateTimeString: String) -> String {
        return dateTimeString
    }
}
