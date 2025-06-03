import XCTest
@testable import Docs

final class RegistrationViewModelTests: XCTestCase {
    
    private var viewModel: RegistrationViewModel!
    private var networkMock: NetworkServiceMock!
    private var keychainMock: KeychainServiceMock!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        networkMock = NetworkServiceMock()
        keychainMock = KeychainServiceMock()
        viewModel = RegistrationViewModel(
            network: networkMock,
            keychain: keychainMock
        )
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        networkMock = nil
        keychainMock = nil
        try super.tearDownWithError()
    }
    
    /// 1) Успешная регистрация: Network возвращает TokenResponse, ViewModel вызывает onSuccess,
    ///    и токен сохраняется в keychain.
    func testRegister_Success_CallsOnSuccessAndSavesToken() {
        let expectedToken = "newToken123"
        let dummyUserID = UserID(id: UUID())
        let dummyResponse = TokenResponse(
            id: UUID(),
            value: expectedToken,
            user: dummyUserID
        )
        networkMock.nextTokenResponse = dummyResponse
        
        let successExpectation = expectation(description: "onSuccess called")
        viewModel.onSuccess = {
            successExpectation.fulfill()
        }
        viewModel.onError = { errMsg in
            XCTFail("onError не должен вызываться, получили: \(errMsg)")
        }
        
        viewModel.register(username: "testUser", email: "test@example.com", password: "password")
        
        wait(for: [successExpectation], timeout: 1.0)
        
        do {
            let stored = try keychainMock.fetch(.authToken)
            XCTAssertEqual(
                stored,
                expectedToken,
                "Ожидали, что keychain.save(token) сохранит «\(expectedToken)»"
            )
        } catch {
            XCTFail("Не ожидали ошибку при fetch из keychain: \(error)")
        }
    }
    
    /// 2) Если network.request бросает NetworkError, вызываем onError с сообщением "Сервер вернул ошибку: …"
    func testRegister_NetworkError_CallsOnErrorWithNetworkError() {
        
        let netErr = NetworkError.serverError(status: 500, message: "Internal server error")
        networkMock.nextError = netErr
        
        let errorExpectation = expectation(description: "onError called with NetworkError")
        viewModel.onSuccess = {
            XCTFail("onSuccess не должен вызываться при ошибке")
        }
        viewModel.onError = { errorMessage in
            XCTAssertTrue(
                errorMessage.contains("Сервер вернул ошибку:"),
                "Ожидали, что сообщение об ошибке начнётся с «Сервер вернул ошибку:», получили: \(errorMessage)"
            )
            XCTAssertTrue(
                errorMessage.contains("serverError"),
                "Ожидали, что в errorMessage будет представление netErr (включая «serverError»), получили: \(errorMessage)"
            )
            errorExpectation.fulfill()
        }
        
        viewModel.register(username: "u", email: "e", password: "p")
        
        wait(for: [errorExpectation], timeout: 1.0)
        
        do {
            let stored = try keychainMock.fetch(.authToken)
            XCTAssertNil(
                stored,
                "Не ожидали, что keychain.save будет вызван при ошибке NetworkError"
            )
        } catch {
            XCTFail("Не ожидали ошибку при fetch из keychain после NetworkError: \(error)")
        }
    }
    
    /// 3) Если network.request бросает любой другой Error, вызываем onError "Неизвестная ошибка: …"
    func testRegister_UnexpectedError_CallsOnErrorWithLocalizedDescription() {
        let unexpected = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
        networkMock.nextError = unexpected
        
        let errorExpectation = expectation(description: "onError called with generic error")
        viewModel.onSuccess = {
            XCTFail("onSuccess не должен вызываться при неизвестной ошибке")
        }
        viewModel.onError = { errorMessage in
            XCTAssertEqual(
                errorMessage,
                "Неизвестная ошибка: \(unexpected.localizedDescription)",
                "Ожидали точное сообщение «Неизвестная ошибка: Something went wrong», получили: \(errorMessage)"
            )
            errorExpectation.fulfill()
        }
        
        viewModel.register(username: "u", email: "e", password: "p")
        
        wait(for: [errorExpectation], timeout: 1.0)
        
        do {
            let stored = try keychainMock.fetch(.authToken)
            XCTAssertNil(
                stored,
                "Не ожидали, что ключ сохранится в keychain при неизвестной ошибке"
            )
        } catch {
            XCTFail("Не ожидали ошибку при fetch из keychain после неизвестной ошибки: \(error)")
        }
    }
}
