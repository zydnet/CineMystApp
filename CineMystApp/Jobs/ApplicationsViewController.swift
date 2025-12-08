import UIKit

// MARK: - Models
struct Application {
    let id: String
    let name: String
    let location: String
    let timeAgo: String
    let profileImage: String
    var isConnected: Bool
    var hasSubmittedTask: Bool
    var isShortlisted: Bool
}

class ApplicationsViewController: UIViewController {
    
    // MARK: - Properties
    private var applications: [Application] = []
    private var filteredApplications: [Application] = []
    private var isFilteredByAI = false
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Lead Actor - Drama Series \"City of Dre"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lbl.textColor = .gray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let searchBar: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search by name, location, or email..."
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        tf.layer.cornerRadius = 12
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 50))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let searchIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "magnifyingglass")
        iv.tintColor = .gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let filtersButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(" Filters", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 19
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let filterIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "slider.horizontal.3")
        iv.tintColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let topApplicantsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Top Applicants ", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 19
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let chevronIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.down")
        iv.tintColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let aiFilterButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Filtered by AI", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 67/255, green: 22/255, blue: 49/255, alpha: 1.0)
        btn.layer.cornerRadius = 19
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let countLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "25 applications"
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.separatorStyle = .singleLine
        tv.separatorInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupData()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Applications"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(red: 0.3, green: 0.1, blue: 0.3, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let profileBtn = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: self, action: #selector(profileTapped))
        profileBtn.tintColor = .darkGray
        navigationItem.rightBarButtonItem = profileBtn
    }
    @objc private func profileTapped() {
        let vc = ShortlistedViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(searchBar)
        searchBar.addSubview(searchIcon)
        contentView.addSubview(filtersButton)
        filtersButton.addSubview(filterIcon)
        contentView.addSubview(topApplicantsButton)
        topApplicantsButton.addSubview(chevronIcon)
        contentView.addSubview(aiFilterButton)
        contentView.addSubview(countLabel)
        contentView.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ApplicationCell.self, forCellReuseIdentifier: "ApplicationCell")
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            searchBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            searchIcon.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchIcon.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 16),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),
            
            filtersButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            filtersButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            filtersButton.heightAnchor.constraint(equalToConstant: 38),
            
            filterIcon.centerYAnchor.constraint(equalTo: filtersButton.centerYAnchor),
            filterIcon.leadingAnchor.constraint(equalTo: filtersButton.leadingAnchor, constant: 12),
            filterIcon.widthAnchor.constraint(equalToConstant: 18),
            filterIcon.heightAnchor.constraint(equalToConstant: 18),
            
            topApplicantsButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            topApplicantsButton.leadingAnchor.constraint(equalTo: filtersButton.trailingAnchor, constant: 10),
            topApplicantsButton.heightAnchor.constraint(equalToConstant: 38),
            
            chevronIcon.centerYAnchor.constraint(equalTo: topApplicantsButton.centerYAnchor),
            chevronIcon.trailingAnchor.constraint(equalTo: topApplicantsButton.trailingAnchor, constant: -12),
            chevronIcon.widthAnchor.constraint(equalToConstant: 10),
            chevronIcon.heightAnchor.constraint(equalToConstant: 10),
            
            aiFilterButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            aiFilterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            aiFilterButton.heightAnchor.constraint(equalToConstant: 38),
            
            countLabel.topAnchor.constraint(equalTo: filtersButton.bottomAnchor, constant: 20),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 6),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 700)
        ])
    }
    
    private func setupData() {
        applications = [
            Application(id: "1", name: "Aisha Sharma", location: "Mumbai, India", timeAgo: "21 days ago", profileImage: "cand3", isConnected: false, hasSubmittedTask: true, isShortlisted: false),
            Application(id: "2", name: "Aisha Sharma", location: "Mumbai, India", timeAgo: "21 days ago", profileImage: "cand3", isConnected: true, hasSubmittedTask: true, isShortlisted: false),
            Application(id: "3", name: "Aisha Sharma", location: "Mumbai, India", timeAgo: "21 days ago", profileImage: "cand3", isConnected: false, hasSubmittedTask: true, isShortlisted: false),
            Application(id: "4", name: "Aisha Sharma", location: "Mumbai, India", timeAgo: "21 days ago", profileImage: "cand3", isConnected: true, hasSubmittedTask: true, isShortlisted: false),
            Application(id: "5", name: "Aisha Sharma", location: "Mumbai, India", timeAgo: "21 days ago", profileImage: "cand3", isConnected: false, hasSubmittedTask: false, isShortlisted: false)
        ]
        filteredApplications = applications
        tableView.reloadData()
    }
    
    private func setupActions() {
        filtersButton.addTarget(self, action: #selector(filtersTapped), for: .touchUpInside)
        topApplicantsButton.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)
        aiFilterButton.addTarget(self, action: #selector(aiFilterTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
   
    
    @objc private func filtersTapped() {
        showFilterMenu()
    }
    
    @objc private func sortTapped() {
        showSortMenu()
    }
    
    @objc private func aiFilterTapped() {
        isFilteredByAI.toggle()
    }
    
    private func showFilterMenu() {
        let alert = UIAlertController(title: "Filter Applications", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "All Applications", style: .default, handler: { _ in
            self.filteredApplications = self.applications
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "By location", style: .default))
        alert.addAction(UIAlertAction(title: "Task Submitted", style: .default, handler: { _ in
            self.filteredApplications = self.applications.filter { $0.hasSubmittedTask }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Connections (100+)", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showSortMenu() {
        let alert = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Most Recent", style: .default))
        alert.addAction(UIAlertAction(title: "Top Applicants", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ApplicationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredApplications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplicationCell", for: indexPath) as! ApplicationCell
        let application = filteredApplications[indexPath.row]
        cell.configure(with: application)
        cell.shortlistAction = { [weak self] in
            self?.toggleShortlist(at: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100   // 🔥 Smaller cell
    }
    
    private func toggleShortlist(at indexPath: IndexPath) {
        filteredApplications[indexPath.row].isShortlisted.toggle()
        if let originalIndex = applications.firstIndex(where: { $0.id == filteredApplications[indexPath.row].id }) {
            applications[originalIndex].isShortlisted = filteredApplications[indexPath.row].isShortlisted
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
import UIKit

class ApplicationCell: UITableViewCell {
    
    var shortlistAction: (() -> Void)?
    
    private var taskLeadingWithConnected: NSLayoutConstraint!
    private var taskLeadingWithoutConnected: NSLayoutConstraint!
    
    private let themePlum = UIColor(red: 67/255, green: 22/255, blue: 49/255, alpha: 1.0)
    
    // MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let portfolioLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Portfolio"
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.textColor = UIColor.systemBlue
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let locationLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .gray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let locationIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "mappin.and.ellipse")
        iv.tintColor = .gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let timeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .gray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let timeIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "clock")
        iv.tintColor = .gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let connectedBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.85, blue: 1.0, alpha: 1.0)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let connectedLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Connected"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = UIColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1.0)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let taskBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.85, green: 0.98, blue: 0.9, alpha: 1.0)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let taskLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Task Submitted"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = UIColor(red: 0.0, green: 0.7, blue: 0.3, alpha: 1.0)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    
    // MARK: - Updated Shortlist Button
    
    private let shortlistButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        // Glow shadow identical to screenshot
        btn.layer.shadowColor = UIColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 0.3).cgColor
        btn.layer.shadowOpacity = 0.25
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 8
        
        return btn
    }()
    
    private let checkmarkIcon: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iv.image = UIImage(systemName: "checkmark", withConfiguration: config)
        iv.tintColor = UIColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1.0)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    // MARK: Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    
    // MARK: Layout
    
    private func setupCell() {
        selectionStyle = .none
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(portfolioLabel)
        contentView.addSubview(locationIcon)
        contentView.addSubview(locationLabel)
        contentView.addSubview(timeIcon)
        contentView.addSubview(timeLabel)
        
        contentView.addSubview(connectedBadge)
        connectedBadge.addSubview(connectedLabel)
        
        contentView.addSubview(taskBadge)
        taskBadge.addSubview(taskLabel)
        
        contentView.addSubview(shortlistButton)
        shortlistButton.addSubview(checkmarkIcon)
        shortlistButton.addTarget(self, action: #selector(shortlistTapped), for: .touchUpInside)
        
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            
            portfolioLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            portfolioLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            locationIcon.topAnchor.constraint(equalTo: portfolioLabel.bottomAnchor, constant: 6),
            locationIcon.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            locationIcon.widthAnchor.constraint(equalToConstant: 12),
            locationIcon.heightAnchor.constraint(equalToConstant: 12),
            
            locationLabel.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 4),
            
            timeIcon.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            timeIcon.leadingAnchor.constraint(equalTo: locationLabel.trailingAnchor, constant: 10),
            timeIcon.widthAnchor.constraint(equalToConstant: 12),
            timeIcon.heightAnchor.constraint(equalToConstant: 12),
            
            timeLabel.centerYAnchor.constraint(equalTo: timeIcon.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: timeIcon.trailingAnchor, constant: 4),
            
            
            // Connected badge
            connectedBadge.topAnchor.constraint(equalTo: locationIcon.bottomAnchor, constant: 6),
            connectedBadge.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            connectedBadge.heightAnchor.constraint(equalToConstant: 20),
            
            connectedLabel.topAnchor.constraint(equalTo: connectedBadge.topAnchor, constant: 2),
            connectedLabel.bottomAnchor.constraint(equalTo: connectedBadge.bottomAnchor, constant: -2),
            connectedLabel.leadingAnchor.constraint(equalTo: connectedBadge.leadingAnchor, constant: 8),
            connectedLabel.trailingAnchor.constraint(equalTo: connectedBadge.trailingAnchor, constant: -8),
            
            
            // Task badge
            taskBadge.topAnchor.constraint(equalTo: locationIcon.bottomAnchor, constant: 6),
            taskBadge.heightAnchor.constraint(equalToConstant: 20),
            
            taskLabel.topAnchor.constraint(equalTo: taskBadge.topAnchor, constant: 2),
            taskLabel.bottomAnchor.constraint(equalTo: taskBadge.bottomAnchor, constant: -2),
            taskLabel.leadingAnchor.constraint(equalTo: taskBadge.leadingAnchor, constant: 8),
            taskLabel.trailingAnchor.constraint(equalTo: taskBadge.trailingAnchor, constant: -8),
            
            
            // Shortlist Button
            shortlistButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            shortlistButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            shortlistButton.widthAnchor.constraint(equalToConstant: 40),
            shortlistButton.heightAnchor.constraint(equalToConstant: 40),
            
            checkmarkIcon.centerXAnchor.constraint(equalTo: shortlistButton.centerXAnchor),
            checkmarkIcon.centerYAnchor.constraint(equalTo: shortlistButton.centerYAnchor),
            checkmarkIcon.widthAnchor.constraint(equalToConstant: 18),
            checkmarkIcon.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        
        // Dual constraints for task badge
        taskLeadingWithConnected =
            taskBadge.leadingAnchor.constraint(equalTo: connectedBadge.trailingAnchor, constant: 6)
        
        taskLeadingWithoutConnected =
            taskBadge.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        
        taskLeadingWithConnected.isActive = true
    }
    
    
    // MARK: Configure
    
    func configure(with application: Application) {
        nameLabel.text = application.name
        locationLabel.text = application.location
        timeLabel.text = application.timeAgo
        profileImageView.image = UIImage(named: application.profileImage)
        
        
        // Connected badge visibility
        connectedBadge.isHidden = !application.isConnected
        
        if application.isConnected {
            taskLeadingWithoutConnected.isActive = false
            taskLeadingWithConnected.isActive = true
        } else {
            taskLeadingWithConnected.isActive = false
            taskLeadingWithoutConnected.isActive = true
        }
        
        
        // Shortlist UI
        if application.isShortlisted {
            shortlistButton.backgroundColor = themePlum
            shortlistButton.layer.shadowOpacity = 0
            checkmarkIcon.tintColor = .white
        } else {
            shortlistButton.backgroundColor = .white
            shortlistButton.layer.shadowOpacity = 0.25
            checkmarkIcon.tintColor = UIColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1.0)
        }
    }
    
    
    @objc private func shortlistTapped() {
        shortlistAction?()
    }
}
