//
//  HeaderView.swift
//  generator
//
//  Created by Матвей on 18.03.2025.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    static let reuseID = "HeaderView"
    private var sectionTitle: String?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        setupConstraints()
    }
    
    func configure(with title: String) {
        sectionTitle = title
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Actions
extension HeaderView {
    @objc private func didTapChevron() {
        if let title = sectionTitle {
            print(title)
        }
    }
}

// MARK: - Constraints
extension HeaderView {
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
