//
//  Extension.swift
//  ShortcutsCollectionView
//
//  Created by Hassan El Desouky on 12/13/18.
//  Copyright © 2018 Hassan El Desouky. All rights reserved.
//

import UIKit

extension UIView {
    
    func setGradientBackgroundColor(colorOne: UIColor, colorTow: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTow.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?,
                bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,
                paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat,
                paddingRight: CGFloat, width: CGFloat = 0, height: CGFloat = 0) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leftAnchor
        }
        return leftAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.rightAnchor
        }
        return rightAnchor
    }
}

public extension UIView {

    /// Оборачивает текущую вью во «фирменный» стеклянный фон,
    /// возвращает созданный `UIVisualEffectView`, если он понадобится дальше.
    @discardableResult
    func embedInBlurCard(
        cornerRadius: CGFloat = 18,
        effectStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark,
        overlayColor: UIColor? = UIColor(
            hue: 0.77, saturation: 0.25, brightness: 0.40, alpha: 0.15),
        strokeColor: UIColor = UIColor.white.withAlphaComponent(0.12),
        lineWidth: CGFloat = 0.5
    ) -> UIVisualEffectView {

        // Если блюр уже добавлен ‒ просто возвращаем его
        if let existing = subviews.first(where: { $0 is UIVisualEffectView }) as? UIVisualEffectView {
            return existing
        }

        // 1. Блюр
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: effectStyle))
        blur.frame = bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.layer.cornerRadius = cornerRadius
        blur.layer.cornerCurve  = .continuous
        blur.clipsToBounds      = true

        // 2. Цветная «дымка» (по желанию)
        if let overlayColor = overlayColor {
            blur.contentView.backgroundColor = overlayColor
        }

        // 3. Едва-заметный штрих по контуру
        let stroke = CAShapeLayer()
        stroke.path        = UIBezierPath(roundedRect: bounds,
                                          cornerRadius: cornerRadius).cgPath
        stroke.fillColor   = UIColor.clear.cgColor
        stroke.strokeColor = strokeColor.cgColor
        stroke.lineWidth   = lineWidth
        stroke.frame       = bounds
        blur.layer.addSublayer(stroke)

        insertSubview(blur, at: 0)
        return blur
    }
}
