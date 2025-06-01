//
//  LoginRouter.swift
//  generator
//
//  Created by Матвей on 14.05.2025.
//

import UIKit

protocol LoginRouterProtocol: AnyObject {
    func navigateToMenu(from viewController: UIViewController)
    func navigateToRegistration(from viewController: UIViewController)
    func showAlert(message: String, from viewController: UIViewController)
}

final class LoginRouter: LoginRouterProtocol {
    
    private let container: AuthProtocol

    init(container: AuthProtocol) {
        self.container = container
    }
    
    func navigateToMenu(from viewController: UIViewController) {
        guard let nav = viewController.navigationController else { return }
        let tabBarController = container.makeTabController()
        nav.setNavigationBarHidden(true, animated: false)
        nav.pushViewController(tabBarController, animated: true)
    }
    
    func navigateToRegistration(from viewController: UIViewController) {
        let signUpController = container.makeRegistrationViewController()
        let nav = UINavigationController(rootViewController: signUpController)
        nav.setNavigationBarHidden(false, animated: false)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController { sheet.detents = [.large()] }
        viewController.present(nav, animated: true)
    }
    
    func showAlert(message: String, from viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}
