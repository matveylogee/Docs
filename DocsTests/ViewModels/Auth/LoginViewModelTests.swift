import XCTest
@testable import Docs

final class LoginViewModelTests: XCTestCase {

    private var viewModel: LoginViewModel!
    private var networkMock: NetworkServiceMock!
    private var tokenProviderMock: TokenProviderVMMock!
    private var keychainMock: KeychainServiceMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        networkMock = NetworkServiceMock()
        tokenProviderMock = TokenProviderVMMock()
        keychainMock = KeychainServiceMock()
        viewModel = LoginViewModel(
            network: networkMock,
            tokenProvider: tokenProviderMock,
            keychain: keychainMock
        )
    }

    override func tearDownWithError() throws {
        viewModel = nil
        networkMock = nil
        tokenProviderMock = nil
        keychainMock = nil
        try super.tearDownWithError()
    }

    /// 1) Успешный логин: Network возвращает токен, ViewModel вызывает onSuccess,
    ///    токен сохраняется в tokenProvider и keychain.
    func testLogin_Success_CallsOnSuccessAndSavesToken() {
        let expectedToken = "abc123"
        let dummyUserID = UserID(id: UUID())
        let dummyTokenResponse = TokenResponse(
            id: UUID(),
            value: expectedToken,
            user: dummyUserID
        )
        networkMock.nextTokenResponse = dummyTokenResponse

        
        let successExpectation = expectation(description: "onSuccess called")
        viewModel.onSuccess = {
            successExpectation.fulfill()
        }
        viewModel.onError = { errorMessage in
            XCTFail("onError не должен вызываться, а получил: \(errorMessage)")
        }

        viewModel.login(email: "user@example.com", password: "password")

        wait(for: [successExpectation], timeout: 1.0)

        XCTAssertEqual(
            tokenProviderMock.token,
            expectedToken,
            "Ожидали, что tokenProvider.save(token:) будет вызван с «\(expectedToken)»"
        )

        do {
            let stored = try keychainMock.fetch(.authToken)
            XCTAssertEqual(
                stored,
                expectedToken,
                "Ожидали, что keychain.save(...) запишет «\(expectedToken)»"
            )
        } catch {
            XCTFail("Не ожидали ошибку при fetch из keychain: \(error)")
        }
    }

    /// 2) Ошибка логина (например, неверные креды): Network кидает ошибку, ViewModel вызывает onError
    func testLogin_Failure_CallsOnError() {
        let expectedError = NSError(domain: "TestDomain", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
        networkMock.nextError = expectedError

        let errorExpectation = expectation(description: "onError called")
        viewModel.onSuccess = {
            XCTFail("onSuccess не должен вызываться")
        }
        viewModel.onError = { errorMessage in
            XCTAssertEqual(
                errorMessage,
                expectedError.localizedDescription,
                "Ожидали, что onError будет вызван с сообщением \(expectedError.localizedDescription)"
            )
            errorExpectation.fulfill()
        }

        viewModel.login(email: "wrong@example.com", password: "wrongpass")

        wait(for: [errorExpectation], timeout: 1.0)

        XCTAssertNil(
            tokenProviderMock.token,
            "Не ожидали, что tokenProvider.save(token:) будет вызван при ошибке"
        )
        
        do {
            let stored = try keychainMock.fetch(.authToken)
            XCTAssertNil(
                stored,
                "Не ожидали, что в keychain будет сохранён токен при ошибке"
            )
        } catch {
            XCTFail("Не ожидали ошибку при fetch из keychain после неудачного логина: \(error)")
        }
    }
}
