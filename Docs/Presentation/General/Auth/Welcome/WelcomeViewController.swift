//
//  WelcomeViewController.swift
//  generator
//
//  Created by Матвей on 07.05.2025.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: - Dependencies
    private let router: WelcomeRouterProtocol

    // MARK: — Inits
    init(router: WelcomeRouterProtocol) {
      self.router = router
      super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome to Docs"
        lbl.font = .systemFont(ofSize: 34, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private func makeBullet(iconName: String, headline: String, subtitle: String) -> UIStackView {
        let icon = UIImageView(image: UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate))
        icon.tintColor = UIColor(hex: "5E5CE7")
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 44),
            icon.heightAnchor.constraint(equalToConstant: 44)
        ])

        let labelsStack = UIStackView()
        labelsStack.axis = .vertical
        labelsStack.spacing = 2
        labelsStack.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = UILabel()
        titleLbl.text = headline
        titleLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLbl.textColor = .white
        titleLbl.numberOfLines = 0
        titleLbl.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLbl = UILabel()
        subtitleLbl.text = subtitle
        subtitleLbl.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLbl.textColor = UIColor(white: 1, alpha: 0.65)
        subtitleLbl.numberOfLines = 0
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = false

        labelsStack.addArrangedSubview(titleLbl)
        labelsStack.addArrangedSubview(subtitleLbl)

        let hStack = UIStackView(arrangedSubviews: [icon, labelsStack])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        return hStack
    }

    private lazy var bulletsStack: UIStackView = {
        let s1 = makeBullet(
            iconName: "text.document.fill",
            headline: "Draw up your contracts",
            subtitle: "Create documents according to the correct templates."
        )
        let s2 = makeBullet(
            iconName: "lock.circle.dotted",
            headline: "Keep it private",
            subtitle: "The security of your documents in the app."
        )
        let s3 = makeBullet(
            iconName: "rectangle.stack.badge.person.crop",
            headline: "Save it to the Library",
            subtitle: "Manage your documents, leave comments, share, add to Favorites."
        )

        let v = UIStackView(arrangedSubviews: [s1, s2, s3])
        v.axis = .vertical
        v.spacing = 25
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let centerImageView: UIImageView = {
        let iv = UIImageView()
        let img = UIImage(systemName: "person.2.fill")?
            .withRenderingMode(.alwaysTemplate)
        iv.image = img
        iv.tintColor = UIColor(hex: "5E5CE7")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let infoLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "When you explore the Docs app prior to subscribing, Apple may use your browsing activity to improve the service. Once you subscribe, your workouts are associated with a random identifier."
        lbl.font = .systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = UIColor(white: 1, alpha: 0.65)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continue", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = UIColor(hex: "5E5CE7")
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    @objc private func didTapContinue() {
        router.navigateToLogin()      
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "1C1C1E")

        [titleLabel, bulletsStack, centerImageView, infoLabel, continueButton].forEach { view.addSubview($0) }

        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        setupConstraints()
    }
}

//MARK: - Constraints
private extension WelcomeViewController {
    func setupConstraints() {
        NSLayoutConstraint.activate([
        
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            bulletsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            bulletsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            bulletsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
            
            centerImageView.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: 5),
            centerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerImageView.widthAnchor.constraint(equalToConstant: 45),
            centerImageView.heightAnchor.constraint(equalToConstant: 45),
            
            infoLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
