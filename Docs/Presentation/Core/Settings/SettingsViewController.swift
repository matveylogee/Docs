//
//  SettingsController.swift
//  generator
//
//  Created by Матвей on 23.03.2024.
//

import UIKit

private enum Layout {
    /// расстояние от навбара / largeTitle до карточки профиля
    static let profileSectionHeaderHeight: CGFloat     = 16
    /// расстояние между карточкой профиля и остальными ячейками
    static let preferencesSectionHeaderHeight: CGFloat = 12
    /// высота ячейки профиля
    static let profileCellHeight: CGFloat = 80
}

// MARK: - Sections
private enum Section: Int, CaseIterable {
    case profile, preferences
}

final class SettingsViewController: UIViewController {
    
    private let viewModel: ProfileViewModelProtocol
    private var currentUser: UserPublic?
    
    // MARK: - Inits
    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        navigationItem.rightBarButtonItem = makeLogoutButton()

        view.applyAppGradient(.dark)
        configureTableView()
        
        bindProfileViewModel()
        viewModel.fetchProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateAppGradientFrame()
    }
}

// MARK: - Bind ViewModel
extension SettingsViewController {
    
    private func bindProfileViewModel() {
        viewModel.onProfileLoaded = { [weak self] user in
            guard let self = self else { return }
            self.currentUser = user
            DispatchQueue.main.async {
                self.tableView.reloadRows(
                    at: [IndexPath(row: 0, section: Section.profile.rawValue)],
                    with: .automatic
                )
            }
        }
        viewModel.onError = { [weak self] msg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "Ошибка", message: msg, preferredStyle: .alert)
                ac.addAction(.init(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
    }
}

// MARK: - Actions
extension SettingsViewController {
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Выход из аккаунта",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Отменить", style: .cancel))
        alert.addAction(.init(title: "Выйти", style: .destructive) { _ in
            try? KeychainService().delete(.authToken)
            NotificationCenter.default.post(name: .didLogout, object: nil)
        })
        present(alert, animated: true)
    }
}

// MARK: - Logout Button
extension SettingsViewController {
    
    private func makeLogoutButton() -> UIBarButtonItem {
        var config = UIButton.Configuration.plain()
        config.title = "Logout"
        config.baseForegroundColor = UIColor(hex: "E95443")
        config.background.backgroundColor = .white.withAlphaComponent(0.1)
        config.background.cornerRadius = 17
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.addAction(UIAction { [weak self] _ in
            self?.logoutTapped()
        }, for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        return UIBarButtonItem(customView: button)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .profile:     return 1
        case .preferences: return 2
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .profile:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsProfileCell.reuseID, for: indexPath) as! SettingsProfileCell
            let user = currentUser
            cell.configure(
                avatar: UIImage(named: "avatar_placeholder"),
                name:   user?.username ?? "",
                email:  user?.email ?? ""
            )
            cell.accessoryType = .disclosureIndicator
            return cell
            
        case .preferences:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DefaultCell", for: indexPath
            )
            cell.textLabel?.text = indexPath.row == 0 ? "Theme" : "Language"
            cell.accessoryType = .disclosureIndicator
            
            var bg = UIBackgroundConfiguration.listGroupedCell()
            bg.backgroundColor = UIColor(hex: "4D4D5B").withAlphaComponent(0.3)
            bg.cornerRadius    = 10
            cell.backgroundConfiguration = bg
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    // 1) Пустой view, чтобы heightForHeader сработал
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    // 2) Кастомная высота отступов
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        switch Section(rawValue: section)! {
        case .profile:     return Layout.profileSectionHeaderHeight
        case .preferences: return Layout.preferencesSectionHeaderHeight
        }
    }

    // 3) Без текстовых заголовков
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        nil
    }

    // 4) Высота профиля фиксированная, остальные — auto
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == Section.profile.rawValue
            ? Layout.profileCellHeight
            : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section)! {
        case .profile:
            let profileVC = ProfileDetailViewController(viewModel: viewModel)
            profileVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileVC, animated: true)
            
        case .preferences:
            if indexPath.row == 0 {
                let themeVC = ThemeSelectionViewController()
                themeVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(themeVC, animated: true)
            } else {
                let languageVC = LanguageSelectionViewController()
                languageVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(languageVC, animated: true)
            }
        }
    }
}

// MARK: - TableView Setup
extension SettingsViewController {
    
    private func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.isOpaque = false

        tableView.dataSource = self
        tableView.delegate   = self

        tableView.register(SettingsProfileCell.self, forCellReuseIdentifier: SettingsProfileCell.reuseID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")

        tableView.sectionHeaderTopPadding = 0
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
