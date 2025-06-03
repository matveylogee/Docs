import XCTest
@testable import Docs

final class NetworkServiceGenericTests: XCTestCase {
    
    /// 1) Проверим, что request<Req,Res> при 200 возвращает Decodable-модель
    func testRequest_Successful200_ReturnsDecodedModel() async throws {
        
        let dummy = DummyResponse(id: 123, name: "Тестовый")
        let jsonData = try JSONEncoder().encode(dummy)

        let url = URL(string: "https://example.com/v1/test")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextData = jsonData
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: "abc123")
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        let fakeEndpoint = TestEndpoint(
            baseURL: URL(string: "https://example.com"),
            path: "/v1/test",
            method: "GET",
            headers: ["X-Custom-Header": "Value"],
            bodyData: nil
        )

        
        let result: DummyResponse = try await service.request(
            endpoint: fakeEndpoint,
            requestDTO: EmptyRequest()
        )

        
        XCTAssertEqual(result, dummy)

        let lastReq = sessionMock.lastRequest!
        XCTAssertEqual(lastReq.url?.absoluteString, "https://example.com/v1/test")
        XCTAssertEqual(lastReq.httpMethod, "GET")
        XCTAssertEqual(lastReq.value(forHTTPHeaderField: "X-Custom-Header"), "Value")
        XCTAssertEqual(
            lastReq.value(forHTTPHeaderField: "Authorization"),
            "Bearer abc123"
        )
        XCTAssertNil(lastReq.httpBody)
    }

    /// 2) Проверим, что при статусе 404 выбрасывается NetworkError.serverError
    func testRequest_Status404_ThrowsServerError() async throws {
        
        let errorMessage = "Not found"
        let data = Data(errorMessage.utf8)
        let url = URL(string: "https://example.com/v1/notfound")!
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

        let fakeEndpoint = TestEndpoint(
            baseURL: URL(string: "https://example.com"),
            path: "/v1/notfound",
            method: "DELETE",
            headers: nil,
            bodyData: nil
        )

        do {
            let _: DummyResponse = try await service.request(
                endpoint: fakeEndpoint,
                requestDTO: EmptyRequest()
            )
            XCTFail("Ожидали ошибку, но её не было.")
        } catch {
            guard case let NetworkError.serverError(status, message) = error else {
                return XCTFail("Ожидали NetworkError.serverError, получили: \(error)")
            }
            XCTAssertEqual(status, 404)
            XCTAssertEqual(message, errorMessage)
        }
    }

    /// 3) Проверим, что baseURL = nil даёт NetworkError.invalidURL
    func testRequest_InvalidURL_ThrowsInvalidURL() async throws {
        
        let sessionMock = URLSessionMock()
        let tokenMock = TokenProviderMock(token: nil)
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        let badEndpoint = TestEndpoint(
            baseURL: nil,
            path: "/whatever",
            method: "PATCH",
            headers: nil,
            bodyData: nil
        )

        do {
            let _: DummyResponse = try await service.request(
                endpoint: badEndpoint,
                requestDTO: EmptyRequest()
            )
            XCTFail("Ожидали NetworkError.invalidURL, но получили результат")
        } catch {
            guard case NetworkError.invalidURL = error else {
                return XCTFail("Ожидали NetworkError.invalidURL, получили: \(error)")
            }
        }
    }

    /// 4) Проверим, что «плохой» JSON даёт NetworkError.decodingError
    func testRequest_InvalidJSON_ThrowsDecodingError() async throws {
        
        let brokenJSON = #" { "id": "нечисло", "name": 123 } "#.data(using: .utf8)!

        let url = URL(string: "https://example.com/v1/test")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let sessionMock = URLSessionMock()
        sessionMock.nextData = brokenJSON
        sessionMock.nextResponse = httpResponse

        let tokenMock = TokenProviderMock(token: nil)
        let service = NetworkService(
            session: sessionMock,
            tokenProvider: tokenMock
        )

        let fakeEndpoint = TestEndpoint(
            baseURL: URL(string: "https://example.com"),
            path: "/v1/test",
            method: "GET",
            headers: nil,
            bodyData: nil
        )

        do {
            let _: DummyResponse = try await service.request(
                endpoint: fakeEndpoint,
                requestDTO: EmptyRequest()
            )
            XCTFail("Ожидали NetworkError.decodingError, но получили результат")
        } catch {
            guard case NetworkError.decodingError = error else {
                return XCTFail("Ожидали NetworkError.decodingError, получили: \(error)")
            }
        }
    }
}
