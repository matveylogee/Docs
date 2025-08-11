//
//  AppRootContainer.swift
//  Docs
//
//  Created by Матвей on 11.08.2025.
//

import UIKit

protocol LoginFactory: AnyObject {
    func makeLoginController() -> UIViewController
}

protocol RegistrationFactory: AnyObject {
    func makeRegistrationViewController() -> UIViewController
}

// Владеет сервисами и создаёт фичевые контейнеры
final class AppRootContainer {
    private let window: UIWindow
    private var services: AppServices

    private var authContainer: AuthContainer?
    private var mainContainer: MainContainer?

    init(window: UIWindow) {
        self.window = window
        self.services = AppServices()
    }

    func start() {
        if let token = try? services.keychainService.fetch(.authToken), !token.isEmpty {
            showMain()
        } else {
            showAuth()
        }
    }

    // MARK: - Show containers
    func showAuth() {
        self.mainContainer = nil

        let nav = UINavigationController()
        let auth = AuthContainer(navigationController: nav, services: services, root: self)
        self.authContainer = auth
        window.rootViewController = nav
        auth.startAuthFlow()
    }

    func showMain() {
        self.authContainer = nil

        let main = MainContainer(services: services, root: self)
        self.mainContainer = main
        window.rootViewController = main.makeTabController()
    }

    func resetToAuth() {
        self.mainContainer = nil
        self.services = AppServices()
        showAuth()
    }
}
