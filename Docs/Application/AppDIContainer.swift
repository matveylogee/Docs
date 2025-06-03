//
//  AppDIContainer.swift
//  generator
//
//  Created by Матвей on 14.05.2025.
//

import UIKit

final class AppDIContainer: DIContainerProtocol {

    private let navigationController: UINavigationController

    // MARK: - Services
    let dateService: CurrentDateProtocol
    let networkService: NetworkServiceProtocol
    let keychainService: KeychainServiceProtocol
    let tokenProvider: TokenProviderProtocol

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.keychainService = KeychainService()

        let savedToken: String?
        do { savedToken = try keychainService.fetch(.authToken) } catch { savedToken = nil }

        let provider = AuthTokenStorage(initialToken: savedToken)
        self.tokenProvider = provider

        self.dateService = CurrentDate()
        self.networkService = NetworkService(session: URLSession.shared, tokenProvider: provider)
    }

    // MARK: - Auth Flow Start
    func startAuthFlow() {
        let welcomeVC = WelcomeViewController(router: welcomeRouter)
        navigationController.setViewControllers([welcomeVC], animated: false)
    }

    // MARK: - Routers
    private lazy var welcomeRouter: WelcomeRouterProtocol = {
        WelcomeRouter(navigationController: navigationController, container: self)
    }()
    
    private lazy var loginRouter: LoginRouterProtocol = {
        LoginRouter(container: self)
    }()
    
    private lazy var registrationRouter: RegistrationRouterProtocol = {
        RegistrationRouter(container: self)
    }()
}

// MARK: - Controllers Factories
extension AppDIContainer {
    
    func makeLoginController() -> UIViewController {
        let vm = LoginViewModel(network: networkService, tokenProvider: tokenProvider, keychain: keychainService)
        let vc = LoginViewController(viewModel: vm, router: loginRouter)
        return vc
    }

    func makeRegistrationViewController() -> UIViewController {
        let vm = RegistrationViewModel(network: networkService, keychain: keychainService)
        let vc = RegistrationViewController(viewModel: vm, router: registrationRouter)
        return vc
    }
    
    func makeDocumentController(fileType: DocumentType) -> UIViewController {
        let vm = DocumentViewModel(network: networkService, currentDate: dateService)
        let router = DocumentRouter(container: self)
        let vc = DocumentController(viewModel: vm, router: router, fileType: fileType)
        router.viewController = vc
        vc.hidesBottomBarWhenPushed = true
        return vc
    }

    func makeDocumentInfoController(info: DocumentInfo) -> UIViewController {
        let router = DocumentInfoRouter()
        let vc = DocumentInfoViewController(info: info, dateService: dateService, router: router)
        router.viewController = vc
        return vc
    }
}

// MARK: - Tab Bar Setup
extension AppDIContainer {
    
    func makeMenuNavController() -> UINavigationController {
        let router = MenuRouter(container: self)
        let menuVC = MenuViewController(menuRouter: router)
        router.viewController = menuVC

        let nav = UINavigationController(rootViewController: menuVC)
        nav.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(systemName: "house"), tag: 0)
        return nav
    }

    func makeLibraryNavController() -> UINavigationController {
        let vm = LibraryViewModel(network: networkService, dateService: dateService)
        let router = LibraryRouter(container: self)
        let libraryVC = LibraryController(viewModel: vm, router: router)
        router.viewController = libraryVC

        let nav = UINavigationController(rootViewController: libraryVC)
        nav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "rectangle.stack.fill"), tag: 1)
        return nav
    }

    func makeSettingsNavController() -> UINavigationController {
        let vm = ProfileViewModel(network: networkService)
        vm.fetchProfile()
        let settingsVC = SettingsViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: settingsVC)
        nav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 2)
        return nav
    }

    func makeTabController() -> UITabBarController {
        let tab = UITabBarController()
        tab.viewControllers = [makeMenuNavController(), makeLibraryNavController(), makeSettingsNavController()]
        tab.tabBar.tintColor = .white
        return tab
    }
}
