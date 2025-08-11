//
//  MainContainer.swift
//  Docs
//
//  Created by Матвей on 11.08.2025.
//

import UIKit

protocol MainContainerProtocol: AnyObject {
    func makeTabController() -> UITabBarController
}

final class MainContainer: MainContainerProtocol {
    private let services: AppServices
    private weak var root: AppRootContainer?

    // child containers (one per feature/tab)
    private lazy var menuContainer: MenuContainer = {
        MenuContainer(services: services, parent: self)
    }()

    private lazy var libraryContainer: LibraryContainer = {
        LibraryContainer(services: services, parent: self)
    }()

    private lazy var settingsContainer: SettingsContainer = {
        SettingsContainer(services: services, parent: self)
    }()

    init(services: AppServices, root: AppRootContainer) {
        self.services = services
        self.root = root
    }

    func makeTabController() -> UITabBarController {
        let tab = UITabBarController()
        tab.viewControllers = [menuContainer.makeNavController(),
                               libraryContainer.makeNavController(),
                               settingsContainer.makeNavController()]
        tab.tabBar.tintColor = .white
        return tab
    }
}
