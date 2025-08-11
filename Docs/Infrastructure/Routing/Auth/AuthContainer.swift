//
//  AuthContainer.swift
//  Docs
//
//  Created by Матвей on 11.08.2025.
//

import UIKit

final class AuthContainer: LoginFactory, RegistrationFactory {
    private let navigationController: UINavigationController
    private let services: AppServices
    private weak var root: AppRootContainer?

    //MARK: - Routers
    private lazy var welcomeRouter: WelcomeRouterProtocol = {
        WelcomeRouter(navigationController: navigationController, loginFactory: self)
    }()

    private lazy var loginRouter: LoginRouterProtocol = {
        LoginRouter(
            navigationController: navigationController,
            registrationFactory: self,
            onLoginSuccess: { [weak root] in root?.showMain() }
        )
    }()

    private lazy var registrationRouter: RegistrationRouterProtocol = {
        RegistrationRouter()
    }()

    init(navigationController: UINavigationController, services: AppServices, root: AppRootContainer) {
        self.navigationController = navigationController
        self.services = services
        self.root = root
    }

    func startAuthFlow() {
        let welcomeVC = WelcomeViewController(router: welcomeRouter)
        navigationController.setViewControllers([welcomeVC], animated: false)
    }

    //MARK: - Factories
    func makeLoginController() -> UIViewController {
        let vm = LoginViewModel(network: services.networkService,
                                tokenProvider: services.tokenProvider,
                                keychain: services.keychainService)
        let vc = LoginViewController(viewModel: vm, router: loginRouter)
        return vc
    }

    func makeRegistrationViewController() -> UIViewController {
        let vm = RegistrationViewModel(network: services.networkService, keychain: services.keychainService)
        let vc = RegistrationViewController(viewModel: vm, router: registrationRouter)
        return vc
    }
}
