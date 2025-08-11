//
//  WelcomeRouter.swift
//  generator
//
//  Created by Матвей on 14.05.2025.
//

import UIKit

protocol WelcomeRouterProtocol: AnyObject {
    func navigateToLogin()
}

final class WelcomeRouter: WelcomeRouterProtocol {
    
    private let navigationController: UINavigationController
    private let loginFactory: LoginFactory

    init(navigationController: UINavigationController, loginFactory: LoginFactory) {
        self.navigationController = navigationController
        self.loginFactory = loginFactory
    }

    func navigateToLogin() {
        let loginVC = loginFactory.makeLoginController()
        navigationController.pushViewController(loginVC, animated: true)
    }
}
