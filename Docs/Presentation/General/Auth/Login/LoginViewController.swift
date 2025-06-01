//
//  RegisterViewController.swift
//  generator
//
//  Created by Матвей on 09.01.2025.
//
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Dependencies
    private let viewModel: LoginViewModelProtocol
    private let router: LoginRouterProtocol

    // MARK: - Inits
    init(viewModel: LoginViewModelProtocol,
         router: LoginRouterProtocol) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Icon"))
        iv.layer.cornerRadius = 18
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Start crearing Docs"
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var emailField = makeTextField("Email")
    private lazy var passwordField = makeTextField("Password", secure: true)

    private let forgotButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot password?", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.contentHorizontalAlignment = .right
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Log In", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = UIColor(hex: "5E5CE7")
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let bottomLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Don’t have an account?"
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let singUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(UIColor(hex: "5E5CE7"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var bottomStack: UIStackView = {
        let stk = UIStackView(arrangedSubviews: [bottomLabel, singUpButton])
        stk.axis = .horizontal
        stk.spacing = 4
        stk.alignment = .center
        stk.translatesAutoresizingMaskIntoConstraints = false
        return stk
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyAppGradient(.auth)
        navigationItem.hidesBackButton = true
        setupLayout()

        loginButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        singUpButton.addTarget(self, action: #selector(didTapSingUp), for: .touchUpInside)
        
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateAppGradientFrame()
    }
}

// MARK: - Bind ViewModel
extension LoginViewController {
    
    private func bindViewModel() {
        viewModel.onSuccess = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.router.navigateToMenu(from: self)
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.router.showAlert(message: message, from: self)
            }
        }
    }
}

// MARK: - Actions
extension LoginViewController {
    
    @objc private func didTapContinue() {
        let email = emailField.text ?? ""
        let pass  = passwordField.text ?? ""
        guard !email.isEmpty, !pass.isEmpty else {
            router.showAlert(message: "Заполните все поля", from: self)
            return
        }
        viewModel.login(email: email, password: pass)
    }
    
    @objc private func didTapSingUp() {
        router.navigateToRegistration(from: self)
    }
}

// MARK: - Helper
extension LoginViewController {
    
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
extension LoginViewController {
    
    private func setupLayout() {
        [logoImageView, titleLabel,
         emailField, passwordField, forgotButton,
         loginButton, bottomStack].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 220),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: -15),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),

            emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            emailField.heightAnchor.constraint(equalToConstant: 50),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalTo: emailField.heightAnchor),

            forgotButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 8),
            forgotButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),

            loginButton.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -10),
            loginButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            bottomStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomStack.heightAnchor.constraint(equalToConstant: 20),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
        ])
    }
}
