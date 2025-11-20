//  MessagesViewController.swift

import UIKit

// MARK: - Models

struct Conversation {
    let id: UUID = .init()
    let name: String
    let preview: String
    let timeText: String
    let avatar: UIImage?
}

// MARK: - Cells

final class ConversationCell: UITableViewCell {
    static let reuseID = "ConversationCell"

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let previewLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = .tertiaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .right
        return l
    }()

    private let chevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor.systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.9, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(previewLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(chevron)
        contentView.addSubview(separator)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),

            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            timeLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 80),

            chevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            previewLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            previewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            previewLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            previewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            separator.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    // MARK: Configure

    func configure(with model: Conversation) {
        nameLabel.text = model.name
        previewLabel.text = model.preview
        timeLabel.text = model.timeText
        if let img = model.avatar {
            avatarImageView.image = img
        } else {
            // fallback placeholder: initials circle
            avatarImageView.image = nil
        }
    }
}

// MARK: - Stories Cell (Collection View cell)

final class StoryCell: UICollectionViewCell {
    static let reuseID = "StoryCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 34
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor(white: 0.93, alpha: 1)
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 68),
            imageView.heightAnchor.constraint(equalToConstant: 68),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            titleLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(image: UIImage?, title: String) {
        imageView.image = image
        titleLabel.text = title
    }
}

// MARK: - Messages View Controller

final class MessagesViewController: UIViewController {

    // Placeholder avatar: uses uploaded image path (replace with asset if you prefer)
    private let placeholderAvatar = UIImage(named: "Image")


    // Dummy data
    private var conversations: [Conversation] = []
    private var stories: [(image: UIImage?, title: String)] = []

    // UI
    private let navLeftButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .label
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let navRightStack: UIStackView = {
        let compose = UIButton(type: .system)
        compose.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        compose.tintColor = .systemBlue
        compose.translatesAutoresizingMaskIntoConstraints = false
        let more = UIButton(type: .system)
        more.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        more.tintColor = .systemBlue
        more.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [more, compose])
        stack.spacing = 12
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Messages"
        l.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let searchField: UISearchBar = {
        let sb = UISearchBar()
        sb.searchBarStyle = .minimal
        sb.placeholder = "Search"
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.layer.cornerRadius = 10
        sb.clipsToBounds = true
        return sb
    }()

    private lazy var storiesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 84, height: 96)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(StoryCell.self, forCellWithReuseIdentifier: StoryCell.reuseID)
        return cv
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseID)
        tv.separatorStyle = .none
        tv.tableFooterView = UIView()
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupDummyData()
        configureSubviews()
        configureConstraints()
        configureActions()
        storiesCollection.dataSource = self
        storiesCollection.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: Setup

    private func setupDummyData() {
        // sample stories
        stories = [
            (image: placeholderAvatar, title: "Kenny..."),
            (image: placeholderAvatar, title: "Peter Herber..."),
            (image: placeholderAvatar, title: "Cooking!"),
            (image: placeholderAvatar, title: "Design"),
            (image: placeholderAvatar, title: "Friends")
        ]

        // sample conversations
        conversations = [
            Conversation(name: "Kristen", preview: "Hello aisha yo..", timeText: "9:41 AM", avatar: placeholderAvatar),
            Conversation(name: "Contact Name", preview: "Message preview...", timeText: "9:41 AM", avatar: placeholderAvatar),
            Conversation(name: "Contact Name", preview: "Message preview...", timeText: "9:41 AM", avatar: placeholderAvatar),
        ]
    }

    private func configureSubviews() {
        // Top "nav" area
        view.addSubview(navLeftButton)
        view.addSubview(titleLabel)
        view.addSubview(navRightStack)

        // Search
        view.addSubview(searchField)

        // Stories row
        view.addSubview(storiesCollection)

        // Table
        view.addSubview(tableView)
    }

    private func configureConstraints() {
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // nav left button
            navLeftButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 12),
            navLeftButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
            navLeftButton.widthAnchor.constraint(equalToConstant: 30),
            navLeftButton.heightAnchor.constraint(equalToConstant: 30),

            // nav right
            navRightStack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
            navRightStack.centerYAnchor.constraint(equalTo: navLeftButton.centerYAnchor),

            // title centered
            titleLabel.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navLeftButton.centerYAnchor),

            // Search bar
            searchField.topAnchor.constraint(equalTo: navLeftButton.bottomAnchor, constant: 8),
            searchField.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 12),
            searchField.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
            searchField.heightAnchor.constraint(equalToConstant: 44),

            // Stories collection
            storiesCollection.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),
            storiesCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            storiesCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            storiesCollection.heightAnchor.constraint(equalToConstant: 110),

            // Table view
            tableView.topAnchor.constraint(equalTo: storiesCollection.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safe.bottomAnchor), // leaves tab bar visible if inside tab controller
        ])
    }

    private func configureActions() {
        navLeftButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        // example button actions inside navRightStack: subviews[0], subviews[1]
        if let more = navRightStack.arrangedSubviews.first as? UIButton {
            more.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        }
        if navRightStack.arrangedSubviews.count > 1, let compose = navRightStack.arrangedSubviews[1] as? UIButton {
            compose.addTarget(self, action: #selector(didTapCompose), for: .touchUpInside)
        }
    }

    // MARK: Actions

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapMore() {
        // placeholder action
        let a = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        a.addAction(.init(title: "Cancel", style: .cancel))
        present(a, animated: true)
    }

    @objc private func didTapCompose() {
        // placeholder: open compose
        let a = UIAlertController(title: "Compose", message: nil, preferredStyle: .alert)
        a.addAction(.init(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UICollectionView DataSource / Delegate

extension MessagesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCell.reuseID, for: indexPath) as? StoryCell else {
            return UICollectionViewCell()
        }
        let item = stories[indexPath.item]
        cell.configure(image: item.image, title: item.title)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // open story / do something
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UITableView DataSource / Delegate

extension MessagesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { conversations.count }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 76 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reuseID, for: indexPath) as? ConversationCell else {
            return UITableViewCell()
        }
        cell.configure(with: conversations[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // push chat VC if you have one
        tableView.deselectRow(at: indexPath, animated: true)
        let conv = conversations[indexPath.row]
        let detail = UIViewController()
        detail.view.backgroundColor = .systemBackground
        detail.title = conv.name
        navigationController?.pushViewController(detail, animated: true)
    }
}
