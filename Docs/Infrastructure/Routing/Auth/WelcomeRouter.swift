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
    private let container: AuthProtocol

    init(navigationController: UINavigationController, container: AuthProtocol) {
        self.navigationController = navigationController
        self.container = container
    }

    func navigateToLogin() {
        let loginVC = container.makeLoginController()
        navigationController.pushViewController(loginVC, animated: true)
    }
}
