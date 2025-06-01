//
//  ThemeSelectionViewController.swift
//  generator
//
//  Created by Матвей on 20.05.2025.
//

import UIKit

final class ThemeSelectionViewController: UIViewController {
    
    private lazy var emptyStateView = EmptyStateView(
        image: UIImage(systemName: "figure.2.right.holdinghands"),
        title: "Change Theme",
        subtitle: "Will be Soon. \n May change App Theme."
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Theme"
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = UIColor(hex: "1C1C1E")
        
        setupEmptyStateView()
    }
    
    private func setupEmptyStateView() {
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
