//
//  InfoTextField.swift
//  generator
//
//  Created by Матвей on 07.03.2024.
//

import UIKit

final class InfoTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        borderStyle = .none
        layer.cornerRadius = 10
        textColor = UIColor(named: "otherColors")
        font = .systemFont(ofSize: 16)
        returnKeyType = .done
        translatesAutoresizingMaskIntoConstraints = false
    }
}
