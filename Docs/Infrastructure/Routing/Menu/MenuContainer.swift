//
//  MenuContainer.swift
//  Docs
//
//  Created by Матвей on 11.08.2025.
//

import UIKit

final class MenuContainer {
    private let services: AppServices
    private weak var parent: MainContainer?

    init(services: AppServices, parent: MainContainer) {
        self.services = services
        self.parent = parent
    }

    func makeNavController() -> UINavigationController {
        let router = MenuRouter(documentFactory: self)
        let menuVC = MenuViewController(menuRouter: router)
        router.viewController = menuVC
        let nav = UINavigationController(rootViewController: menuVC)
        nav.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(systemName: "house"), tag: 0)
        return nav
    }
}

extension MenuContainer: DocumentFactory {
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
