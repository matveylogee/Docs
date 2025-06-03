import XCTest
@testable import Docs

final class NetworkServiceDownloadTests: XCTestCase {
    
    /// 6) Проверка downloadDocument → возвращаем URL файла
    func testDownloadDocument_Successful200_ReturnsLocalFileURL() async throws {
        // Arrange
        let tempDownloadedURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("out.pdf")

        let sessionMock = URLSessionMock()
        sessionMock.nextDownloadedFileURL = tempDownloadedURL
        sessionMock.nextDownloadResponse = HTTPURLResponse(
            url: URL(string: "http://127.0.0.1:8080/api/v1/documents/ID/download")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let tokenMock = TokenProviderMock(token: "tokXYZ")
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        let docID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!

        // Act
        let returnedURL = try await service.downloadDocument(id: docID)

        // Assert
        XCTAssertEqual(returnedURL, tempDownloadedURL)

        let lastReq = sessionMock.lastRequest!
        XCTAssertEqual(lastReq.httpMethod, "GET")
        XCTAssertEqual(
            lastReq.url?.absoluteString,
            "http://127.0.0.1:8080/api/v1/documents/\(docID.uuidString)/download"
        )
        XCTAssertEqual(
            lastReq.value(forHTTPHeaderField: "Authorization"),
            "Bearer tokXYZ"
        )
    }

    /// 7) Проверка downloadDocument при ошибке → выбрасывается URLError
    func testDownloadDocument_UnderlyingError_Throws() async throws {
        // Arrange
        let underlying = URLError(.notConnectedToInternet)
        let sessionMock = URLSessionMock()
        sessionMock.nextDownloadError = underlying

        let tokenMock = TokenProviderMock(token: nil)
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )
        let docID = UUID()

        // Act + Assert
        do {
            _ = try await service.downloadDocument(id: docID)
            XCTFail("Ожидали URLError, но получили URL.")
        } catch {
            guard let urlErr = error as? URLError else {
                return XCTFail("Ожидали URLError, а получили \(error)")
            }
            XCTAssertEqual(urlErr.code, .notConnectedToInternet)
        }
    }
}
