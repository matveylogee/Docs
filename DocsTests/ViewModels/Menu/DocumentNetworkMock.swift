import XCTest
@testable import Docs

final class DocumentViewModelTests: XCTestCase {

    private var viewModel: DocumentViewModel!
    private var networkMock: DocumentNetworkMock!
    private var currentDateMock: CurrentDateMock!

    private var tempDirectory: URL {
        return FileManager.default.temporaryDirectory
    }

    private var libraryURL: URL {
        return FileManager.pdfLibraryURL
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        if FileManager.default.fileExists(atPath: libraryURL.path) {
            try FileManager.default.removeItem(at: libraryURL)
        }
        try? FileManager.default.removeItem(at: tempDirectory.appendingPathComponent("TestNick TestComp.pdf"))

        networkMock = DocumentNetworkMock()
        currentDateMock = CurrentDateMock("01/01/23 12:00")
        viewModel = DocumentViewModel(network: networkMock, currentDate: currentDateMock)
    }

    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: libraryURL.path) {
            try FileManager.default.removeItem(at: libraryURL)
        }
        try? FileManager.default.removeItem(at: tempDirectory.appendingPathComponent("TestNick TestComp.pdf"))

        viewModel = nil
        networkMock = nil
        currentDateMock = nil
        try super.tearDownWithError()
    }

    // MARK: - previewDocument – успешный путь
    func testPreviewDocument_Success_CallsOnPreviewWithValidURL() {
        let fakeUser = UserPublic(
            id: UUID(),
            username: "ProducerName",
            email: "producer@example.com"
        )
        networkMock.nextUserPublic = fakeUser

        let previewExpectation = expectation(description: "onPreview called")
        var receivedURL: URL?

        viewModel.onPreview = { url in
            receivedURL = url
            previewExpectation.fulfill()
        }
        viewModel.onError = { errMsg in
            XCTFail("onError не должен вызываться, получили: \(errMsg)")
        }

        viewModel.previewDocument(
            name: "AnyName",
            nickname: "TestNick",
            composition: "TestComp",
            price: "5",
            experience: DocumentType.mp3
        )

        wait(for: [previewExpectation], timeout: 1.0)

        XCTAssertNotNil(receivedURL, "Ожидали, что onPreview будет вызван с URL, но получили nil")

        let expectedFileName = "TestNick TestComp.pdf"
        let expectedTempURL = tempDirectory.appendingPathComponent(expectedFileName)
        XCTAssertEqual(
            receivedURL?.lastPathComponent,
            expectedFileName,
            "Ожидали, что файл называется \(expectedFileName), получили \(String(describing: receivedURL?.lastPathComponent))"
        )
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: expectedTempURL.path),
            "Ожидали, что PDF-файл будет создан во временной директории по пути \(expectedTempURL.path)"
        )
    }

    // MARK: - previewDocument – ошибка сети
    func testPreviewDocument_NetworkError_CallsOnError() {
        let expectedError = NSError(
            domain: "TestDomain",
            code: 123,
            userInfo: [NSLocalizedDescriptionKey: "No connection"]
        )
        networkMock.nextError = expectedError

        let errorExpectation = expectation(description: "onError called")
        viewModel.onSuccess = nil
        viewModel.onPreview = { _ in
            XCTFail("onPreview не должен вызываться при ошибке сети")
        }
        viewModel.onError = { errMsg in
            XCTAssertEqual(
                errMsg,
                expectedError.localizedDescription,
                "Ожидали, что onError получит «\(expectedError.localizedDescription)», но получили «\(errMsg)»"
            )
            errorExpectation.fulfill()
        }

        viewModel.previewDocument(
            name: "AnyName",
            nickname: "TestNick",
            composition: "TestComp",
            price: "5",
            experience: DocumentType.mp3
        )

        wait(for: [errorExpectation], timeout: 1.0)
    }

    // MARK: - saveDocument – успешный путь
    func testSaveDocument_Success_CallsOnSuccessAndCopiesToLibrary() {
        let fakeUser = UserPublic(
            id: UUID(),
            username: "ProducerName",
            email: "producer@example.com"
        )
        networkMock.nextUserPublic = fakeUser

        let uploadedDto = DocumentDTO(
            id: UUID(),
            fileName:       "TestNick TestComp.pdf",
            fileURL:        "https://server/files/TestNick%20TestComp.pdf",
            fileType:       "mp3",
            createTime:     "01/01/23 12:00",
            comment:        "some comment",
            isFavorite:     true,
            artistName:     "AnyName",
            artistNickname: "TestNick",
            compositionName:"TestComp",
            price:          "5"
        )
        networkMock.nextUploadedDocument = uploadedDto

        let successExpectation = expectation(description: "onSuccess called")
        var receivedDto: DocumentDTO?

        viewModel.onSuccess = { dto in
            receivedDto = dto
            successExpectation.fulfill()
        }
        viewModel.onError = { errMsg in
            XCTFail("onError не должен вызываться, получили: \(errMsg)")
        }

        viewModel.saveDocument(
            name: "AnyName",
            nickname: "TestNick",
            composition: "TestComp",
            price: "5",
            comment: "some comment",
            isFavorite: true,
            experience: DocumentType.mp3
        )

        wait(for: [successExpectation], timeout: 2.0)

        XCTAssertEqual(
            receivedDto,
            uploadedDto,
            "Ожидали, что onSuccess будет вызван с тем же DocumentDTO, который mock вернул"
        )

        let libraryFileURL = libraryURL.appendingPathComponent("TestNick TestComp.pdf")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: libraryFileURL.path),
            "Ожидали, что PDF-файл окажется в библиотеке по пути \(libraryFileURL.path)"
        )
    }

    // MARK: - saveDocument – ошибка при запросе «/me»
    func testSaveDocument_RequestMeError_CallsOnError() {
        let expectedError = NSError(
            domain: "TestDomain",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Server down"]
        )
        networkMock.nextError = expectedError

        let errorExpectation = expectation(description: "onError called for request failure")
        var receivedError: String?

        viewModel.onSuccess = nil
        viewModel.onPreview = nil
        viewModel.onError = { errMsg in
            receivedError = errMsg
            errorExpectation.fulfill()
        }

        viewModel.saveDocument(
            name: "AnyName",
            nickname: "TestNick",
            composition: "TestComp",
            price: "5",
            comment: nil,
            isFavorite: false,
            experience: DocumentType.mp3
        )

        wait(for: [errorExpectation], timeout: 1.0)
        XCTAssertEqual(
            receivedError,
            expectedError.localizedDescription,
            "Ожидали, что onError получит «\(expectedError.localizedDescription)»"
        )
    }

    // MARK: - saveDocument – ошибка при записи PDF во temp-файл
    func testSaveDocument_PDFWriteFailure_CallsOnError() {
        let fakeUser = UserPublic(
            id: UUID(),
            username: "ProducerName",
            email: "producer@example.com"
        )
        networkMock.nextUserPublic = fakeUser

        let errorExpectation = expectation(description: "onError called for pdf write failure")
        var receivedErrorMsg: String?

        viewModel.onSuccess = nil
        viewModel.onPreview = nil
        viewModel.onError = { errMsg in
            receivedErrorMsg = errMsg
            errorExpectation.fulfill()
        }

        let badNickname = "Bad/Name"

        viewModel.saveDocument(
            name: "AnyName",
            nickname: badNickname,
            composition: "TestComp",
            price: "5",
            comment: nil,
            isFavorite: false,
            experience: DocumentType.mp3
        )

        wait(for: [errorExpectation], timeout: 1.0)
        XCTAssertNotNil(receivedErrorMsg)
        XCTAssertTrue(
            receivedErrorMsg?.starts(with: "Не удалось сохранить PDF во временный файл:") ?? false,
            "Ожидали, что сообщение начнётся с «Не удалось сохранить PDF во временный файл:», получили: \(String(describing: receivedErrorMsg))"
        )
    }
}
