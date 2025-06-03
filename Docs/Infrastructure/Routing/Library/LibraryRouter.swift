//
//  LibraryRouter.swift
//  generator
//
//  Created by Матвей on 14.05.2025.
//

import UIKit
import QuickLook

// MARK: - Router Protocol

protocol LibraryRouterProtocol: AnyObject {
    func showPreview(for document: DocumentDTO, from transitionView: UIView)
    func share(document: DocumentDTO)
    func showInfo(for document: DocumentDTO)
    
    func confirmDelete(
        document: DocumentDTO,
        onConfirm: @escaping () -> Void,
        onCancel:  @escaping () -> Void
    )
    
    func presentCommentOptions(
        document: DocumentDTO,
        initialText: String,
        onEdit:        @escaping () -> Void,
        onDeleteComment: @escaping () -> Void,
        onCancel:      @escaping () -> Void
    )
    
    func presentCommentEditor(
        initialText: String,
        for document: DocumentDTO,
        onSave: @escaping (String) -> Void
    )
    
    func presentAlert(title: String, message: String?)
}

// MARK: - Router Implementation

final class LibraryRouter: NSObject, LibraryRouterProtocol {
    
    weak var viewController: LibraryController?
    private var previewURL: URL?
    private weak var transitionView: UIView?

    private let container: DocumentProtocol
    
    init(container: DocumentProtocol) {
        self.container = container
    }
    
    // MARK: - Preview
    func showPreview(for document: DocumentDTO, from transitionView: UIView) {
        // Формируем локальный URL по имени файла
        let url = FileManager.pdfLibraryURL.appendingPathComponent(document.fileName)
        self.previewURL = url
        self.transitionView = transitionView
        
        let ql = QLPreviewController()
        ql.dataSource = self
        ql.delegate   = self
        ql.currentPreviewItemIndex = 0
        ql.modalPresentationStyle = .fullScreen
        ql.view.tintColor = UIColor(hex: "5E5CE7")
        
        viewController?.present(ql, animated: true)
    }

    // MARK: - Share

    func share(document: DocumentDTO) {
        let url = FileManager.pdfLibraryURL.appendingPathComponent(document.fileName)
        let activity = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        viewController?.present(activity, animated: true)
    }

    // MARK: - Info

    func showInfo(for document: DocumentDTO) {
        let name = document.fileName
        let url = FileManager.pdfLibraryURL
            .appendingPathComponent(name)
        
        // Считаем размер
        let sizeDesc: String = {
            guard let attrs = try? FileManager.default
                    .attributesOfItem(atPath: url.path),
                  let bytes = attrs[.size] as? UInt64
            else { return "" }
            return String(format: "%.0f KB", Double(bytes) / 1024)
        }()
        
        // Собираем модель для экрана инфо
        let info = DocumentInfo(
            fileURL: url,
            fileName: name,
            fileSizeDescription: sizeDesc,
            kind: "PDF document",
            createdRaw: document.createTime,
            type: document.fileType.capitalized,
            artistName:       document.artistName,
            artistNickname:   document.artistNickname,
            compositionName:  document.compositionName,
            price:            document.price
        )
        
        let infoVC = container.makeDocumentInfoController(info: info)
        let nav = UINavigationController(rootViewController: infoVC)
        nav.modalPresentationStyle = .pageSheet
        nav.modalTransitionStyle = .coverVertical
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
        }
        viewController?.present(nav, animated: true)
    }
    
    // MARK: - Delete Confirmation
    func confirmDelete(
        document: DocumentDTO,
        onConfirm: @escaping () -> Void,
        onCancel:  @escaping () -> Void
    ) {
        guard let vc = viewController else { return }
        let sheet = UIAlertController(
            title: nil,
            message: "Are you sure you want to delete this document? This action can’t be undone.",
            preferredStyle: .actionSheet
        )
        sheet.addAction(.init(title: "Delete", style: .destructive) { _ in onConfirm() })
        sheet.addAction(.init(title: "Cancel", style: .cancel)   { _ in onCancel()  })
        vc.present(sheet, animated: true)
    }

    // MARK: - Comment Options
    func presentCommentOptions(
        document: DocumentDTO,
        initialText: String,
        onEdit:        @escaping () -> Void,
        onDeleteComment: @escaping () -> Void,
        onCancel:      @escaping () -> Void
    ) {
        guard let vc = viewController else { return }
        if initialText.isEmpty {
            onEdit()
        } else {
            let sheet = UIAlertController(title: nil,
                                          message: nil,
                                          preferredStyle: .actionSheet)
            sheet.addAction(.init(title: "Edit Comment",    style: .default)    { _ in onEdit()         })
            sheet.addAction(.init(title: "Delete Comment",  style: .destructive) { _ in onDeleteComment() })
            sheet.addAction(.init(title: "Cancel",          style: .cancel)      { _ in onCancel()       })
            vc.present(sheet, animated: true)
        }
    }

    // MARK: - Comment Editor
    func presentCommentEditor(
        initialText: String,
        for document: DocumentDTO,
        onSave: @escaping (String) -> Void
    ) {
        guard let vc = viewController else { return }
        let alert = UIAlertController(
            title: initialText.isEmpty ? "Add Comment" : "Edit Comment",
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField {
            $0.placeholder = "Your Comment"
            $0.text = initialText
        }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Save", style: .default) { _ in
            let text = alert.textFields?.first?.text ?? ""
            onSave(text)
        })
        alert.view.tintColor = UIColor(hex: "5E5CE7")
        vc.present(alert, animated: true)
    }

    // MARK: - Generic Alert
    func presentAlert(title: String, message: String?) {
        guard let vc = viewController else { return }
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        vc.present(alert, animated: true)
    }
}

// MARK: - QLPreviewControllerDataSource & Delegate
extension LibraryRouter: QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        previewURL == nil ? 0 : 1
    }

    func previewController(_ controller: QLPreviewController,
                           previewItemAt index: Int) -> QLPreviewItem {
        previewURL! as NSURL
    }

    func previewController(_ controller: QLPreviewController,
                           transitionViewFor item: QLPreviewItem) -> UIView? {
        transitionView
    }

    func previewController(_ controller: QLPreviewController,
                           editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .updateContents
    }

    func previewController(_ controller: QLPreviewController,
                           didUpdateContentsOf previewItem: QLPreviewItem) {
        // при необходимости можно прокинуть уведомление в LibraryController
    }
}

