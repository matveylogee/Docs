//
//  UILabel + Extensions.swift
//  generator
//
//  Created by Матвей on 07.03.2024.
//

import UIKit

extension UILabel {
    convenience init (text: String = "") {
        self.init()
        self.text = text
        self.textColor = .lightGray
        self.font = .systemFont(ofSize: 12)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
