import XCTest
@testable import Docs

final class NetworkServiceDocumentCRUDTests: XCTestCase {

    /// 8) Проверка listDocuments (GET /documents) «хэппи-пасс»
    func testListDocuments_Successful200_ReturnsArrayOfDocumentDTO() async throws {
        // Arrange
        let doc1 = DocumentDTO(
            id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!,
            fileName:        "Doc1.pdf",
            fileURL:         "https://example.com/files/Doc1.pdf",
            fileType:        "pdf",
            createTime:      "2025-06-03T00:00:00Z",
            comment:         nil,
            isFavorite:      false,
            artistName:      "Artist1",
            artistNickname:  "Nick1",
            compositionName: "Comp1",
            price:           "10"
        )
        let doc2 = DocumentDTO(
            id: UUID(uuidString: "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF")!,
            fileName:        "Doc2.pdf",
            fileURL:         "https://example.com/files/Doc2.pdf",
            fileType:        "pdf",
            createTime:      "2025-06-04T00:00:00Z",
            comment:         "Note",
            isFavorite:      true,
            artistName:      "Artist2",
            artistNickname:  "Nick2",
            compositionName: "Comp2",
            price:           "20"
        )
        let docsArray = [doc1, doc2]
        let jsonData = try JSONEncoder().encode(docsArray)

        // Реальный URL для DocumentEndpoint.list
        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextData = jsonData
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: "token123")
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        // Act
        let returnedDocs: [DocumentDTO] = try await service.listDocuments()

        // Assert
        XCTAssertEqual(returnedDocs, docsArray)

        let lastReq = sessionMock.lastRequest!
        XCTAssertEqual(lastReq.httpMethod, "GET")
        XCTAssertEqual(
            lastReq.url?.absoluteString,
            "http://127.0.0.1:8080/api/v1/documents"
        )
        XCTAssertEqual(
            lastReq.value(forHTTPHeaderField: "Authorization"),
            "Bearer token123"
        )
    }

    /// 9) Проверка listDocuments при ошибке (например, 500) → throws serverError
    func testListDocuments_Status500_ThrowsServerError() async throws {
        // Arrange
        let errorMessage = "Server down"
        let data = Data(errorMessage.utf8)
        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextData = data
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: nil)
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        // Act + Assert
        do {
            let _: [DocumentDTO] = try await service.listDocuments()
            XCTFail("Ожидали NetworkError.serverError, но успело вернуться значение")
        } catch {
            guard case let NetworkError.serverError(status, message) = error else {
                return XCTFail("Ожидали NetworkError.serverError, получили: \(error)")
            }
            XCTAssertEqual(status, 500)
            XCTAssertEqual(message, errorMessage)
        }
    }

    /// 10) Проверка getDocument (GET /documents/{id}) «хэппи-пасс»
    func testGetDocument_Successful200_ReturnsDocumentDTO() async throws {
        // Arrange
        let docID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let dummyDoc = DocumentDTO(
            id: docID,
            fileName:        "Doc1.pdf",
            fileURL:         "https://example.com/files/Doc1.pdf",
            fileType:        "pdf",
            createTime:      "2025-06-03T00:00:00Z",
            comment:         nil,
            isFavorite:      false,
            artistName:      "Artist1",
            artistNickname:  "Nick1",
            compositionName: "Comp1",
            price:           "10"
        )
        let jsonData = try JSONEncoder().encode(dummyDoc)

        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents/\(docID.uuidString)")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextData = jsonData
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: "tokXYZ")
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        // Act
        let returnedDoc: DocumentDTO = try await service.getDocument(id: docID)

        // Assert
        XCTAssertEqual(returnedDoc, dummyDoc)

        let lastReq = sessionMock.lastRequest!
        XCTAssertEqual(lastReq.httpMethod, "GET")
        XCTAssertEqual(
            lastReq.url?.absoluteString,
            "http://127.0.0.1:8080/api/v1/documents/\(docID.uuidString)"
        )
        XCTAssertEqual(
            lastReq.value(forHTTPHeaderField: "Authorization"),
            "Bearer tokXYZ"
        )
    }

    /// 11) Проверка getDocument при статусе 404 → throws serverError
    func testGetDocument_Status404_ThrowsServerError() async throws {
        // Arrange
        let docID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let errorMessage = "Not found"
        let data = Data(errorMessage.utf8)
        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents/\(docID.uuidString)")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextData = data
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: nil)
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        // Act + Assert
        do {
            let _: DocumentDTO = try await service.getDocument(id: docID)
            XCTFail("Ожидали NetworkError.serverError, но получили успех")
        } catch {
            guard case let NetworkError.serverError(status, message) = error else {
                return XCTFail("Ожидали NetworkError.serverError, получили: \(error)")
            }
            XCTAssertEqual(status, 404)
            XCTAssertEqual(message, errorMessage)
        }
    }

    /// 12) Проверка updateDocument (PUT /documents/{id}) «хэппи-пасс»
    func testUpdateDocument_Successful200_ReturnsDocumentDTO() async throws {
        // Arrange
        let docID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let updateReq = UpdateDocumentRequest(
            comment:    "New note",
            isFavorite: true
        )
        let dummyDoc = DocumentDTO(
            id: docID,
            fileName:        "Doc1.pdf",
            fileURL:         "https://example.com/files/Doc1.pdf",
            fileType:        "pdf",
            createTime:      "2025-06-03T00:00:00Z",
            comment:         "New note",
            isFavorite:      true,
            artistName:      "Artist1",
            artistNickname:  "Nick1",
            compositionName: "Comp1",
            price:           "10"
        )
        let jsonData = try JSONEncoder().encode(dummyDoc)

        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents/\(docID.uuidString)")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextData = jsonData
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: "tokXYZ")
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        // Act
        let returnedDoc: DocumentDTO = try await service.updateDocument(
            id: docID,
            update: updateReq
        )

        // Assert
        XCTAssertEqual(returnedDoc, dummyDoc)

        let lastReq = sessionMock.lastRequest!
        XCTAssertEqual(lastReq.httpMethod, "PUT")
        XCTAssertEqual(
            lastReq.url?.absoluteString,
            "http://127.0.0.1:8080/api/v1/documents/\(docID.uuidString)"
        )
        XCTAssertEqual(
            lastReq.value(forHTTPHeaderField: "Authorization"),
            "Bearer tokXYZ"
        )
        // Тело должно содержать JSON с полями "comment" и "isFavorite"
        let bodyString = String(data: lastReq.httpBody!, encoding: .utf8) ?? ""
        XCTAssertTrue(
            bodyString.contains("\"comment\":\"New note\"") &&
            bodyString.contains("\"isFavorite\":true"),
            "HTTP body не содержит ожидаемых полей updateReq"
        )
    }

    /// 13) Проверка updateDocument при статусе 400 → throws serverError
    func testUpdateDocument_Status400_ThrowsServerError() async throws {
        // Arrange
        let docID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let updateReq = UpdateDocumentRequest(
            comment:    "New note",
            isFavorite: true
        )
        let errorMessage = "Bad request"
        let data = Data(errorMessage.utf8)
        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents/\(docID.uuidString)")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextData = data
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: nil)
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        // Act + Assert
        do {
            let _: DocumentDTO = try await service.updateDocument(
                id: docID,
                update: updateReq
            )
            XCTFail("Ожидали NetworkError.serverError, но получили успех")
        } catch {
            guard case let NetworkError.serverError(status, message) = error else {
                return XCTFail("Ожидали NetworkError.serverError, получили: \(error)")
            }
            XCTAssertEqual(status, 400)
            XCTAssertEqual(message, errorMessage)
        }
    }

    /// 14) Проверка deleteDocument (DELETE /documents/{id}) «хэппи-пасс»
    func testDeleteDocument_Successful200_CompletesWithoutError() async throws {
        // Arrange
        let docID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents/\(docID.uuidString)")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: "tok123")
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        // Act (должен завершиться без ошибок)
        try await service.deleteDocument(id: docID)

        // Assert
        let lastReq = sessionMock.lastRequest!
        XCTAssertEqual(lastReq.httpMethod, "DELETE")
        XCTAssertEqual(
            lastReq.url?.absoluteString,
            "http://127.0.0.1:8080/api/v1/documents/\(docID.uuidString)"
        )
        XCTAssertEqual(
            lastReq.value(forHTTPHeaderField: "Authorization"),
            "Bearer tok123"
        )
    }

    /// 15) Проверка deleteDocument при статусе 500 → throws serverError
    func testDeleteDocument_Status500_ThrowsServerError() async throws {
        // Arrange
        let docID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents/\(docID.uuidString)")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: nil)
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        // Act + Assert
        do {
            try await service.deleteDocument(id: docID)
            XCTFail("Ожидали NetworkError.serverError, но получили завершение")
        } catch {
            guard case let NetworkError.serverError(status, _) = error else {
                return XCTFail("Ожидали NetworkError.serverError, получили: \(error)")
            }
            XCTAssertEqual(status, 500)
        }
    }

    /// 16) Проверка deleteAllDocuments (DELETE /documents) «хэппи-пасс»
    func testDeleteAllDocuments_Successful200_CompletesWithoutError() async throws {
        // Arrange
        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: "tokXYZ")
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        // Act (должен завершиться без ошибок)
        try await service.deleteAllDocuments()

        // Assert
        let lastReq = sessionMock.lastRequest!
        XCTAssertEqual(lastReq.httpMethod, "DELETE")
        XCTAssertEqual(
            lastReq.url?.absoluteString,
            "http://127.0.0.1:8080/api/v1/documents"
        )
        XCTAssertEqual(
            lastReq.value(forHTTPHeaderField: "Authorization"),
            "Bearer tokXYZ"
        )
    }

    /// 17) Проверка deleteAllDocuments при статусе 500 → throws serverError
    func testDeleteAllDocuments_Status500_ThrowsServerError() async throws {
        // Arrange
        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: nil)
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        // Act + Assert
        do {
            try await service.deleteAllDocuments()
            XCTFail("Ожидали NetworkError.serverError, но получили завершение")
        } catch {
            guard case let NetworkError.serverError(status, _) = error else {
                return XCTFail("Ожидали NetworkError.serverError, получили: \(error)")
            }
            XCTAssertEqual(status, 500)
        }
    }
}
