//
//  BlurView.swift
//  generator
//
//  Created by Матвей on 05.05.2025.
//

import UIKit

final class BlurView: UIView {

    // MARK: - Subviews
    private let backgroundBlurView: UIVisualEffectView
    private var innerShadowLayer: CAShapeLayer?
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 22, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.alpha = 0.9
        lbl.font = .systemFont(ofSize: 16, weight: .regular)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - Init
    init(
        title: String? = nil,
        description: String? = nil,
        cornerRadius: CGFloat = 18,
        blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialLight,
        backgroundAlpha: CGFloat = 0.35
    ) {
        precondition(title != nil || description != nil, "Хотя бы один из параметров (title / description) должен быть заполнен")

        self.backgroundBlurView = UIVisualEffectView(effect: nil)
        self.backgroundBlurView.backgroundColor = UIColor(hex: "4D4D5B")
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.masksToBounds = false
        clipsToBounds = true

        backgroundBlurView.translatesAutoresizingMaskIntoConstraints = false
        backgroundBlurView.alpha = backgroundAlpha
        addSubview(backgroundBlurView)

        if let title {
            titleLabel.text = title
            addSubview(titleLabel)
        } else {
            titleLabel.isHidden = true
        }

        if let description {
            descriptionLabel.text = description
            addSubview(descriptionLabel)
        } else {
            descriptionLabel.isHidden = true
        }

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не поддерживается — используйте init(title:description:...)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
        ).cgPath
        applyInnerShadow()
    }

    private func applyInnerShadow() {

        innerShadowLayer?.removeFromSuperlayer()
        
        let radius: CGFloat = 4
        let shadowOpacity: Float = 0.01
        
        // создаём форму «рамки»
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = bounds
        
        // внешний прямоугольник чуть больше
        let bigRect = bounds.insetBy(dx: -radius, dy: -radius)
        let path = UIBezierPath(rect: bigRect)
        let inner = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        path.append(inner.reversing())
        
        shadowLayer.path = path.cgPath
        shadowLayer.fillRule = .evenOdd
        
        shadowLayer.shadowColor = UIColor(hex: "61616E").cgColor
        shadowLayer.shadowOffset = .zero
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowRadius = radius
        
        layer.addSublayer(shadowLayer)
        innerShadowLayer = shadowLayer
    }
}

// MARK: - Constraints
extension BlurView {
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundBlurView.topAnchor.constraint(equalTo: topAnchor),
            backgroundBlurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundBlurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundBlurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        if !titleLabel.isHidden {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            ])
        }

        if !descriptionLabel.isHidden {
            let topAnchorForDescription: NSLayoutYAxisAnchor =
                titleLabel.isHidden ? topAnchor : titleLabel.bottomAnchor

            let topConstant: CGFloat = titleLabel.isHidden ? 20 : 10

            NSLayoutConstraint.activate([
                descriptionLabel.topAnchor.constraint(equalTo: topAnchorForDescription, constant: topConstant),
                descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20)
            ])
        }
    }
}
