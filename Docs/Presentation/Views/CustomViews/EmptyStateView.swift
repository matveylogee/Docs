//
//  EmptyStateView.swift
//  generator
//
//  Created by Матвей on 10.05.2025.
//

import UIKit

/// Вью для отображения пустого состояния с иконкой, заголовком и подзаголовком
final class EmptyStateView: UIView {

    // MARK: - Subviews
    private let imageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let subtitleLabel: UILabel = UILabel()
    private let stackView: UIStackView = UIStackView()

    // MARK: - Init
    /// - Parameters:
    ///   - image: Иконка в центре
    ///   - title: Заголовок (большой текст)
    ///   - subtitle: Подзаголовок (мелкий текст, может быть несколько строк)
    init(image: UIImage?, title: String, subtitle: String) {
        super.init(frame: .zero)
        configure(image: image, title: title, subtitle: subtitle)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure(image: nil, title: "", subtitle: "")
    }

    // MARK: - Configuration
    private func configure(image: UIImage?, title: String, subtitle: String) {
        backgroundColor = .clear

        // imageView
        imageView.image = image
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // titleLabel
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // subtitleLabel
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // stackView
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // добавляем subviews
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        // вручную задаём одинаковые отступы
        let customSpacing: CGFloat = 20
        stackView.setCustomSpacing(customSpacing - 15, after: imageView)
        stackView.setCustomSpacing(customSpacing - 15, after: titleLabel)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            
            imageView.heightAnchor.constraint(equalToConstant: 75),
            imageView.widthAnchor.constraint(equalToConstant: 75)
        ])
    }
}
