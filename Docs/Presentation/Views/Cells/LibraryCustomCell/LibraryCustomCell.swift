//
//  CustomCell.swift
//  generator
//
//  Created by Матвей on 23.03.2024.
//

import UIKit

protocol LibraryCustomCellDelegate: AnyObject {
    func previewCellTapped(_ document: DocumentDTO, from transitionView: UIView)
    func shareCellTapped(_ document: DocumentDTO)
    func deleteCell(_ document: DocumentDTO)
    func getInfoTapped(_ document: DocumentDTO)
    func addCommentTapped(_ document: DocumentDTO)
    func editCommentTapped(_ document: DocumentDTO)
    func deleteCommentTapped(_ document: DocumentDTO)
    func showCommentTapped(_ document: DocumentDTO)
    func toggleFavoriteTapped(_ document: DocumentDTO)
}

class LibraryCustomCell: UITableViewCell {
    
    weak var delegate: LibraryCustomCellDelegate?
    var dateService: CurrentDateProtocol!
    var dto: DocumentDTO!
    static let reuseID = String(describing: LibraryCustomCell.self)
    
    // MARK: - UI
    
    private let commentButton: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "text.bubble", withConfiguration: cfg), for: .normal)
        btn.tintColor = .lightGray
        btn.backgroundColor = .init(white:1, alpha:0.15)
        btn.layer.cornerRadius = 17
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let favoriteButton: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bookmark.fill"))
        iv.tintColor = UIColor(hex: "EC7064")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()
    
    private let previewCellButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    internal let pdfIconView: UIImageView = {
        let img = UIImage(named: "pdf")
        let iv = UIImageView(image: img)
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 17)
        lbl.textColor = .label
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingMiddle
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    private let createTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, createTimeLabel])
        sv.axis = .vertical
        sv.spacing = 2
        sv.alignment = .leading
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isUserInteractionEnabled = false
        return sv
    }()
    
    private lazy var pdfAspectRatio: CGFloat = {
        guard let img = UIImage(named: "pdf") else { return 1 }
        return img.size.width / img.size.height
    }()
    
    // MARK: - Dynamic Constraints
    
    private var favoriteToCommentConstraint: NSLayoutConstraint!
    private var favoriteToTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Model
        func configure(with dto: DocumentDTO) {
            self.dto = dto
            titleLabel.text = "\(dto.artistNickname) \(dto.compositionName)"
            let displayDate = dateService.pdfDisplayDate(from: dto.createTime)
            createTimeLabel.text = "\(displayDate) • \(dto.fileType.capitalized)"
            commentButton.isHidden  = (dto.comment ?? "").isEmpty
            favoriteButton.isHidden = !dto.isFavorite
            updateFavoriteButtonPosition()
        }
    
    func setFavorite(_ favored: Bool) {
        favoriteButton.isHidden = !favored
        updateFavoriteButtonPosition()
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Actions

extension LibraryCustomCell {
    @objc private func previewCellButtonTapped() {
        guard let d = dto else { return }
        delegate?.previewCellTapped(d, from: pdfIconView)
    }
    @objc private func commentButtonTapped() {
        guard let d = dto else { return }
        delegate?.showCommentTapped(d)
    }
}

// MARK: - Setup

extension LibraryCustomCell {
    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(previewCellButton)
        previewCellButton.addTarget(self, action: #selector(previewCellButtonTapped), for: .touchUpInside)
        previewCellButton.addInteraction(UIContextMenuInteraction(delegate: self))
        
        // Вложенные элементы
        previewCellButton.addSubview(pdfIconView)
        previewCellButton.addSubview(labelsStackView)
        previewCellButton.addSubview(commentButton)
        previewCellButton.addSubview(favoriteButton)
        commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        favoriteToCommentConstraint = favoriteButton.trailingAnchor.constraint(
            equalTo: commentButton.leadingAnchor, constant: -12
        )
        favoriteToTrailingConstraint = favoriteButton.trailingAnchor.constraint(
            equalTo: previewCellButton.trailingAnchor, constant: -15
        )
        
        NSLayoutConstraint.activate([
            // Кнопка-превью на всю ячейку
            previewCellButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewCellButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewCellButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewCellButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // pdf-иконка
            pdfIconView.leadingAnchor.constraint(equalTo: previewCellButton.leadingAnchor, constant: 15),
            pdfIconView.topAnchor.constraint(equalTo: previewCellButton.topAnchor, constant: 8),
            pdfIconView.bottomAnchor.constraint(equalTo: previewCellButton.bottomAnchor, constant: -8),
            pdfIconView.widthAnchor.constraint(equalTo: pdfIconView.heightAnchor, multiplier: pdfAspectRatio),
            
            // кнопка комментариев
            commentButton.trailingAnchor.constraint(equalTo: previewCellButton.trailingAnchor, constant: -16),
            commentButton.centerYAnchor.constraint(equalTo: previewCellButton.centerYAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 34),
            commentButton.heightAnchor.constraint(equalTo: commentButton.widthAnchor),
            
            // кнопка избранного
            favoriteButton.centerYAnchor.constraint(equalTo: previewCellButton.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 20),
            favoriteButton.heightAnchor.constraint(equalTo: favoriteButton.widthAnchor),
            
            // стек лейблов
            labelsStackView.leadingAnchor.constraint(equalTo: pdfIconView.trailingAnchor, constant: 10),
            labelsStackView.centerYAnchor.constraint(equalTo: previewCellButton.centerYAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -10),
        ])
        
        // Активируем нужный constraint
        favoriteToTrailingConstraint.isActive = true
    }
    
    private func updateFavoriteButtonPosition() {
        if commentButton.isHidden {
            favoriteToCommentConstraint.isActive = false
            favoriteToTrailingConstraint.isActive = true
        } else {
            favoriteToTrailingConstraint.isActive = false
            favoriteToCommentConstraint.isActive = true
        }
        setNeedsLayout()
    }
}
