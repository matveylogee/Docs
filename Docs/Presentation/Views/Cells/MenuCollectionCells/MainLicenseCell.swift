//
//  MainLicenseCell.swift
//  generator
//
//  Created by Матвей on 18.03.2025.
//

import UIKit

protocol MainLicenseCellDelegate: AnyObject {
    func mainButtonTapped(in cell: MainLicenseCell)
    func categoryButtonTapped(in cell: MainLicenseCell)
    func openActionTapped(in cell: MainLicenseCell)
    func moreInfoActionTapped(in cell: MainLicenseCell)
}

class MainLicenseCell: UICollectionViewCell, CollectionCellProtocol {

    static let reuseID = "MainLicenseCell"
    weak var delegate: MainLicenseCellDelegate?
    var cellIndex: Int = 0
    var fileType: DocumentType?

    private lazy var mainButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 18
        button.layer.cornerCurve = .continuous
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)

        let ctx = UIContextMenuInteraction(delegate: self)
        button.addInteraction(ctx)

        return button
    }()

    lazy var categoryName: UILabel  = CellLabel(
        font: .systemFont(ofSize: 18, weight: .semibold),
        color: .white
    )
    lazy var categoryTime:  UILabel  = CellLabel(
        font: .systemFont(ofSize: 15, weight: .semibold),
        color: .white,
        alpha: 0.85
    )
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let img = UIImage(systemName: "ellipsis", withConfiguration: config)
        button.setImage(img, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 1, alpha: 0.15)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: – Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        mainButton.applyGradient(.banner)

        contentView.addSubview(mainButton)
        mainButton.addSubview(categoryName)
        mainButton.addSubview(categoryTime)
        mainButton.addSubview(categoryButton)
        setConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainButton.layoutIfNeeded()
        mainButton.layer.sublayers?
            .compactMap { $0 as? CAGradientLayer }
            .forEach { $0.frame = mainButton.bounds }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(item: CollectionItem) {
        categoryName.text = item.header
        categoryTime.text = item.description
    }
}

// MARK: – Context Menu
extension MainLicenseCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint)
                                -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let open = UIAction(title: "Открыть", image: UIImage(systemName: "doc")) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.openActionTapped(in: self)
            }
            let more = UIAction(title: "Подробнее", image: UIImage(systemName: "info.circle")) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.moreInfoActionTapped(in: self)
            }
            return UIMenu(title: "", children: [open, more])
        }
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration)
                                -> UITargetedPreview? {
        let params = UIPreviewParameters()
        params.backgroundColor = .clear
        return UITargetedPreview(view: mainButton, parameters: params)
    }
}

// MARK: – Actions
extension MainLicenseCell {
    @objc private func mainButtonTapped() {
        delegate?.mainButtonTapped(in: self)
    }
    
    @objc private func categoryButtonTapped() {
        delegate?.categoryButtonTapped(in: self)
    }
}

// MARK: – Constraints
extension MainLicenseCell {
    func setConstraints() {
        NSLayoutConstraint.activate([
            mainButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            categoryTime.topAnchor.constraint(equalTo: mainButton.topAnchor, constant: 15),
            categoryTime.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor, constant: 12),
            categoryTime.trailingAnchor.constraint(equalTo: mainButton.trailingAnchor, constant: -10),

            categoryButton.widthAnchor.constraint(equalToConstant: 30),
            categoryButton.heightAnchor.constraint(equalToConstant: 30),
            categoryButton.trailingAnchor.constraint(equalTo: mainButton.trailingAnchor, constant: -10),
            categoryButton.topAnchor.constraint(equalTo: mainButton.topAnchor, constant: 10),

            categoryName.bottomAnchor.constraint(equalTo: mainButton.bottomAnchor, constant: -13),
            categoryName.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor, constant: 13),
            categoryName.trailingAnchor.constraint(equalTo: mainButton.trailingAnchor, constant: -13),
        ])
    }
}
