//
//  ProfileDetailViewController.swift
//  generator
//
//  Created by Матвей on 20.05.2025.
//

import UIKit
import QuartzCore

// MARK: — Layout constants
private enum Layout {
    static let topInset: CGFloat    = 22
    static let bottomInset: CGFloat = 32
    static let avatarSize: CGFloat  = 120
}

// MARK: — Diffable sections & fields
private enum Section { case main }

private enum Field: CaseIterable, Hashable {
    case firstName, lastName, nickname, location

    var title: String {
        switch self {
        case .firstName: return "First Name"
        case .lastName:  return "Last Name"
        case .nickname:  return "Nickname"
        case .location:  return "Email"
        }
    }
}

final class ProfileDetailViewController: UITableViewController {

    // MARK: — Dependencies & state
    private let viewModel: ProfileViewModelProtocol
    private var fieldValues: [Field: String?] = [:]
    private var dataSource: UITableViewDiffableDataSource<Section, Field>!

    // MARK: — UI
    private let avatarImageView = UIImageView()
    private lazy var editButton = UIBarButtonItem(
        title: "Edit", style: .plain,
        target: self, action: #selector(editTapped)
    )
    private var isEditingMode = false {
        didSet {
            editButton.title = isEditingMode ? "Done" : "Edit"
            tableView.visibleCells
                .compactMap { $0 as? FieldCell }
                .forEach {
                    $0.setEditing(isEditingMode, tint: UIColor(hex: "5E5CE7"))
                    if isEditingMode { $0.shakeTextField() }
                }
        }
    }

    // MARK: — Init
    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: — Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Personal Information"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = editButton

        view.backgroundColor = UIColor(hex: "1C1C1E")
        tableView.backgroundColor = UIColor(hex: "1C1C1E")
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.layoutMargins = .init(top:0,left:15,bottom:0,right:15)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .separator
        tableView.separatorInset = .init(top:0,left:15,bottom:0,right:0)
        tableView.rowHeight = 48
        tableView.sectionHeaderTopPadding = 0
        tableView.keyboardDismissMode = .interactive

        tableView.register(FieldCell.self, forCellReuseIdentifier: FieldCell.reuseID)

        configureDataSource()
        setupTableHeader()
        setupTableFooter()

        bindViewModel()
        viewModel.fetchProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Adjust header height
        if let header = tableView.tableHeaderView {
            let H = Layout.topInset + Layout.avatarSize + Layout.bottomInset
            if header.frame.height != H {
                header.frame.size.height = H
                tableView.tableHeaderView = header
            }
        }
    }

    // MARK: — Binding
    private func bindViewModel() {
        viewModel.onProfileLoaded = { [weak self] user in
            DispatchQueue.main.async {
                guard let self = self else { return }
                // fill fieldValues from the fetched user
                self.fieldValues = [
                    .firstName: user.username,
                    .lastName:  user.username,
                    .nickname:  nil,
                    .location:  user.email
                ]
                self.applySnapshot(animatingDifferences: false)
            }
        }
        viewModel.onProfileUpdated = { [weak self] user in
            DispatchQueue.main.async {
                guard let self = self else { return }
                // update same fields on save
                self.fieldValues[.firstName] = user.username
                self.fieldValues[.lastName]  = user.username
                self.fieldValues[.location]  = user.email
                self.applySnapshot()
            }
        }
        viewModel.onError = { [weak self] msg in
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "Ошибка", message: msg, preferredStyle: .alert)
                ac.addAction(.init(title: "OK", style: .default))
                self?.present(ac, animated: true)
            }
        }
    }

    // MARK: — Data Source
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section,Field>(tableView: tableView) { [weak self] table, ip, field in
            guard let self = self else { return UITableViewCell() }
            let cell = table.dequeueReusableCell(withIdentifier: FieldCell.reuseID, for: ip) as! FieldCell
            let value = self.fieldValues[field] ?? nil
            cell.configure(title: field.title, value: value, isEditing: self.isEditingMode)
            return cell
        }
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snap = NSDiffableDataSourceSnapshot<Section,Field>()
        snap.appendSections([.main])
        snap.appendItems(Field.allCases, toSection: .main)
        dataSource.apply(snap, animatingDifferences: animatingDifferences)
    }

    // MARK: — Edit action
    @objc private func editTapped() {
        if isEditingMode {
            // on Done → collect new values and send to backend
            let cells = tableView.visibleCells.compactMap { $0 as? FieldCell }
            let newFirst = cells.first { $0.titleText == Field.firstName.title }?.textValue
            let newLast  = cells.first { $0.titleText == Field.lastName.title  }?.textValue
            let newEmail = cells.first { $0.titleText == Field.location.title  }?.textValue
            viewModel.updateProfile(username: newFirst, email: newEmail, password: nil)
        }
        isEditingMode.toggle()
        applySnapshot()
    }

    // MARK: — Header & Footer
    private func setupTableHeader() {
        let header = UIView()
        header.backgroundColor = UIColor(hex: "1C1C1E")
        avatarImageView.image = UIImage(named: "avatar_placeholder")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = Layout.avatarSize/2
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        header.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: header.topAnchor, constant: Layout.topInset),
            avatarImageView.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: Layout.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Layout.avatarSize)
        ])
        tableView.tableHeaderView = header
    }

    private func setupTableFooter() {
        let footer = UIView(); footer.backgroundColor = .clear
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = """
            Track pushes instead of steps on Apple Watch in the Activity app, and in wheelchair workouts in the Workout app, and record them to Health. When this setting is on, your iPhone stops tracking steps.
            """
        label.translatesAutoresizingMaskIntoConstraints = false

        footer.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 25),
            label.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -25),
            label.topAnchor.constraint(equalTo: footer.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -15)
        ])

        tableView.tableFooterView = footer
        DispatchQueue.main.async {
            let target = CGSize(width: self.tableView.bounds.width, height: .greatestFiniteMagnitude)
            let h = footer.systemLayoutSizeFitting(target,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel).height
            footer.frame.size.height = h
            self.tableView.tableFooterView = footer
        }
    }

}

// MARK: — FieldCell

final class FieldCell: UITableViewCell {
    static let reuseID = "FieldCell"

    private let titleLabel = UILabel()
    private let textField  = UITextField()
    private lazy var trailingConstraint = textField.trailingAnchor.constraint(
        equalTo: contentView.layoutMarginsGuide.trailingAnchor
    )

    /// Expose for editTapped
    var titleText: String { titleLabel.text ?? "" }
    var textValue: String? { textField.text }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        if #available(iOS 15, *) {
            var bg = UIBackgroundConfiguration.listGroupedCell()
            bg.backgroundColor = UIColor(hex: "2C2C2E")
            bg.cornerRadius = 10
            backgroundConfiguration = bg
        } else {
            contentView.backgroundColor = UIColor(hex: "2C2C2E")
            let sel = UIView(); sel.backgroundColor = UIColor(hex: "3C3C3E")
            selectedBackgroundView = sel
        }

        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        textField.font = .systemFont(ofSize: 17)
        textField.textAlignment = .right
        textField.tintColor = UIColor(hex: "5E5CDF")
        textField.translatesAutoresizingMaskIntoConstraints = false

        accessoryType = .disclosureIndicator
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            textField.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            textField.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            trailingConstraint
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, value: String?, isEditing: Bool) {
        titleLabel.text = title

        if let v = value, !v.isEmpty {
            textField.text = v
            textField.attributedPlaceholder = nil
            accessoryType = .none
        } else {
            textField.text = ""
            textField.attributedPlaceholder = NSAttributedString(
                string: "Not Set",
                attributes: [.foregroundColor: UIColor(white:1,alpha:0.6)]
            )
            accessoryType = .disclosureIndicator
        }
        setEditing(isEditing, tint: tintColor)
    }

    func setEditing(_ editing: Bool, tint: UIColor) {
        textField.isUserInteractionEnabled = editing
        if editing {
            textField.textColor = tint
            if textField.text?.isEmpty ?? true {
                textField.attributedPlaceholder = NSAttributedString(
                    string: "Not Set", attributes: [.foregroundColor: tint]
                )
            }
            accessoryType = .none
        } else {
            if let t = textField.text, !t.isEmpty {
                textField.textColor = .white
                textField.attributedPlaceholder = nil
                accessoryType = .none
            } else {
                textField.textColor = .white
                textField.attributedPlaceholder = NSAttributedString(
                    string: "Not Set", attributes: [.foregroundColor: UIColor(white:1,alpha:0.6)]
                )
                accessoryType = .disclosureIndicator
            }
        }
    }

    func shakeTextField() {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.3
        anim.values = [-3, 3, -3, 3, 0]
        textField.layer.add(anim, forKey: "shake")
    }
}
