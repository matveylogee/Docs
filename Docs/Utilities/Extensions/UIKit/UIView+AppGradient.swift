//
//  UIView+AppGradient.swift
//  generator
//
//  Created by Матвей on 03.05.2025.
//

import UIKit
import ObjectiveC

private enum Assoc {
    static var gradientKey = "AppGradientLayerKey"
}

public extension UIView {

    /// Вставляет градиент позади всех сабвью.
    func applyAppGradient(_ style: BackgroundGradient) {
        // Если уже есть -- обновляем, а не плодим копии
        let layer = objc_getAssociatedObject(self, Assoc.gradientKey) as? CAGradientLayer
                    ?? {
                        let l = style.makeLayer()
                        objc_setAssociatedObject(self,
                                                  Assoc.gradientKey,
                                                  l,
                                                  .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                        return l
                    }()

        layer.frame = bounds
        if layer.superlayer == nil {
            layer.zPosition = -1     // гарантирует, что градиент остаётся фоном
            self.layer.insertSublayer(layer, at: 0)
        }
    }

    /// Вызываем из `layoutSubviews`, чтобы слой тянулся за экраном.
    func updateAppGradientFrame() {
        (objc_getAssociatedObject(self,
                                  Assoc.gradientKey) as? CAGradientLayer)?
                                 .frame = bounds
    }
}

