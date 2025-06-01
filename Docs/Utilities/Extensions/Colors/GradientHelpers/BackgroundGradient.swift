//
//  AppGradient.swift
//  generator
//
//  Created by Матвей on 03.05.2025.
//

import UIKit

public enum BackgroundGradient {
    case light
    case dark
    case auth

    func makeLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        
        switch self {
        case .light:
            gradient.colors = [
                UIColor(hex: "F8F6F5").cgColor,
                UIColor(hex: "FAF3F3").cgColor,
                UIColor(hex: "F4EFF5").cgColor
            ]
            gradient.locations   = [0.0, 0.5, 1.0]
            gradient.startPoint  = CGPoint(x: 0.5, y: 0)
            gradient.endPoint    = CGPoint(x: 0.5, y: 1)
            
        case .dark:
            gradient.colors = [
                UIColor(hex: "06070E").cgColor,
                UIColor(hex: "15101B").cgColor,
                UIColor(hex: "2F1A34").cgColor
            ]
            gradient.locations   = [0.0, 0.5, 1.0]
            gradient.startPoint  = CGPoint(x: 0.5, y: 0)
            gradient.endPoint    = CGPoint(x: 0.5, y: 1)
            
        case .auth:
            gradient.colors = [
                UIColor(hex: "2F1A34").cgColor,
                UIColor(hex: "06070E").cgColor 
            ]
            gradient.locations   = [0.0, 1.0]
            gradient.startPoint  = CGPoint(x: 0.5, y: 0)
            gradient.endPoint    = CGPoint(x: 0.5, y: 1)
        }
        return gradient
    }
}
