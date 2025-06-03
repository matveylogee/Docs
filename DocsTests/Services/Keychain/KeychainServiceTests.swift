import XCTest
@testable import Docs

final class KeychainServiceTests: XCTestCase {
    
    private var keychainService: KeychainServiceProtocol!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        keychainService = KeychainService()
        try? keychainService.delete(.authToken)
    }
    
    override func tearDownWithError() throws {
        try? keychainService.delete(.authToken)
        keychainService = nil
        try super.tearDownWithError()
    }
    
    /// 1) Если в Keychain нет сохранённого токена, fetch(_:) вернёт nil
    func testFetch_WhenNotSaved_ReturnsNil() throws {
        try? keychainService.delete(.authToken)
        
        let fetched = try keychainService.fetch(.authToken)
        
        XCTAssertNil(fetched, "Ожидали, что при отсутствии значения fetch вернёт nil")
    }
    
    /// 2) После save(_ value:for:) fetch(_:) вернёт то же самое значение
    func testSaveAndFetch_ReturnsSavedValue() throws {
        let expectedValue = "secret-token-123"
        try keychainService.save(expectedValue, for: .authToken)
        
        let fetched = try keychainService.fetch(.authToken)
        
        XCTAssertEqual(fetched, expectedValue, "Ожидали, что fetch вернёт ранее сохранённое значение")
    }
    
    /// 3) Если в Keychain уже есть значение, вызов save(_:) перезапишет его
    func testSave_OverwritePreviousValue() throws {
        let firstValue = "first-token"
        let secondValue = "second-token"
        
        try keychainService.save(firstValue, for: .authToken)
        try keychainService.save(secondValue, for: .authToken)
        let fetched = try keychainService.fetch(.authToken)
        
        XCTAssertEqual(fetched, secondValue, "Ожидали, что значение будет перезаписано на второе")
    }
    
    /// 4) После delete(_:) fetch(_:) вернёт nil (удаление существующей записи)
    func testDelete_WhenKeyExists_FetchReturnsNil() throws {
        let value = "to-be-deleted"
        try keychainService.save(value, for: .authToken)

        XCTAssertEqual(try keychainService.fetch(.authToken), value)
        
        try keychainService.delete(.authToken)
        let fetchedAfterDelete = try keychainService.fetch(.authToken)
        
        XCTAssertNil(fetchedAfterDelete, "Ожидали, что после delete запись исчезнет и fetch вернёт nil")
    }
    
    /// 5) delete(_:) на отсутствии записи не должен выбрасывать ошибку
    func testDelete_WhenKeyDoesNotExist_DoesNotThrow() {
        try? keychainService.delete(.authToken)
        
        XCTAssertNoThrow(
            try keychainService.delete(.authToken),
            "Ожидали, что delete не выбросит ошибку, даже если ключа нет"
        )
    }
}
