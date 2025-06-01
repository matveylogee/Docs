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
                let user: UserPublic = try await network.request(endpoint: UserEndpoint.me, requestDTO: EmptyRequest())
                
                /// Генерация PDF в Data
                let baseName = "\(name) \(composition)"
                let fileName = baseName + ".pdf"
                let pdfData  = PDFCreator(
                    producerName: user.username,
                    name: name,
                    nickname: nickname,
                    composition: composition,
                    price: price,
                    experience: experience
                ).pdfCreateData(fileName: fileName)
                
                /// Сохраняем во временный файл
                let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "_\(fileName)")
                do {
                    try pdfData.write(to: tmpURL, options: .atomic)
                } catch {
                    onError?("Не удалось сохранить во временный файл")
                    return
                }
                
                /// DTO для бэка
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
                
                /// Асинхронная загрузка + копирование в локальную библиотеку
                let uploaded = try await network.uploadDocument(fileURL: tmpURL, metadata: dto)
                
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
                let user: UserPublic = try await network.request(endpoint: UserEndpoint.me, requestDTO: EmptyRequest())
                
                let fileName = "\(name)_\(composition).pdf"
                let pdfData  = PDFCreator(
                    producerName: user.username,
                    name: name,
                    nickname: nickname,
                    composition: composition,
                    price: price,
                    experience: experience
                ).pdfCreateData(fileName: fileName)
                
                let tmpURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".pdf")
                do {
                    try pdfData.write(to: tmpURL, options: .atomic)
                    onPreview?(tmpURL)
                } catch {
                    onError?("Не удалось создать превью PDF")
                }
            }
        }
    }
}
