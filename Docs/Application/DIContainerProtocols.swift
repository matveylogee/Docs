//
//  DIContainerProtocols.swift
//  generator
//
//  Created by Матвей on 25.05.2025.
//

import UIKit

typealias DIContainerProtocol = AuthProtocol & DocumentProtocol & MainTabProtocol

protocol AuthProtocol: AnyObject {
    func startAuthFlow()
    func makeLoginController() -> UIViewController
    func makeRegistrationViewController() -> UIViewController
    func makeTabController() -> UITabBarController
}

protocol DocumentProtocol: AnyObject {
    func makeDocumentController(fileType: DocumentType) -> UIViewController
    func makeDocumentInfoController(info: DocumentInfo) -> UIViewController
}

protocol MainTabProtocol: AnyObject {
    func makeMenuNavController() -> UINavigationController
    func makeLibraryNavController() -> UINavigationController
    func makeSettingsNavController() -> UINavigationController
}
