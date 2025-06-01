//
//  SceneDelegate.swift
//  generator
//
//  Created by Матвей on 06.03.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var diContainer: AppDIContainer!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let ws = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: ws)
        
        let authNav = UINavigationController()
        self.diContainer = AppDIContainer(navigationController: authNav)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: .didLogout, object: nil)
        
        if let token = try? diContainer.keychainService.fetch(.authToken),
           !token.isEmpty {
            window.rootViewController = diContainer.makeTabController()
        } else {
            window.rootViewController = authNav
            diContainer.startAuthFlow()
        }
        
        window.makeKeyAndVisible()
        self.window = window
    }
    
    @objc private func handleLogout() {
        try? diContainer.keychainService.delete(.authToken)
        guard let window = self.window else { return }
        let authNav = UINavigationController()
        diContainer = AppDIContainer(navigationController: authNav)
        window.rootViewController = authNav
        diContainer.startAuthFlow()
    }
}
