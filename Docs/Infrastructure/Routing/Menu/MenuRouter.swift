//
//  MenuRouter.swift
//  generator
//
//  Created by Матвей on 21.03.2025.
//

import UIKit

protocol MenuRouterProtocol: AnyObject {
    func navigateToDocument(fileType: DocumentType)
    func navigateToInfo()
}

final class MenuRouter: MenuRouterProtocol {
    
    weak var viewController: UIViewController?
    private let container: DocumentProtocol

    init(container: DocumentProtocol) {
        self.container = container
    }

    func navigateToDocument(fileType: DocumentType) {
        let documentVC = container.makeDocumentController(fileType: fileType)
        viewController?.navigationController?.pushViewController(documentVC, animated: true)
    }

    func navigateToInfo() {
        let infoVC = MainLicensesInfoViewController()
        let nav = UINavigationController(rootViewController: infoVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController { sheet.detents = [.large()] }  
        viewController?.present(nav, animated: true)
    }

}
