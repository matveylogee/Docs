//
//  ViewController.swift
//  generator
//
//  Created by Матвей on 06.03.2024.
//

import UIKit

final class DocumentController: UIViewController {

    // MARK: - Dependencies
    private let viewModel: DocumentViewModelProtocol
    private let router: DocumentRouterProtocol
    private let fileType: DocumentType
    
    // MARK: - Inits
    init(viewModel: DocumentViewModelProtocol, router: DocumentRouterProtocol, fileType: DocumentType) {
        self.viewModel = viewModel
        self.fileType = fileType
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let nameView = InfoView("Artist Name", type: .name)
    private let nicknameView = InfoView("Artist Nickname", type: .nickname)
    private let compositionView = InfoView("Composition", type: .composition)
    private let priceView = InfoView("Price", type: .price)
    private let previewButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Document"
        navigationItem.largeTitleDisplayMode = .never
        view.applyAppGradient(.dark)

        setupUI()
        exitWarning()
        
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateAppGradientFrame()
    }
    
    //MARK: - Bind ViewModel
    private func bindViewModel() {
        
        viewModel.onSuccess = { [weak self] _ in
            DispatchQueue.main.async {
                self?.router.finishSaving()
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
        
        viewModel.onPreview = { [weak self] url in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.router.presentPreview(from: self.previewButton, pdfURL: url)
            }
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        [nameView, nicknameView, compositionView, priceView, previewButton, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        saveButton.setTitle("Save To Library", for: .normal)
        saveButton.setImage(nil, for: .normal)
        saveButton.tintColor = .white
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        saveButton.backgroundColor = UIColor(hex: "5E5CE7")
        saveButton.layer.cornerRadius = 12
        saveButton.layer.borderWidth = 0
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        previewButton.setTitle("Preview", for: .normal)
        previewButton.setTitleColor(.white, for: .normal)
        previewButton.backgroundColor = .clear
        previewButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        previewButton.addTarget(self, action: #selector(previewButtonTapped), for: .touchUpInside)
        
        
        setupConstraints()
    }
}

extension DocumentController {

    // MARK: - Save
    @objc private func saveButtonTapped() {
        guard checkInfoField() else { return }
        router.confirmSave { [weak self] in
            guard let self = self else { return }
            self.viewModel.saveDocument(
                name:        nameView.getText(),
                nickname:    nicknameView.getText(),
                composition: compositionView.getText(),
                price:       priceView.getText(),
                comment:     nil,
                isFavorite:  false,
                experience:  self.fileType
            )
        }
    }

    // MARK: - Preview
    @objc private func previewButtonTapped() {
        guard checkInfoField() else { return }
        viewModel.previewDocument(
            name:        nameView.getText(),
            nickname:    nicknameView.getText(),
            composition: compositionView.getText(),
            price:       priceView.getText(),
            experience:  fileType
        )
    }
}

// MARK: - ExitWarning
extension DocumentController {
    private func exitWarning() {
        navigationItem.backAction = UIAction { [weak self] _ in
            self?.router.confirmExitAndPop()
        }
    }
}

// MARK: - Helpers (Check Field)
extension DocumentController {

    private func checkInfoField() -> Bool {
        var result = true
        for type in ViewType.allCases {
            let text: String
            let view: InfoView
            switch type {
            case .name:
                text = nameView.getText(); view = nameView
            case .nickname:
                text = nicknameView.getText(); view = nicknameView
            case .composition:
                text = compositionView.getText(); view = compositionView
            case .price:
                text = priceView.getText(); view = priceView
            }
            if text.isEmpty {
                view.isFailed = true
                result = false
            } else {
                view.isFailed = false
            }
        }
        return result
    }
}

// MARK: - Constraints
extension DocumentController {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            nameView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 70),
            nameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.12),

            nicknameView.topAnchor.constraint(equalTo: nameView.bottomAnchor, constant: 30),
            nicknameView.leadingAnchor.constraint(equalTo: nameView.leadingAnchor),
            nicknameView.trailingAnchor.constraint(equalTo: nameView.trailingAnchor),
            nicknameView.heightAnchor.constraint(equalTo: nameView.heightAnchor),

            compositionView.topAnchor.constraint(equalTo: nicknameView.bottomAnchor, constant: 30),
            compositionView.leadingAnchor.constraint(equalTo: nameView.leadingAnchor),
            compositionView.trailingAnchor.constraint(equalTo: nameView.trailingAnchor),
            compositionView.heightAnchor.constraint(equalTo: nameView.heightAnchor),

            priceView.topAnchor.constraint(equalTo: compositionView.bottomAnchor, constant: 30),
            priceView.leadingAnchor.constraint(equalTo: nameView.leadingAnchor),
            priceView.trailingAnchor.constraint(equalTo: nameView.trailingAnchor),
            priceView.heightAnchor.constraint(equalTo: nameView.heightAnchor),

            saveButton.topAnchor.constraint(equalTo: priceView.bottomAnchor, constant: 260),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            previewButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10),
            previewButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            previewButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50)
        ])
    }
}
