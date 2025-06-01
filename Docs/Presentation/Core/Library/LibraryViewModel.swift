//
//  LibraryViewModel.swift
//  generator
//
//  Created by Матвей on 25.05.2025.
//

import Foundation

protocol LibraryViewModelProtocol: AnyObject {
    var onDocumentsChanged: (([DocumentDTO]) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    var dateService: CurrentDateProtocol { get }
    
    func fetchDocuments(showingFavoritesOnly: Bool, filter: String?)
    func deleteDocument(id: UUID)
    func updateComment(id: UUID, comment: String)
    func toggleFavorite(id: UUID, isFavorite: Bool)
}

final class LibraryViewModel: LibraryViewModelProtocol {
    
    // MARK: - Dependencies
    private let network: NetworkServiceProtocol
    internal let dateService: CurrentDateProtocol
    
    init(network: NetworkServiceProtocol, dateService: CurrentDateProtocol) {
        self.network = network
        self.dateService = dateService
    }
    
    // MARK: - Callbacks
    var onDocumentsChanged: (([DocumentDTO]) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Internal state
    /// весь список, полученный с бэка
    private var allDocuments: [DocumentDTO] = []
    
    // MARK: - Fetch
    func fetchDocuments(showingFavoritesOnly: Bool, filter: String?) {
        Task {
            do {
                let docs = try await network.listDocuments()
                self.allDocuments = docs
                // примени фильтры
                var result = docs
                if showingFavoritesOnly {
                    result = result.filter { $0.isFavorite }
                }
                if let q = filter?.lowercased(), !q.isEmpty {
                    result = result.filter { $0.fileName.lowercased().contains(q) }
                }
                onDocumentsChanged?(result)
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Delete
    func deleteDocument(id: UUID) {
        Task {
            do {
                try await network.deleteDocument(id: id)
                // убираем из локального массива
                allDocuments.removeAll { $0.id == id }
                onDocumentsChanged?(allDocuments)
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Comment
    func updateComment(id: UUID, comment: String) {
        Task {
            do {
                let updated = try await network.updateDocument(
                    id: id,
                    update: UpdateDocumentRequest(comment: comment, isFavorite: nil)
                )
                if let idx = allDocuments.firstIndex(where: { $0.id == updated.id }) {
                    allDocuments[idx] = updated
                    onDocumentsChanged?(allDocuments)
                }
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Favorite
    func toggleFavorite(id: UUID, isFavorite: Bool) {
        Task {
            do {
                let updated = try await network.updateDocument(
                    id: id,
                    update: UpdateDocumentRequest(comment: nil, isFavorite: isFavorite)
                )
                if let idx = allDocuments.firstIndex(where: { $0.id == updated.id }) {
                    allDocuments[idx] = updated
                    onDocumentsChanged?(allDocuments)
                }
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }
}
