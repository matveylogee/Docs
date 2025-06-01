//
//  MainLicensesInfoViewController.swift
//  generator
//
//  Created by Матвей on 20.03.2025.
//

import UIKit

final class MainLicensesInfoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private lazy var backgroundView = BlurView(
        title: "Info about mp3 licenses",
        description: "An Mp3 is a digital music file that is compressed to allow for easy storage and transfer."
    )

    private lazy var secondBackgroundView = BlurView(
        title: "Leasing",
        description: "Permissions: Grants you a license to use the beat for a specific purpose, often with limitations. These can include restrictions on streams, sales, territories, or whether the use is for profit or non-profit. \nCost: Typically cheaper than exclusive rights. \nExclusivity: The producer can still sell the same beat to other artists unless you purchase exclusive rights. \nControl: The producer maintains ownership of the beat and sets the terms of the lease. \nIdeal for starting artists, demos, or if you're on a budget. You can experiment with different beats without a huge investment."
    )

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.applyAppGradient(.dark)

        setupNavigationItems()
        
        setupScrollHierarchy()
        setupSubviews()
        setupConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateAppGradientFrame()
    }
}

// MARK: - Actions
private extension MainLicensesInfoViewController {
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - BarItems
private extension MainLicensesInfoViewController {
    
    private func makeTitleItem() -> UIBarButtonItem {
        let label = UILabel()
        label.text = "Info"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        return UIBarButtonItem(customView: label)
    }
    
    private func makeCloseButton() -> UIBarButtonItem {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let img = UIImage(systemName: "xmark", withConfiguration: config)
        btn.setImage(img, for: .normal)
        btn.tintColor = .secondaryLabel
        btn.showsMenuAsPrimaryAction = true
        btn.backgroundColor = UIColor(white: 1, alpha: 0.15)
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            btn.widthAnchor.constraint(equalToConstant: 32),
            btn.heightAnchor.constraint(equalToConstant: 32),
        ])
        
        return UIBarButtonItem(customView: btn)
    }
}

// MARK: - Constraints
private extension MainLicensesInfoViewController {
    
    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = makeTitleItem()
        navigationItem.rightBarButtonItem = makeCloseButton()
    }
    
    private func setupScrollHierarchy() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.alwaysBounceVertical = true
    }
    
    private func setupSubviews() {
        [backgroundView, secondBackgroundView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let p: CGFloat = 16
        let safe = view.safeAreaLayoutGuide
        let contentLayout = scrollView.contentLayoutGuide
        let frameLayout   = scrollView.frameLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safe.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: contentLayout.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayout.widthAnchor),
            
            backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            backgroundView.heightAnchor.constraint(equalToConstant: 200),
            
            secondBackgroundView.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: p),
            secondBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            secondBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            secondBackgroundView.heightAnchor.constraint(equalToConstant: 350),
            
            secondBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -p)
        ])
    }
}
