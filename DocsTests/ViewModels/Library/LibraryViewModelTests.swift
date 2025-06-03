import XCTest
@testable import Docs

final class LibraryViewModelTests: XCTestCase {

    private var viewModel: LibraryViewModel!
    private var networkMock: LibraryNetworkMock!
    private var dateServiceMock: LibraryCurrentDateMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        networkMock = LibraryNetworkMock()
        dateServiceMock = LibraryCurrentDateMock()
        viewModel = LibraryViewModel(network: networkMock, dateService: dateServiceMock)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        networkMock = nil
        dateServiceMock = nil
        try super.tearDownWithError()
    }

    // MARK: - fetchDocuments без фильтров: onDocumentsChanged с полным списком
    func testFetchDocuments_Success_NoFilters_CallsOnDocumentsChangedFullList() {
        let doc1 = DocumentDTO(
            id: UUID(),
            fileName: "Doc1.pdf",
            fileURL: "url1",
            fileType: "mp3",
            createTime: "time1",
            comment: nil,
            isFavorite: false,
            artistName: "A",
            artistNickname: "A1",
            compositionName: "C1",
            price: "1"
        )
        
        let doc2 = DocumentDTO(
            id: UUID(),
            fileName: "Doc2.pdf",
            fileURL: "url2",
            fileType: "wav",
            createTime: "time2",
            comment: "hello",
            isFavorite: true,
            artistName: "B",
            artistNickname: "B1",
            compositionName: "C2",
            price: "2"
        )
        
        networkMock.nextDocuments = [doc1, doc2]

        let expectationChanged = expectation(description: "onDocumentsChanged called with full list")
        var received: [DocumentDTO]?

        viewModel.onDocumentsChanged = { docs in
            received = docs
            expectationChanged.fulfill()
        }
        viewModel.onError = { _ in
            XCTFail("onError не должен вызываться при успешном fetch")
        }

        viewModel.fetchDocuments(showingFavoritesOnly: false, filter: nil)

        wait(for: [expectationChanged], timeout: 1.0)
        XCTAssertEqual(received, [doc1, doc2], "Ожидали полный список документов [doc1, doc2]")
    }

    // MARK: - fetchDocuments с showingFavoritesOnly=true: возвращаются только избранные
    func testFetchDocuments_Success_FavoritesOnly() {
        let fav = DocumentDTO(
            id: UUID(),
            fileName: "FavDoc.pdf",
            fileURL: "urlFav",
            fileType: "mp3",
            createTime: "time",
            comment: nil,
            isFavorite: true,
            artistName: "X",
            artistNickname: "X1",
            compositionName: "CX",
            price: "0"
        )
        
        let nonFav = DocumentDTO(
            id: UUID(),
            fileName: "NonFav.pdf",
            fileURL: "urlN",
            fileType: "wav",
            createTime: "time",
            comment: nil,
            isFavorite: false,
            artistName: "Y",
            artistNickname: "Y1",
            compositionName: "CY",
            price: "0"
        )
        
        networkMock.nextDocuments = [nonFav, fav]

        let expectationChanged = expectation(description: "onDocumentsChanged with only favorites")
        var received: [DocumentDTO]?

        viewModel.onDocumentsChanged = { docs in
            received = docs
            expectationChanged.fulfill()
        }
        viewModel.onError = { _ in
            XCTFail("onError не должен вызываться при успешном fetch")
        }

        viewModel.fetchDocuments(showingFavoritesOnly: true, filter: nil)

        wait(for: [expectationChanged], timeout: 1.0)
        XCTAssertEqual(received, [fav], "Ожидали список только избранных документов [fav]")
    }

    // MARK: - fetchDocuments с текстовым фильтром (case-insensitive)
    func testFetchDocuments_Success_FilterByFileName() {
        let d1 = DocumentDTO(
            id: UUID(),
            fileName: "Apple.pdf",
            fileURL: "u1",
            fileType: "mp3",
            createTime: "t1",
            comment: nil,
            isFavorite: false,
            artistName: "A",
            artistNickname: "A1",
            compositionName: "C1",
            price: "1"
        )
        
        let d2 = DocumentDTO(
            id: UUID(),
            fileName: "Banana.pdf",
            fileURL: "u2",
            fileType: "wav",
            createTime: "t2",
            comment: nil,
            isFavorite: false,
            artistName: "B",
            artistNickname: "B1",
            compositionName: "C2",
            price: "2"
        )
        
        let d3 = DocumentDTO(
            id: UUID(),
            fileName: "appleJuice.pdf",
            fileURL: "u3",
            fileType: "trackout",
            createTime: "t3",
            comment: nil,
            isFavorite: false,
            artistName: "C",
            artistNickname: "C1",
            compositionName: "C3",
            price: "3"
        )
        
        networkMock.nextDocuments = [d1, d2, d3]

        let expectationChanged = expectation(description: "onDocumentsChanged with filtered list")
        var received: [DocumentDTO]?

        viewModel.onDocumentsChanged = { docs in
            received = docs
            expectationChanged.fulfill()
        }
        viewModel.onError = { _ in
            XCTFail("onError не должен вызываться при успешном fetch")
        }

        viewModel.fetchDocuments(showingFavoritesOnly: false, filter: "apple")

        wait(for: [expectationChanged], timeout: 1.0)
        XCTAssertEqual(received, [d1, d3], "Ожидали список документов, в которых fileName содержит 'apple'")
    }

    // MARK: - fetchDocuments – ошибка сети: onError вызывается
    func testFetchDocuments_Failure_CallsOnError() {
        let expectedError = NSError(domain: "TestDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server down"])
        networkMock.nextListError = expectedError

        let errorExpectation = expectation(description: "onError called")
        viewModel.onDocumentsChanged = { _ in
            XCTFail("onDocumentsChanged не должен вызываться при ошибке")
        }
        viewModel.onError = { errMsg in
            XCTAssertEqual(errMsg, expectedError.localizedDescription,
                           "Ожидали, что onError получит «\(expectedError.localizedDescription)»")
            errorExpectation.fulfill()
        }

        viewModel.fetchDocuments(showingFavoritesOnly: false, filter: nil)

        wait(for: [errorExpectation], timeout: 1.0)
    }

    // MARK: - deleteDocument – успешное удаление: onDocumentsChanged с обновлённым локальным списком
    func testDeleteDocument_Success_RemovesFromLocalCacheAndCallsOnDocumentsChanged() {
        let idToDelete = UUID()
        
        let keep = DocumentDTO(
            id: UUID(),
            fileName: "Keep.pdf",
            fileURL: "u1",
            fileType: "mp3",
            createTime: "t1",
            comment: nil,
            isFavorite: false,
            artistName: "A",
            artistNickname: "A1",
            compositionName: "C1",
            price: "1"
        )
        
        let delDoc = DocumentDTO(
            id: idToDelete,
            fileName: "Delete.pdf",
            fileURL: "u2",
            fileType: "wav",
            createTime: "t2",
            comment: nil,
            isFavorite: false,
            artistName: "B",
            artistNickname: "B1",
            compositionName: "C2",
            price: "2"
        )
        
        networkMock.nextDocuments = [keep, delDoc]
        let fetchExpectation = expectation(description: "Initial fetch to populate allDocuments")
        viewModel.onDocumentsChanged = { docs in
            fetchExpectation.fulfill()
        }
        viewModel.onError = { _ in XCTFail("onError не должен вызываться при fetch") }
        viewModel.fetchDocuments(showingFavoritesOnly: false, filter: nil)
        wait(for: [fetchExpectation], timeout: 1.0)

        let deleteExpectation = expectation(description: "onDocumentsChanged called after delete")
        var receivedAfterDelete: [DocumentDTO]?

        viewModel.onDocumentsChanged = { docs in
            receivedAfterDelete = docs
            deleteExpectation.fulfill()
        }
        viewModel.onError = { _ in XCTFail("onError не должен вызываться при удалении") }

        viewModel.deleteDocument(id: idToDelete)

        // Assert
        wait(for: [deleteExpectation], timeout: 1.0)
        XCTAssertEqual(receivedAfterDelete, [keep],
                       "Ожидали, что после удаления останется только [keep]")
    }

    // MARK: - deleteDocument – ошибка сети: onError вызывается
    func testDeleteDocument_Failure_CallsOnError() {
        let someID = UUID()
        let expectedErr = NSError(domain: "TestDomain", code: 400, userInfo: [NSLocalizedDescriptionKey: "Bad request"])
        networkMock.nextDeleteError = expectedErr

        let errorExpectation = expectation(description: "onError called on delete failure")
        viewModel.onDocumentsChanged = nil
        viewModel.onError = { errMsg in
            XCTAssertEqual(errMsg, expectedErr.localizedDescription,
                           "Ожидали, что onError получит «\(expectedErr.localizedDescription)»")
            errorExpectation.fulfill()
        }

        viewModel.deleteDocument(id: someID)

        wait(for: [errorExpectation], timeout: 1.0)
    }

    // MARK: - updateComment – успешный путь: onDocumentsChanged с обновлённым комментарием
    func testUpdateComment_Success_UpdatesLocalAndCallsOnDocumentsChanged() {
        let targetID = UUID()
        let original = DocumentDTO(
            id: targetID,
            fileName: "Doc.pdf",
            fileURL: "u",
            fileType: "mp3",
            createTime: "t",
            comment: "old",
            isFavorite: false,
            artistName: "A",
            artistNickname: "A1",
            compositionName: "C1",
            price: "1"
        )
        
        let unchanged = DocumentDTO(
            id: UUID(),
            fileName: "Other.pdf",
            fileURL: "u2",
            fileType: "wav",
            createTime: "t2",
            comment: nil,
            isFavorite: false,
            artistName: "B",
            artistNickname: "B1",
            compositionName: "C2",
            price: "2"
        )
        
        networkMock.nextDocuments = [original, unchanged]
        let initialFetchExp = expectation(description: "initial fetch")
        viewModel.onDocumentsChanged = { _ in initialFetchExp.fulfill() }
        viewModel.onError = { _ in XCTFail("onError не должен вызываться при fetch") }
        viewModel.fetchDocuments(showingFavoritesOnly: false, filter: nil)
        wait(for: [initialFetchExp], timeout: 1.0)

        let updatedDTO = DocumentDTO(
            id: targetID,
            fileName: "Doc.pdf",
            fileURL: "u",
            fileType: "mp3",
            createTime: "t",
            comment: "new",
            isFavorite: false,
            artistName: "A",
            artistNickname: "A1",
            compositionName: "C1",
            price: "1"
        )
        networkMock.nextUpdatedDocument = updatedDTO

        let updateExp = expectation(description: "onDocumentsChanged after updateComment")
        var receivedAfterComment: [DocumentDTO]?

        viewModel.onDocumentsChanged = { docs in
            receivedAfterComment = docs
            updateExp.fulfill()
        }
        viewModel.onError = { _ in XCTFail("onError не должен вызываться при updateComment") }

        viewModel.updateComment(id: targetID, comment: "new")

        wait(for: [updateExp], timeout: 1.0)
        XCTAssertEqual(
            receivedAfterComment,
            [updatedDTO, unchanged],
            "Ожидали, что список обновится так, что первый элемент — updatedDTO, второй — unchanged"
        )
    }

    // MARK: - updateComment – ошибка сети: onError вызывается
    func testUpdateComment_Failure_CallsOnError() {
        let someID = UUID()
        let expectedErr = NSError(domain: "TestDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        networkMock.nextUpdateError = expectedErr

        let errorExp = expectation(description: "onError after updateComment failure")
        viewModel.onDocumentsChanged = nil
        viewModel.onError = { errMsg in
            XCTAssertEqual(errMsg, expectedErr.localizedDescription,
                           "Ожидали, что onError получит «\(expectedErr.localizedDescription)»")
            errorExp.fulfill()
        }

        viewModel.updateComment(id: someID, comment: "new")

        wait(for: [errorExp], timeout: 1.0)
    }

    // MARK: - toggleFavorite – успешный путь: onDocumentsChanged с обновлённым полем isFavorite
    func testToggleFavorite_Success_UpdatesLocalAndCallsOnDocumentsChanged() {
        let targetID = UUID()
        
        let original = DocumentDTO(
            id: targetID,
            fileName: "Doc.pdf",
            fileURL: "u",
            fileType: "wav",
            createTime: "t",
            comment: nil,
            isFavorite: false,
            artistName: "A",
            artistNickname: "A1",
            compositionName: "C1",
            price: "1"
        )
        
        let other = DocumentDTO(
            id: UUID(),
            fileName: "Other.pdf",
            fileURL: "u2",
            fileType: "mp3",
            createTime: "t2",
            comment: nil,
            isFavorite: false,
            artistName: "B",
            artistNickname: "B1",
            compositionName: "C2",
            price: "2"
        )
        
        networkMock.nextDocuments = [original, other]
        let initialFetchExp = expectation(description: "initial fetch")
        viewModel.onDocumentsChanged = { _ in initialFetchExp.fulfill() }
        viewModel.onError = { _ in XCTFail("onError не должен вызываться при fetch") }
        viewModel.fetchDocuments(showingFavoritesOnly: false, filter: nil)
        wait(for: [initialFetchExp], timeout: 1.0)

        let updatedDTO = DocumentDTO(
            id: targetID,
            fileName: "Doc.pdf",
            fileURL: "u",
            fileType: "wav",
            createTime: "t",
            comment: nil,
            isFavorite: true,
            artistName: "A",
            artistNickname: "A1",
            compositionName: "C1",
            price: "1"
        )
        networkMock.nextUpdatedDocument = updatedDTO

        let toggleExp = expectation(description: "onDocumentsChanged after toggleFavorite")
        var receivedAfterToggle: [DocumentDTO]?

        viewModel.onDocumentsChanged = { docs in
            receivedAfterToggle = docs
            toggleExp.fulfill()
        }
        viewModel.onError = { _ in XCTFail("onError не должен вызываться при toggleFavorite") }

        viewModel.toggleFavorite(id: targetID, isFavorite: true)

        wait(for: [toggleExp], timeout: 1.0)
        XCTAssertEqual(
            receivedAfterToggle,
            [updatedDTO, other],
            "Ожидали, что первый элемент — updatedDTO (isFavorite=true), второй — other"
        )
    }

    // MARK: - toggleFavorite – ошибка сети: onError вызывается
    func testToggleFavorite_Failure_CallsOnError() {
        let someID = UUID()
        let expectedErr = NSError(domain: "TestDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found"])
        networkMock.nextUpdateError = expectedErr

        let errorExp = expectation(description: "onError after toggleFavorite failure")
        viewModel.onDocumentsChanged = nil
        viewModel.onError = { errMsg in
            XCTAssertEqual(errMsg, expectedErr.localizedDescription,
                           "Ожидали, что onError получит «\(expectedErr.localizedDescription)»")
            errorExp.fulfill()
        }

        viewModel.toggleFavorite(id: someID, isFavorite: false)

        wait(for: [errorExp], timeout: 1.0)
    }
}
