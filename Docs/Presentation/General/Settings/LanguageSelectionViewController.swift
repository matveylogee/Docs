//
//  LanguageSelectionViewController.swift
//  generator
//
//  Created by Матвей on 20.05.2025.
//

import UIKit

final class LanguageSelectionViewController: UIViewController {
    
    private lazy var emptyStateView = EmptyStateView(
        image: UIImage(systemName: "figure.2.right.holdinghands"),
        title: "Change Language",
        subtitle: "Will be Soon. \n May change App and Document \nTemplates Language."
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Language"
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

