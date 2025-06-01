//
//  SettingsProfileCell.swift
//  generator
//
//  Created by Матвей on 29.05.2025.
//

import UIKit

private enum Layout {
    /// размер аватара
    static let avatarSize: CGFloat = 64
    /// отступы внутри ячейки
    static let avatarLeftInset: CGFloat     = 16
    static let avatarToTextSpacing: CGFloat = 12
    static let textTrailingInset: CGFloat   = 32
}

final class SettingsProfileCell: UITableViewCell {
    
    static let reuseID = "SettingsProfileCell"

    private let avatarImageView = UIImageView()
    private let nameLabel  = UILabel()
    private let emailLabel = UILabel()
    private let textStack  = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        var bg = UIBackgroundConfiguration.listGroupedCell()
        bg.backgroundColor = UIColor(hex: "4D4D5B").withAlphaComponent(0.3)
        bg.cornerRadius    = 10
        backgroundConfiguration = bg
        
        // Аватар
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = Layout.avatarSize / 2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Лейблы
        nameLabel.font = .systemFont(ofSize: 17, weight: .medium)
        nameLabel.textColor = .white
        
        emailLabel.font = .systemFont(ofSize: 13)
        emailLabel.textColor = .secondaryLabel
        
        // Stack
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(emailLabel)
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(textStack)
        accessoryType = .disclosureIndicator
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Layout.avatarLeftInset
            ),
            avatarImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            avatarImageView.widthAnchor.constraint(
                equalToConstant: Layout.avatarSize
            ),
            avatarImageView.heightAnchor.constraint(
                equalToConstant: Layout.avatarSize
            ),
            
            textStack.leadingAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: Layout.avatarToTextSpacing
            ),
            textStack.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -Layout.textTrailingInset
            ),
            textStack.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            )
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(avatar: UIImage?, name: String, email: String) {
        avatarImageView.image = avatar
        nameLabel.text = name
        emailLabel.text = email
    }
}
