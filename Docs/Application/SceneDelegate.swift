//
//  SceneDelegate.swift
//  generator
//
//  Created by Матвей on 06.03.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appRoot: AppRootContainer!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: ws)
        self.window = window

        self.appRoot = AppRootContainer(window: window)
        appRoot.start()

        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: .didLogout, object: nil)

        window.makeKeyAndVisible()
    }

    @objc private func handleLogout() {
        appRoot.resetToAuth()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
