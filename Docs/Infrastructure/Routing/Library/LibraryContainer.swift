//
//  LibraryContainer.swift
//  Docs
//
//  Created by Матвей on 11.08.2025.
//

import UIKit

protocol DocumentFactory: AnyObject {
    func makeDocumentController(fileType: DocumentType) -> UIViewController
    func makeDocumentInfoController(info: DocumentInfo) -> UIViewController
}

final class LibraryContainer {
    private let services: AppServices
    private weak var parent: MainContainer?

    init(services: AppServices, parent: MainContainer) {
        self.services = services
        self.parent = parent
    }

    func makeNavController() -> UINavigationController {
        let vm = LibraryViewModel(network: services.networkService, dateService: services.dateService)
        let router = LibraryRouter(documentFactory: self)
        let libraryVC = LibraryController(viewModel: vm, router: router)
        router.viewController = libraryVC
        let nav = UINavigationController(rootViewController: libraryVC)
        nav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "rectangle.stack.fill"), tag: 1)
        return nav
    }
}

extension LibraryContainer: DocumentFactory {
    func makeDocumentController(fileType: DocumentType) -> UIViewController {
        let vm = DocumentViewModel(network: services.networkService, currentDate: services.dateService)
        let router = DocumentRouter()
        let vc = DocumentController(viewModel: vm, router: router, fileType: fileType)
        router.viewController = vc
        vc.hidesBottomBarWhenPushed = true
        return vc
    }

    func makeDocumentInfoController(info: DocumentInfo) -> UIViewController {
        let router = DocumentInfoRouter()
        let vc = DocumentInfoViewController(info: info, dateService: services.dateService, router: router)
        router.viewController = vc
        return vc
    }
}
