//
//  DocumentViewModel.swift
//  generator
//
//  Created by Матвей on 25.05.2025.
//

import Foundation

protocol DocumentViewModelProtocol: AnyObject {
    var onSuccess: ((DocumentDTO) -> Void)? { get set }
    var onError:   ((String) -> Void)?      { get set }
    var onPreview: ((URL) -> Void)?         { get set }

    func saveDocument(
        name: String,
        nickname: String,
        composition: String,
        price: String,
        comment: String?,
        isFavorite: Bool,
        experience: DocumentType
    )

    func previewDocument(
        name: String,
        nickname: String,
        composition: String,
        price: String,
        experience: DocumentType
    )
}

final class DocumentViewModel: DocumentViewModelProtocol {
    
    // MARK: - Dependencies
    private let network: NetworkServiceProtocol
    private let currentDate: CurrentDateProtocol
    
    // MARK: - Init
    init(network: NetworkServiceProtocol, currentDate: CurrentDateProtocol) {
        self.network = network
        self.currentDate = currentDate
    }

    // MARK: - Callbacks
    var onSuccess: ((DocumentDTO) -> Void)?
    var onError: ((String) -> Void)?
    var onPreview: ((URL) -> Void)?

    // MARK: - Save
    func saveDocument(
        name: String,
        nickname: String,
        composition: String,
        price: String,
        comment: String?,
        isFavorite: Bool,
        experience: DocumentType
    ) {
        Task {
            do {
                let user: UserPublic = try await network.request(
                    endpoint: UserEndpoint.me,
                    requestDTO: EmptyRequest()
                )
                
                let fileName = "\(nickname) \(composition).pdf"
                
                let pdfData = PDFCreator(
                    producerName: user.username,
                    name: name,
                    nickname: nickname,
                    composition: composition,
                    price: price,
                    experience: experience
                ).pdfCreateData(fileName: fileName)
                
                let tmpURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(fileName)
                do {
                    if FileManager.default.fileExists(atPath: tmpURL.path) {
                        try FileManager.default.removeItem(at: tmpURL)
                    }
                    try pdfData.write(to: tmpURL, options: .atomic)
                } catch {
                    onError?("Не удалось сохранить PDF во временный файл: \(error.localizedDescription)")
                    return
                }
                
                let dto = CreateDocumentRequest(
                    fileType:    experience.rawValue,
                    createTime:  currentDate.pdfCreateTimestamp(),
                    artistName:      name,
                    artistNickname:  nickname,
                    compositionName: composition,
                    price:            price,
                    comment:          comment,
                    isFavorite:       isFavorite
                )
                
                let uploaded = try await network.uploadDocument(fileURL: tmpURL, metadata: dto)
                
                do {
                    let libraryFolder = FileManager.pdfLibraryURL
                    let libraryURL = libraryFolder.appendingPathComponent(uploaded.fileName)
                    
                    try FileManager.default.createDirectory(
                        at: libraryFolder,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    
                    if FileManager.default.fileExists(atPath: libraryURL.path) {
                        try FileManager.default.removeItem(at: libraryURL)
                    }
                    try FileManager.default.copyItem(at: tmpURL, to: libraryURL)
                } catch {
                    print("⚠️ Не удалось скопировать PDF в библиотеку: \(error.localizedDescription)")
                }
                
                onSuccess?(uploaded)
                
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }

    // MARK: - Preview
    func previewDocument(
        name: String,
        nickname: String,
        composition: String,
        price: String,
        experience: DocumentType
    ) {
        Task {
            do {
                let user: UserPublic = try await network.request(
                    endpoint: UserEndpoint.me,
                    requestDTO: EmptyRequest()
                )
                
                let previewFileName = "\(nickname) \(composition).pdf"
                
                let pdfData = PDFCreator(
                    producerName: user.username,
                    name: name,
                    nickname: nickname,
                    composition: composition,
                    price: price,
                    experience: experience
                ).pdfCreateData(fileName: previewFileName)
                
                let tmpPreviewURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(previewFileName)
                
                do {
                    if FileManager.default.fileExists(atPath: tmpPreviewURL.path) {
                        try FileManager.default.removeItem(at: tmpPreviewURL)
                    }
                    try pdfData.write(to: tmpPreviewURL, options: .atomic)
                    onPreview?(tmpPreviewURL)
                } catch {
                    onError?("Не удалось создать превью PDF: \(error.localizedDescription)")
                }
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }
}
