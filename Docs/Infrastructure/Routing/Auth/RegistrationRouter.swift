//
//  LoginRouter.swift
//  generator
//
//  Created by Матвей on 14.05.2025.
//

import UIKit

protocol RegistrationRouterProtocol: AnyObject {
    func showAlert(message: String, from viewController: UIViewController)
}

final class RegistrationRouter: RegistrationRouterProtocol {
    
    init() {}

    func showAlert(message: String, from viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "ОК", style: .default))
        viewController.present(alert, animated: true)
    }
}

