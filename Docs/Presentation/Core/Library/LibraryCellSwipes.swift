//
//  LibraryCellSwipes.swift
//  generator
//
//  Created by Матвей on 30.05.2025.
//

import UIKit

extension LibraryController {
    
    // MARK: - Right Swipe
    func tableView(_ tv: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let dto = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let id = dto.id
        
        // MARK: - Delete
        let trashImg = UIImage(
            systemName: "trash",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        )?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _,_, done in
            self.router.confirmDelete(
                document: dto,
                onConfirm: { self.viewModel.deleteDocument(id: id) },
                onCancel: {}
            )
            done(true)
        }
        delete.image = trashImg
        delete.backgroundColor = UIColor(hex: "E95443")
        
        // MARK: - Comment
        let commentImg = UIImage(
            systemName: "text.bubble",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        )?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        
        let comment = UIContextualAction(style: .normal, title: "Comment") { _,_, done in
            let existing = dto.comment ?? ""
            self.router.presentCommentOptions(
                document: dto,
                initialText: existing,
                onEdit: {
                    self.router.presentCommentEditor(
                        initialText: existing,
                        for: dto
                    ) { newText in
                        self.viewModel.updateComment(id: id, comment: newText)
                    }
                },
                onDeleteComment: {
                    self.viewModel.updateComment(id: id, comment: "")
                },
                onCancel: {}
            )
            done(true)
        }
        comment.image = commentImg
        comment.backgroundColor = UIColor(hex: "5E5CDF")
        
        let cfg = UISwipeActionsConfiguration(actions: [delete, comment])
        cfg.performsFirstActionWithFullSwipe = true
        
        return cfg
    }
    
    // MARK: -  Left Swipe (Toggle Favorite)
    func tableView(_ tv: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let dto = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let id = dto.id
        let willFav = !dto.isFavorite
        
        let favImg = UIImage(
            systemName: willFav ? "bookmark" : "bookmark.slash",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        )?
        .withTintColor(.white, renderingMode: .alwaysOriginal)
        
        let fav = UIContextualAction(style: .normal,
                                     title: willFav ? "Add Favorite" : "Remove Favorite") { _,_, done in
            self.viewModel.toggleFavorite(id: id, isFavorite: willFav)
            done(true)
        }
        fav.image = favImg
        fav.backgroundColor = UIColor(hex: "EC7064")
        
        let cfg = UISwipeActionsConfiguration(actions: [fav])
        cfg.performsFirstActionWithFullSwipe = true
        return cfg
    }
}
