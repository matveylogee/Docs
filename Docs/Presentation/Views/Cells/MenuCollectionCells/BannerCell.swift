//
//  BannerCell.swift
//  generator
//
//  Created by Матвей on 18.03.2025.
//

import UIKit

class BannerCell: UICollectionViewCell, CollectionCellProtocol {

    static let reuseID = "BannerCell"

    private lazy var bannerHeader = CellLabel(
        font: .systemFont(ofSize: 18, weight: .semibold),
        color: .white
    )
    
    private lazy var bannerText = CellLabel(
        font: .systemFont(ofSize: 14, weight: .regular),
        color: .white,
        alpha: 0.75
    )

    // MARK: – Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor         = .clear
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve  = .continuous
        contentView.clipsToBounds      = true

        contentView.applyGradient(.banner)

        contentView.addSubview(bannerHeader)
        contentView.addSubview(bannerText)
        setConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        contentView.layer.sublayers?
            .compactMap { $0 as? CAGradientLayer }
            .forEach { $0.frame = contentView.bounds }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(item: CollectionItem) {
        bannerHeader.text = item.header
        bannerText.text   = item.description
    }
}

// MARK: – Constraints
extension BannerCell {
    func setConstraints() {
        NSLayoutConstraint.activate([
            bannerText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            bannerText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            bannerText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),

            bannerHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            bannerHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            bannerHeader.bottomAnchor.constraint(equalTo: bannerText.topAnchor, constant: -5),
        ])
    }
}
