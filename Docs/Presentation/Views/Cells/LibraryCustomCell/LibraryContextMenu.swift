//
//  LibraryContextMenu.swift
//  generator
//
//  Created by Матвей on 11.05.2025.
//

import UIKit

// MARK: - ContextMenu
extension LibraryCustomCell: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                              configurationForMenuAtLocation location: CGPoint)
    -> UIContextMenuConfiguration? {
    guard let file = dto else { return nil }

    return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in

      let share = UIAction(title: "Share",
                           image: UIImage(systemName: "square.and.arrow.up")) { _ in
          self.delegate?.shareCellTapped(file)
      }
        
        let quickLook = UIAction(title: "Quick Look", image: UIImage(systemName: "doc.text.magnifyingglass")) { [weak self] _ in
            guard let self = self, let file = self.dto else { return }
            DispatchQueue.main.async {
                self.delegate?.previewCellTapped(file, from: self.pdfIconView)
            }
        }
        
        let info = UIAction(title: "Get Info", image: UIImage(systemName: "info.circle")) { _ in
            self.delegate?.getInfoTapped(file)
        }
        
        let group1 = UIMenu(title: "", options: .displayInline, children: [share, quickLook, info])

        let favTitle = file.isFavorite ? "Remove From Favourites" : "Add To Favourite"
        let favIcon  = UIImage(systemName: file.isFavorite ? "bookmark.slash" : "bookmark")
        let favAction = UIAction(title: favTitle, image: favIcon) { _ in
            self.delegate?.toggleFavoriteTapped(file)
        }
      let groupFav = UIMenu(title: "", options: .displayInline, children: [favAction])

      /// Комментарии
      let existing = file.comment ?? ""
      var commentChildren: [UIMenuElement]
      if existing.isEmpty {
        let add = UIAction(title: "Add Comment",
                           image: UIImage(systemName: "text.bubble")) { _ in
          self.delegate?.addCommentTapped(file)
        }
        commentChildren = [add]
      } else {
        let view = UIAction(title: "View Comment",
                            image: UIImage(systemName: "eye")) { _ in
          self.delegate?.showCommentTapped(file)
        }
        let edit = UIAction(title: "Edit",
                            image: UIImage(systemName: "pencil")) { _ in
          self.delegate?.editCommentTapped(file)
        }
        let delC = UIAction(title: "Delete",
                            image: UIImage(systemName: "trash.slash"),
                            attributes: .destructive) { _ in
          self.delegate?.deleteCommentTapped(file)
        }
        let submenu = UIMenu(title: "Comment",
                             image: UIImage(systemName: "text.bubble"),
                             children: [edit, delC])
        commentChildren = [view, submenu]
      }
      let group2 = UIMenu(title: "", options: .displayInline, children: commentChildren)

      /// Удаление файла
      let deleteFile = UIAction(title: "Delete",
                                image: UIImage(systemName: "trash"),
                                attributes: .destructive) { _ in
        self.delegate?.deleteCell(file)
      }
      let group3 = UIMenu(title: "", options: .displayInline, children: [deleteFile])

      return UIMenu(title: "", children: [group1, groupFav, group2, group3])
    }
  }
}
