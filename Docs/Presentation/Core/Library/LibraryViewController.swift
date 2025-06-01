//
//  LibraryController.swift
//  generator
//
//  Created by Матвей on 23.03.2024.
//

import UIKit

// MARK: - Sorting
private enum SortOption {
    case entryDate, momentDate
    var title: String {
        switch self {
        case .entryDate:  return "Entry Date"
        case .momentDate: return "Moment Date"
        }
    }
}

final class LibraryController: UIViewController {
    
    // MARK: - Dependencies
    let viewModel: LibraryViewModelProtocol
    let router: LibraryRouterProtocol
    var dataSource: UITableViewDiffableDataSource<Int, DocumentDTO>!

    private static var currentSort: SortOption = .entryDate
    private var showingFavoritesOnly = false
    
    // MARK: - UI
    private lazy var emptyStateView = EmptyStateView(
        image: UIImage(systemName: "folder.fill.badge.plus"),
        title: "Create Documents",
        subtitle: "Create your personal licence.\nSwipe to the Menu to get started."
    )
    
    private lazy var noResultsView = EmptyStateView(
        image: UIImage(systemName: "folder.fill.badge.questionmark"),
        title: "No Results",
        subtitle: "We couldn’t find any documents \nmatching your query."
    )
    
    private lazy var searchController: UISearchController = {
        let c = UISearchController(searchResultsController: nil)
        c.obscuresBackgroundDuringPresentation = false
        c.searchResultsUpdater = self
        c.searchBar.placeholder = "Search files"
        return c
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(LibraryCustomCell.self, forCellReuseIdentifier: LibraryCustomCell.reuseID)
        tv.separatorStyle = .singleLine
        tv.separatorColor = .separator
        tv.separatorInset = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 15)
        tv.backgroundColor = .clear
        return tv
    }()
    
    // MARK: - Inits
    init(viewModel: LibraryViewModelProtocol, router: LibraryRouterProtocol) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Library"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.applyAppGradient(.dark)
        extendedLayoutIncludesOpaqueBars = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem = makeMoreButton()
        definesPresentationContext = true
        
        setupTableView()
        configureDataSource()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        reloadDocuments()
    }
    
    // MARK: - Helpers
    private func reloadDocuments() {
        viewModel.fetchDocuments(showingFavoritesOnly: showingFavoritesOnly, filter: searchController.searchBar.text)
    }
    
    private func updateBackground(docs: [DocumentDTO]) {
        if docs.isEmpty {
            let hasQuery = !(searchController.searchBar.text?.isEmpty ?? true)
            tableView.backgroundView = hasQuery ? noResultsView : emptyStateView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - Erroe Alert
    private func presentError(_ message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(.init(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - Bind ViewModel
extension LibraryController {
    
    private func bindViewModel() {
        viewModel.onDocumentsChanged = { [weak self] docs in
            DispatchQueue.main.async {
                guard let self = self else { return }
                var snap = NSDiffableDataSourceSnapshot<Int, DocumentDTO>()
                snap.appendSections([0])
                snap.appendItems(docs)
                self.dataSource.apply(snap, animatingDifferences: true)
                //MARK: - ПОПРАВИТЬ АНИМАЦИЮ (ЗАМЕНИТЬ ПРОКИДЫВАНИЕ DTO НА ID)
                self.updateBackground(docs: docs)
            }
        }
        
        viewModel.onError = { [weak self] msg in
            DispatchQueue.main.async { self?.presentError(msg) }
        }
    }
}

// MARK: - UISearchResultsUpdating
extension LibraryController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        reloadDocuments()
    }
}

// MARK: - Cell Delegate
extension LibraryController: LibraryCustomCellDelegate {
    
    func previewCellTapped(_ document: DocumentDTO, from transitionView: UIView) {
        router.showPreview(for: document, from: transitionView)
    }
    
    func shareCellTapped(_ document: DocumentDTO) {
        router.share(document: document)
    }
    
    func deleteCell(_ document: DocumentDTO) {
        router.confirmDelete(
            document: document,
            onConfirm: { self.viewModel.deleteDocument(id: document.id) },
            onCancel: {}
        )
    }
    
    func getInfoTapped(_ document: DocumentDTO) {
        router.showInfo(for: document)
    }
    
    func addCommentTapped(_ document: DocumentDTO) {
        router.presentCommentEditor(initialText: "", for: document) { text in
            self.viewModel.updateComment(id: document.id, comment: text)
        }
    }
    
    func editCommentTapped(_ document: DocumentDTO) {
        let existing = document.comment ?? ""
        router.presentCommentEditor(initialText: existing, for: document) { text in
            self.viewModel.updateComment(id: document.id, comment: text)
        }
    }
    
    func deleteCommentTapped(_ document: DocumentDTO) {
        viewModel.updateComment(id: document.id, comment: "")
    }
    
    func showCommentTapped(_ document: DocumentDTO) {
        router.presentAlert(title: "Comment", message: document.comment)
    }
    
    func toggleFavoriteTapped(_ document: DocumentDTO) {
        viewModel.toggleFavorite(id: document.id, isFavorite: !document.isFavorite)
    }
}

// MARK: - More Button Actions
extension LibraryController {
    
    private func makeMoreButton() -> UIBarButtonItem {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.showsMenuAsPrimaryAction = true
        btn.backgroundColor = UIColor(white: 1, alpha: 0.15)
        btn.layer.cornerRadius = 17
        btn.menu = makeMainMenu()
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.widthAnchor.constraint(equalToConstant: 34),
            btn.heightAnchor.constraint(equalToConstant: 34),
        ])
        return UIBarButtonItem(customView: btn)
    }
    
    private func makeMainMenu() -> UIMenu {
        let favTitle = showingFavoritesOnly ? "Show All" : "Favourites"
        let favImage = UIImage(systemName: showingFavoritesOnly ? "list.bullet" : "bookmark")
        let fav = UIAction(title: favTitle, image: favImage) { [weak self] _ in
            guard let self = self else { return }
            self.showingFavoritesOnly.toggle()
            self.reloadDocuments()
            if let btn = self.navigationItem.rightBarButtonItem?.customView as? UIButton {
                btn.menu = self.makeMainMenu()
            }
        }
        let sortMenu = UIMenu(
            title: "Sort By",
            subtitle: LibraryController.currentSort.title,
            image: UIImage(systemName: "arrow.up.arrow.down"),
            children: [
                UIAction(title: SortOption.entryDate.title, state: .off) { _ in },
                UIAction(title: SortOption.momentDate.title, state: .off) { _ in }
            ]
        )
        return UIMenu(children: [fav, sortMenu])
    }
}

// MARK: - TableView Setup
extension LibraryController {
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, DocumentDTO>(tableView: tableView) { tableView, indexPath, dto in
            let cell = tableView.dequeueReusableCell(withIdentifier: LibraryCustomCell.reuseID, for: indexPath) as! LibraryCustomCell
            cell.delegate = self
            cell.dateService = self.viewModel.dateService
            cell.configure(with: dto)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension LibraryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 65 }
}
