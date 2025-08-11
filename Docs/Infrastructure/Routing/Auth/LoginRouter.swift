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
    private weak var navigationController: UINavigationController?
    private let registrationFactory: RegistrationFactory
    private let onLoginSuccess: () -> Void

    init(navigationController: UINavigationController?, registrationFactory: RegistrationFactory, onLoginSuccess: @escaping () -> Void) {
        self.navigationController = navigationController
        self.registrationFactory = registrationFactory
        self.onLoginSuccess = onLoginSuccess
    }
    
    func navigateToMenu(from viewController: UIViewController) {
        onLoginSuccess()
    }
    
    func navigateToRegistration(from viewController: UIViewController) {
        let signUpController = registrationFactory.makeRegistrationViewController()
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
