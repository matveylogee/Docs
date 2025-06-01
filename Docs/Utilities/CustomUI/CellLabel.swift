//
//  CellLabel.swift
//  generator
//
//  Created by Матвей on 18.03.2025.
//

import UIKit

class CellLabel: UILabel {

    /// - Parameters:
    ///   - font:  Шрифт текста.
    ///   - color: Цвет текста.
    ///   - alpha: Прозрачность (0…1). По умолчанию — 1 (полностью непрозрачный).
    init(font: UIFont, color: UIColor, alpha: CGFloat = 1) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        self.font      = font
        self.textColor = color
        self.alpha     = alpha
        numberOfLines  = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
