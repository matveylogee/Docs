import XCTest
@testable import Docs

// MARK: - Мок для NetworkServiceProtocol, специфичный для LibraryViewModel
final class LibraryNetworkMock: NetworkServiceProtocol {
    /// Входные данные для listDocuments()
    var nextDocuments: [DocumentDTO]?
    var nextListError: Error?

    /// Входная ошибка для deleteDocument(id:)
    var nextDeleteError: Error?

    /// Входные данные/ошибка для updateDocument(id:update:)
    var nextUpdatedDocument: DocumentDTO?
    var nextUpdateError: Error?

    func listDocuments() async throws -> [DocumentDTO] {
        if let err = nextListError {
            throw err
        }
        return nextDocuments ?? []
    }

    func deleteDocument(id: UUID) async throws {
        if let err = nextDeleteError {
            throw err
        }
    }

    func updateDocument(id: UUID, update: UpdateDocumentRequest) async throws -> DocumentDTO {
        if let err = nextUpdateError {
            throw err
        }
        if let dto = nextUpdatedDocument {
            return dto
        }
        fatalError("LibraryNetworkMock: nextUpdatedDocument must be set before calling updateDocument")
    }

    func request<Req: Encodable, Res: Decodable>(endpoint: Endpoint, requestDTO: Req) async throws -> Res {
        fatalError("Not used by LibraryViewModel")
    }
    
    func uploadDocument(fileURL: URL, metadata: CreateDocumentRequest) async throws -> DocumentDTO {
        fatalError("Not used by LibraryViewModel")
    }
    
    func getDocument(id: UUID) async throws -> DocumentDTO {
        fatalError("Not used by LibraryViewModel")
    }
    
    func deleteAllDocuments() async throws {
        fatalError("Not used by LibraryViewModel")
    }
    
    func downloadDocument(id: UUID) async throws -> URL {
        fatalError("Not used by LibraryViewModel")
    }
}

// MARK: - Мок для CurrentDateProtocol
final class LibraryCurrentDateMock: CurrentDateProtocol {
    func pdfCreateData() -> String { return "" }
    func pdfCreateTimestamp() -> String { return "" }
    func pdfDisplayDate(from dateTimeString: String) -> String { return "" }
}
