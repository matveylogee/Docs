//
//  DocumentInfoRouter.swift
//  generator
//
//  Created by Матвей on 20.05.2025.
//

import UIKit
import QuickLook

protocol DocumentInfoRouterProtocol: AnyObject {
    func presentPreview(from transitionView: UIView, fileURL: URL)
    func dismissInfo()
}

final class DocumentInfoRouter: NSObject, DocumentInfoRouterProtocol {
    
    weak var viewController: UIViewController?
    private var previewURL: URL?
    private weak var transitionView: UIView?

    func presentPreview(from transitionView: UIView, fileURL: URL) {
        guard let vc = viewController else { return }
        self.previewURL = fileURL
        self.transitionView = transitionView

        let ql = QLPreviewController()
        ql.dataSource = self
        ql.delegate   = self
        ql.currentPreviewItemIndex = 0
        ql.modalPresentationStyle = .fullScreen
        ql.view.tintColor = UIColor(hex: "#5E5CDF")
        vc.present(ql, animated: true)
    }

    func dismissInfo() {
        viewController?.dismiss(animated: true)
    }
}

// MARK: – QLPreviewController DataSource & Delegate
extension DocumentInfoRouter: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in _: QLPreviewController) -> Int { previewURL == nil ? 0 : 1 }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewURL! as NSURL
    }
    
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        transitionView
    }
    
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .updateContents
    }
    
    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        if let docVC = viewController as? DocumentInfoViewController {
            docVC.renderThumbnail()
        }
    }
}

