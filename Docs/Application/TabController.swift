//
//  TabController.swift
//  generator
//
//  Created by Матвей on 23.03.2024.
//

import UIKit

final class TabController: UITabBarController {
    
    private let container: AppDIContainer

    init(container: AppDIContainer) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
        viewControllers = container.makeTabController().viewControllers
        tabBar.tintColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не поддерживается")
    }
}
