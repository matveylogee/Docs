import XCTest
@testable import Docs

// MARK: - Mock для URLSessionProtocol
final class URLSessionMock: URLSessionProtocol {
    private(set) var lastRequest: URLRequest?
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?

    var nextDownloadedFileURL: URL?
    var nextDownloadResponse: URLResponse?
    var nextDownloadError: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        if let err = nextError {
            throw err
        }
        let data = nextData ?? Data()
        let response = nextResponse ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        return (data, response)
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        lastRequest = request
        if let err = nextDownloadError {
            throw err
        }
        let fileURL = nextDownloadedFileURL ??
            URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("dummy.pdf")
        let response = nextDownloadResponse ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        return (fileURL, response)
    }
}

// MARK: - Mock для TokenProviderProtocol
final class TokenProviderMock: TokenProviderProtocol {
    var token: String?
    init(token: String?) { self.token = token }
    func save(token: String) { self.token = token }
}

// MARK: - Тестовый Endpoint и TokenProviderMock
struct TestEndpoint: Endpoint {
    let baseURL: URL?
    let path: String
    let method: String
    let headers: [String: String]?
    let bodyData: Data?

    func encodedBody() throws -> Data? {
        return bodyData
    }
}

// MARK: - Фейковый ответ для generic-request
struct DummyResponse: Codable, Equatable {
    let id: Int
    let name: String
}
