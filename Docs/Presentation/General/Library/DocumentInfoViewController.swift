//
//  DocumentInfoViewController.swift
//  generator
//
//  Created by Матвей on 12.05.2025.
//

import UIKit
import QuickLook
import QuickLookThumbnailing

class DocumentInfoViewController: UIViewController {

    // MARK: - Dependencies
    private let info: DocumentInfo
    private let dateService: CurrentDateProtocol
    private let router: DocumentInfoRouterProtocol
    
    private var previewController: QLPreviewController?
    private weak var transitionViewForPreview: UIView?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let openButton = UIButton(type: .system)
    private let infoHeaderLabel = UILabel()
    private let infoStack = UIStackView()
    private let separatorView = UIView()

    // MARK: - Inits
    init(info: DocumentInfo, dateService: CurrentDateProtocol, router: DocumentInfoRouterProtocol) {
        self.info = info
        self.dateService = dateService
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "Info"
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

        setupSubviews()
        renderThumbnail()
    }

    // MARK: - Helper
    private func makeInfoRow(title: String, value: String) -> UIView {
        let h = UIStackView()
        h.axis = .horizontal
        h.spacing = 8

        let t = UILabel()
        t.font = .systemFont(ofSize: 14, weight: .regular)
        t.textColor = .secondaryLabel
        t.text = title

        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .label
        v.text = value
        v.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        h.addArrangedSubview(t)
        h.addArrangedSubview(spacer)
        h.addArrangedSubview(v)
        return h
    }

    // MARK: - Рендер эскиза PDF
    func renderThumbnail() {
        let req = QLThumbnailGenerator.Request(
            fileAt: info.fileURL,
            size: CGSize(width: 200, height: 260),
            scale: UIScreen.main.scale,
            representationTypes: .all
        )
        
        QLThumbnailGenerator.shared.generateRepresentations(for: req) { [weak self] thumb, _, _ in
            guard let ui = thumb?.uiImage else { return }
            DispatchQueue.main.async {
                self?.thumbnailImageView.image = ui
            }
        }
    }
}

// MARK: - Actions
extension DocumentInfoViewController {

    @objc private func openTapped() {
        router.presentPreview(from: openButton, fileURL: info.fileURL)
    }
    
    @objc private func doneTapped() {
        router.dismissInfo()
    }
}

// MARK: - Setup UI
extension DocumentInfoViewController {
    
    private func setupSubviews() {
        [scrollView, contentView,
         thumbnailImageView, titleLabel, subtitleLabel,
         openButton, separatorView, infoHeaderLabel, infoStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.alwaysBounceVertical = true
        
        thumbnailImageView.contentMode = .scaleAspectFill
        
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.text = info.fileName
        
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.text = "\(info.kind) — \(info.fileSizeDescription)"
        
        openButton.setTitle("OPEN", for: .normal)
        openButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        openButton.backgroundColor = UIColor(hex: "#5E5CDF")
        openButton.setTitleColor(.white, for: .normal)
        openButton.layer.cornerRadius = 19
        openButton.addTarget(self, action: #selector(openTapped), for: .touchUpInside)
        
        separatorView.backgroundColor = .separator
        
        infoHeaderLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        infoHeaderLabel.text = "Information"
        
        infoStack.axis = .vertical
        infoStack.spacing = 8
        
        let createdDisplay = dateService.pdfDisplayDate(from: info.createdRaw)
        
        infoStack.addArrangedSubview(makeInfoRow(title: "Kind",        value: info.kind))
        infoStack.addArrangedSubview(makeInfoRow(title: "Created",     value: createdDisplay))
        infoStack.addArrangedSubview(makeInfoRow(title: "Type",        value: info.type))
        infoStack.addArrangedSubview(makeInfoRow(title: "Artist",      value: info.artistName))
        infoStack.addArrangedSubview(makeInfoRow(title: "Nickname",    value: info.artistNickname))
        infoStack.addArrangedSubview(makeInfoRow(title: "Composition", value: info.compositionName))
        infoStack.addArrangedSubview(makeInfoRow(title: "Price",       value: info.price))
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(openButton)
        contentView.addSubview(separatorView)
        contentView.addSubview(infoHeaderLabel)
        contentView.addSubview(infoStack)
        
        setupConstraints()
    }
}

// MARK: - Constraints
extension DocumentInfoViewController {
    
    private func setupConstraints() {
        let contentLayout = scrollView.contentLayoutGuide
        let frameLayout = scrollView.frameLayoutGuide
        let p: CGFloat = 16
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: contentLayout.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayout.widthAnchor),
            
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            thumbnailImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 180),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 240),
            
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            openButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            openButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            openButton.heightAnchor.constraint(equalToConstant: 38),
            openButton.widthAnchor.constraint(equalToConstant: 75),
            
            separatorView.topAnchor.constraint(equalTo: openButton.bottomAnchor, constant: 12),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
            
            infoHeaderLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: p),
            infoHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            infoHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            infoStack.topAnchor.constraint(equalTo: infoHeaderLabel.bottomAnchor, constant: 8),
            infoStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            infoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            infoStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -p),
        ])
    }
}
