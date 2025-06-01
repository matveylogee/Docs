//
//  GradientHelper.swift
//  generator
//
//  Created by Матвей on 09.05.2025.
//

import UIKit

/// Описывает параметры градиента
struct GradientConfig {
    let colors: [UIColor]
    let locations: [NSNumber]?
    let startPoint: CGPoint
    let endPoint: CGPoint
    let cornerRadius: CGFloat
    let cornerCurve: CALayerCornerCurve

    static let mainLicense = GradientConfig(
        colors: [
            UIColor(hex: "#8692E0"),
            UIColor(hex: "#6B6DAE"),
            UIColor(hex: "#59568F")
        ],
        locations: [0.0, 0.85, 2.0].map { NSNumber(value: $0) },
        startPoint: CGPoint(x: 0.5, y: 0.0),
        endPoint:   CGPoint(x: 0.5, y: 1.0),
        cornerRadius: 18,
        cornerCurve: .continuous
    )
    
    static let banner = GradientConfig(
        colors: [
            UIColor(hex: "#8692E0"),
            UIColor(hex: "#6B6DAE"),
            UIColor(hex: "#59568F")
        ],
        locations: [0.0, 0.55, 1.0].map { NSNumber(value: $0) },
        startPoint: CGPoint(x: 0.5, y: 0.0),
        endPoint:   CGPoint(x: 0.5, y: 1.0),
        cornerRadius: 18,
        cornerCurve: .continuous
    )
}

extension UIView {
    func applyGradient(_ config: GradientConfig) {
        layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        let gradient = CAGradientLayer()
        gradient.colors       = config.colors.map { $0.cgColor }
        gradient.locations    = config.locations
        gradient.startPoint   = config.startPoint
        gradient.endPoint     = config.endPoint
        gradient.cornerRadius = config.cornerRadius
        gradient.cornerCurve  = config.cornerCurve
        gradient.frame        = bounds

        layer.insertSublayer(gradient, at: 0)
    }
}

