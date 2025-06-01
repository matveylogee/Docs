//
//  MenuViewController.swift
//  generator
//
//  Created by Матвей on 18.03.2025.
//

import UIKit

enum DocumentType: String {
    case mp3 = "Mp3"
    case wav = "Wav"
    case trackout = "Trackout"
    case exclusive = "Exclusive"
    
    var intValue: Int {
        switch self {
        case .mp3: return 0
        case .wav: return 1
        case .trackout: return 2
        case .exclusive: return 3
        }
    }
}

final class MenuViewController: UIViewController {

    // MARK: - Data / Routing
    private let collectionData = MenuCollectionSections.mockData()
    private let menuRouter: MenuRouterProtocol

    // MARK: - Search
    private lazy var searchController: UISearchController = {
        let c = UISearchController(searchResultsController: nil)
        c.obscuresBackgroundDuringPresentation = false
        c.searchBar.placeholder = "Search files"
        return c
    }()

    // MARK: - CollectionView
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .clear
        cv.isOpaque = false
        cv.dataSource = self

        cv.register(MainLicenseCell.self, forCellWithReuseIdentifier: MainLicenseCell.reuseID)
        cv.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.reuseID)
        cv.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseID)
        return cv
    }()
    
    // MARK: - Inits
    init(menuRouter: MenuRouterProtocol) {
        self.menuRouter = menuRouter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Menu"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController

        view.applyAppGradient(.dark)
        view.addSubview(collectionView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        view.updateAppGradientFrame()
    }
}

// MARK: - MainLicenseCellDelegate
extension MenuViewController: MainLicenseCellDelegate {
    
    func mainButtonTapped(in cell: MainLicenseCell) {
        menuRouter.navigateToDocument(fileType: cell.fileType!)
    }

    func openActionTapped(in cell: MainLicenseCell) {
        menuRouter.navigateToDocument(fileType: cell.fileType!)
    }

    func categoryButtonTapped(in cell: MainLicenseCell) {
        menuRouter.navigateToInfo()
    }

    func moreInfoActionTapped(in cell: MainLicenseCell) {
        menuRouter.navigateToInfo()
    }
}

// MARK: - Layout helpers
private extension MenuViewController {
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [unowned self] section, _ in
            let current = collectionData[section]
            switch current.type {
            case .mainLicense: return createMainLicenseLayout()
            case .banner: return createBannerLayout()
            }
        }
    }

    func createMainLicenseLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(190),
                                                            heightDimension: .absolute(122)))
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 10)

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                        heightDimension: .absolute(132)),
                                                        repeatingSubitem: item,
                                                        count: 2)
        group.contentInsets = .init(top: 5, leading: 16, bottom: 15, trailing: 6)

        let section = NSCollectionLayoutSection(group: group)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                heightDimension: .absolute(25))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        section.boundarySupplementaryItems = [header]
        return section
    }

    func createBannerLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                        heightDimension: .absolute(150)),
                                                        repeatingSubitem: item,
                                                        count: 1)
        group.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 30, trailing: 0)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                heightDimension: .absolute(35))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        section.boundarySupplementaryItems = [header]
        return section
    }
}

// MARK: - UICollectionViewDataSource
extension MenuViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { collectionData.count }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionData[section].item.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = collectionData[indexPath.section]
        let item = section.item[indexPath.item]

        switch section.type {
        case .mainLicense:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainLicenseCell.reuseID,
                                                          for: indexPath) as! MainLicenseCell
            cell.setupCell(item: item)
            cell.cellIndex = indexPath.item
            cell.fileType = item.type
            cell.delegate  = self
            return cell

        case .banner:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCell.reuseID,
                                                          for: indexPath) as! BannerCell
            cell.setupCell(item: item)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: HeaderView.reuseID,
                                                                           for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        header.configure(with: collectionData[indexPath.section].type.title)
        return header
    }
}
