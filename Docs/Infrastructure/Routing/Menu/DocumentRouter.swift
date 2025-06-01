//
//  DocumentRouter.swift
//  generator
//
//  Created by Матвей on 17.05.2025.
//

import UIKit
import QuickLook

protocol DocumentRouterProtocol: AnyObject {
    func presentPreview(from transitionView: UIView, pdfURL: URL)
    func confirmSave(onConfirm: @escaping () -> Void)
    func finishSaving()
    func confirmExitAndPop()
}

final class DocumentRouter: NSObject, DocumentRouterProtocol {
    
    weak var viewController: UIViewController?
    private let container: DocumentProtocol
    
    private var previewURL: URL?
    private weak var transitionView: UIView?
    
    init(container: DocumentProtocol) {
        self.container = container
    }
    
    // MARK: - Preview
    func presentPreview(from transitionView: UIView, pdfURL: URL) {
        guard let vc = viewController else { return }
        self.previewURL = pdfURL
        self.transitionView = transitionView
        
        let ql = QLPreviewController()
        ql.dataSource = self
        ql.delegate   = self
        ql.currentPreviewItemIndex = 0
        ql.modalPresentationStyle = .fullScreen
        ql.view.tintColor = UIColor(hex: "5E5CE7")
        
        vc.present(ql, animated: true)
    }

    // MARK: - Save
    func confirmSave(onConfirm: @escaping () -> Void) {
        guard let vc = viewController else { return }
        let alert = UIAlertController(
            title: "Save document?",
            message: "Документ будет добавлен в библиотеку",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Save", style: .default) { _ in onConfirm() })
        vc.present(alert, animated: true)
    }

    func finishSaving() {
        guard let vc = viewController else { return }
        vc.navigationController?.popToRootViewController(animated: true)
        
        let toast = UIAlertController(
            title: "The document has been saved to the Library",
            message: nil,
            preferredStyle: .alert
        )
        vc.present(toast, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            toast.dismiss(animated: true)
        }
    }

    // MARK: - Exit
    func confirmExitAndPop() {
        guard let vc = viewController else { return }
        let ac = UIAlertController(
            title: "Вы уверены?",
            message: "Данные сотрутся",
            preferredStyle: .alert
        )
        ac.addAction(.init(title: "Отмена", style: .cancel))
        ac.addAction(.init(title: "Хорошо", style: .default) { _ in
            vc.navigationController?.popViewController(animated: true)
        })
        vc.present(ac, animated: true)
    }
}

// MARK: - QLPreviewControllerDataSource & Delegate
extension DocumentRouter: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        previewURL == nil ? 0 : 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
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
        // сюда можно проставить необходимость апдейта модели
    }
}
