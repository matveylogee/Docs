//
//  SettingsContainer.swift
//  Docs
//
//  Created by Матвей on 11.08.2025.
//

import UIKit

final class SettingsContainer {
    private let services: AppServices
    private weak var parent: MainContainer?

    init(services: AppServices, parent: MainContainer) {
        self.services = services
        self.parent = parent
    }

    func makeNavController() -> UINavigationController {
        let vm = ProfileViewModel(network: services.networkService)
        vm.fetchProfile()
        let settingsVC = SettingsViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: settingsVC)
        nav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 2)
        return nav
    }
}
