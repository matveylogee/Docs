//
//  LoginViewController.swift
//  generator
//
//  Created by Матвей on 09.01.2025.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    // MARK: - Dependencies
    private let viewModel: RegistrationViewModelProtocol
    private let router: RegistrationRouterProtocol
    
    // MARK: - Inits
    init(viewModel: RegistrationViewModelProtocol, router: RegistrationRouterProtocol) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Create a Docs Account"
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = """
        Please fill in the information below to create your account. This will be used in the preparation of documents. The information can be changed in the settings.
        """
        lbl.font = .systemFont(ofSize: 16)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var usernameField = makeTextField("Full Name")
    private lazy var emailField = makeTextField("Email")
    private lazy var passwordField = makeTextField("Password", secure: true)
    
    private let bottomNoteLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "By creating an account, you agree to our Terms and Privacy Policy."
        lbl.font = .systemFont(ofSize: 12)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let createButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Create Account", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = UIColor(hex: "5E5CE7")
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAppGradient(.auth)
        setupLayout()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateAppGradientFrame()
    }
}

// MARK: - Bind ViewModel
extension RegistrationViewController {
    
    private func bindViewModel() {
        viewModel.onSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true) {
                    guard let self = self else { return }
                    self.router.showAlert(message: "Успешно зарегистрированы! Теперь войдите.", from: self)
                }
            }
        }

        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            self.router.showAlert(message: message, from: self)
        }
    }
}

// MARK: - Actions
extension RegistrationViewController {
    
    @objc private func createTapped() {
        let user = usernameField.text ?? ""
        let mail = emailField.text ?? ""
        let pass = passwordField.text ?? ""
        guard !user.isEmpty, !mail.isEmpty, !pass.isEmpty else {
            router.showAlert(message: "Заполните все поля", from: self)
            return
        }
        viewModel.register(username: user, email: mail, password: pass)
    }
    
    @objc private func cancelTapped() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}

// MARK: - Helper
extension RegistrationViewController {
    private func makeTextField(_ placeholder: String, secure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.isSecureTextEntry = secure
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 16)
        tf.borderStyle = .none
        tf.backgroundColor = .clear
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(white: 1, alpha: 0.6).cgColor
        tf.layer.cornerRadius = 12
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftView = spacer
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
}

// MARK: - Layout

extension RegistrationViewController {
    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(createButton)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: createButton.topAnchor),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            createButton.heightAnchor.constraint(equalToConstant: 50),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel,
            usernameField,
            emailField,
            passwordField,
            bottomNoteLabel
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25),
            
            usernameField.heightAnchor.constraint(equalToConstant: 50),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
