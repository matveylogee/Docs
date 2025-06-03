import XCTest
@testable import Docs

final class NetworkServiceUploadTests: XCTestCase {
    
    /// 5) Тестируем uploadDocument (multipart/form-data) «хэппи-пасс»
    func testUploadDocument_Successful200_ReturnsDocumentDTO() async throws {
        
        let dummyDoc = DocumentDTO(
            id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!,
            fileName:       "TestDoc.pdf",
            fileURL:        "https://example.com/files/TestDoc.pdf",
            fileType:       "pdf",
            createTime:     "2025-06-03T12:00:00Z",
            comment:        nil,
            isFavorite:     false,
            artistName:     "TestArtist",
            artistNickname: "ArtistNick",
            compositionName:"SomeComposition",
            price:          "0"
        )
        let jsonData = try JSONEncoder().encode(dummyDoc)

        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("test.pdf")
        FileManager.default.createFile(
            atPath: tempURL.path,
            contents: Data("PDFDATA".utf8),
            attributes: nil
        )

        let url = URL(string: "http://127.0.0.1:8080/api/v1/documents")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextData = jsonData
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: "tok123")
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        let createReq = CreateDocumentRequest(
            fileType:       "pdf",
            createTime:     "2025-06-03T12:00:00Z",
            artistName:     "TestArtist",
            artistNickname: "ArtistNick",
            compositionName:"SomeComposition",
            price:          "0",
            comment:        nil,
            isFavorite:     false
        )

        // Act
        let returned: DocumentDTO = try await service.uploadDocument(
            fileURL:  tempURL,
            metadata: createReq
        )

        XCTAssertEqual(returned, dummyDoc)

        let lastReq = sessionMock.lastRequest!
        XCTAssertEqual(lastReq.httpMethod, "POST")

        XCTAssertEqual(
            lastReq.url?.absoluteString,
            "http://127.0.0.1:8080/api/v1/documents"
        )

        let contentType = lastReq.value(forHTTPHeaderField: "Content-Type")
        XCTAssertTrue(
            contentType?.starts(with: "multipart/form-data; boundary=") ?? false,
            "Ожидали multipart/form-data с boundary, а получили: \(String(describing: contentType))"
        )

        XCTAssertEqual(
            lastReq.value(forHTTPHeaderField: "Authorization"),
            "Bearer tok123"
        )

        XCTAssertNotNil(lastReq.httpBody)
        let bodyString = String(data: lastReq.httpBody!, encoding: .utf8) ?? ""
        XCTAssertTrue(
            bodyString.contains("Content-Disposition: form-data; name=\"file\"; filename=\"test.pdf\""),
            "В теле не нашлась PDF-часть"
        )
        XCTAssertTrue(
            bodyString.contains("\"fileType\":\"pdf\"") &&
            bodyString.contains("\"createTime\":\"2025-06-03T12:00:00Z\"") &&
            bodyString.contains("\"artistName\":\"TestArtist\"") &&
            bodyString.contains("\"artistNickname\":\"ArtistNick\"") &&
            bodyString.contains("\"compositionName\":\"SomeComposition\"") &&
            bodyString.contains("\"price\":\"0\""),
            "В JSON-части не нашлись все поля CreateDocumentRequest"
        )
    }
}
