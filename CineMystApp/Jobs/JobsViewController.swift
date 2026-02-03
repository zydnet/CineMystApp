import UIKit
import Supabase

// MARK: - Colors & Helpers
fileprivate extension UIColor {
    static let themePlum = UIColor(red: 67/255, green: 22/255, blue: 49/255, alpha: 1)
    static let softGrayBg = UIColor.systemGroupedBackground
}

fileprivate func makeShadow(on view: UIView, radius: CGFloat = 8, yOffset: CGFloat = 2, opacity: Float = 0.08) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = opacity
    view.layer.shadowRadius = radius
    view.layer.shadowOffset = CGSize(width: 0, height: yOffset)
    view.layer.masksToBounds = false
}

// MARK: - JobsViewController
final class jobsViewController: UIViewController, UIScrollViewDelegate {
    
    // Theme
    private let themeColor = UIColor.themePlum
    
    // Core UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Search Controller
    private let searchController = UISearchController(searchResultsController: nil)
    
    // Title bar
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Explore Jobs"
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        l.textColor = .label
        return l
    }()
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Discover your next role"
        l.font = UIFont.systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        return l
    }()
    private lazy var bookmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        btn.setImage(UIImage(systemName: "bookmark", withConfiguration: config), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 44).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return btn
    }()
    private lazy var filterButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        btn.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle", withConfiguration: config), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 44).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return btn
    }()
    
    // Search bar container
    private let searchBarContainer = UIView()
    
    // Post buttons
    private let postButtonsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 12
        s.distribution = .fillEqually
        return s
    }()
    
    // Curated header
    private let curatedLabel: UILabel = {
        let l = UILabel()
        l.text = "Curated for You"
        l.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .label
        return l
    }()
    private let curatedSubtitle: UILabel = {
        let l = UILabel()
        l.text = "Opportunities that match your profile"
        l.font = UIFont.systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        return l
    }()
    
    // Job list
    private let jobListStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        return s
    }()
    
    // Dim + Filter
    private var dimView = UIView()
    private var filterVC: FilterScrollViewController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSearchController()
        setupScrollView()
        setupTitleBar()
        setupSearchBar()
        setupPostButtons()
        setupCuratedAndJobs()
        setupBottomSpacing()
        
        filterButton.addTarget(self, action: #selector(openFilter), for: .touchUpInside)
        bookmarkButton.addTarget(self, action: #selector(openSavedPosts), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload job cards when view appears
        reloadJobCards()
    }
    
    // MARK: - Search Controller Setup
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search jobs"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.backgroundColor = .clear
        definesPresentationContext = true
    }
    
    // MARK: - ScrollView & Content
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    // Title bar at top of content
    private func setupTitleBar() {
        let titleBar = UIStackView(arrangedSubviews: [titleLabel, UIView(), bookmarkButton, filterButton])
        titleBar.axis = .horizontal
        titleBar.alignment = .center
        titleBar.spacing = 4
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleBar)
        contentView.addSubview(subtitleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleBar.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleBar.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    // Search bar below title
    private func setupSearchBar() {
        contentView.addSubview(searchBarContainer)
        searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the search bar to the container
        searchBarContainer.addSubview(searchController.searchBar)
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBarContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            searchBarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            searchBarContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            searchController.searchBar.topAnchor.constraint(equalTo: searchBarContainer.topAnchor),
            searchController.searchBar.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor),
            searchController.searchBar.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor),
            searchController.searchBar.bottomAnchor.constraint(equalTo: searchBarContainer.bottomAnchor)
        ])
    }
    
    // Post buttons row
    private func setupPostButtons() {
        contentView.addSubview(postButtonsStack)
        postButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            postButtonsStack.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor, constant: 16),
            postButtonsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postButtonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postButtonsStack.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let titles = ["Post Job", "My Jobs", "Posted"]
        for t in titles {
            let btn = UIButton(type: .system)
            btn.setTitle(t, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            btn.setTitleColor(.label, for: .normal)
            btn.layer.cornerRadius = 10
            btn.backgroundColor = .systemBackground
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.separator.cgColor
            
            makeShadow(on: btn)
            
            switch t {
            case "Post Job": btn.addTarget(self, action: #selector(postJobTapped), for: .touchUpInside)
            case "My Jobs": btn.addTarget(self, action: #selector(myJobsTapped), for: .touchUpInside)
            case "Posted": btn.addTarget(self, action: #selector(didTapPosted), for: .touchUpInside)
            default: break
            }
            
            postButtonsStack.addArrangedSubview(btn)
        }
    }
    
    // Curated header + job list
    private func setupCuratedAndJobs() {
        [curatedLabel, curatedSubtitle, jobListStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Add separator line
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            curatedLabel.topAnchor.constraint(equalTo: postButtonsStack.bottomAnchor, constant: 32),
            curatedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            curatedSubtitle.topAnchor.constraint(equalTo: curatedLabel.bottomAnchor, constant: 4),
            curatedSubtitle.leadingAnchor.constraint(equalTo: curatedLabel.leadingAnchor),
            curatedSubtitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            separator.topAnchor.constraint(equalTo: curatedSubtitle.bottomAnchor, constant: 16),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            
            jobListStack.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16),
            jobListStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            jobListStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    // Ensure bottom spacing
    private func setupBottomSpacing() {
        // add a spacer view so contentView has a bottom constraint for scrolling
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spacer)
        NSLayoutConstraint.activate([
            spacer.topAnchor.constraint(equalTo: jobListStack.bottomAnchor),
            spacer.heightAnchor.constraint(equalToConstant: 160),
            spacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            spacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            spacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Job Cards Management
    private func reloadJobCards() {
        // Clear existing cards
        jobListStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Load new cards
        Task { [weak self] in
            await self?.addJobCards()
        }
    }
    
    // MARK: - Sample job cards (uses your JobCardView)
    private func addJobCards() async {
        do {
            let jobs = try await JobsService.shared.fetchActiveJobs()
            
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                for job in jobs {
                    let card = JobCardView()

                    card.configure(
                        image: UIImage(named: "rani2"),
                        title: job.title,
                        company: job.companyName,
                        location: job.location,
                        salary: "₹ \(job.ratePerDay)/day",
                        daysLeft: job.daysLeftText,
                        tag: job.jobType,
                        appliedCount: "0 applied" // replace later with real count
                    )
                    
                    // Set up card tap handler
                    card.onTap = { [weak self] in
                        let detailVC = JobDetailsViewController()
                        detailVC.job = job // Pass job data
                        self?.navigationController?.pushViewController(detailVC, animated: true)
                    }

                    self.jobListStack.addArrangedSubview(card)
                }
            }
        } catch {
            print("Error loading jobs: \(error)")
        }
    }


    
    // MARK: - Actions
    @objc private func postJobTapped() {
        // Check if user has already filled profile information
        Task {
            let hasProfile = await checkIfProfileExists()
            await MainActor.run {
                if hasProfile {
                    // Profile exists, go directly to PostJobViewController
                    let vc = PostJobViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    // No profile, show ProfileInfoViewController first
                    let vc = ProfileInfoViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    private func checkIfProfileExists() async -> Bool {
        guard let userId = supabase.auth.currentUser?.id else {
            print("❌ User not authenticated")
            return false
        }
        
        do {
            let response = try await supabase
                .from("casting_profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
            
            // If we successfully got a response, profile exists
            let profile = try JSONDecoder().decode(CastingProfileRecord.self, from: response.data)
            print("✅ Profile exists: \(profile.companyName ?? "N/A")")
            return true
        } catch {
            print("ℹ️ No profile found: \(error)")
            return false
        }
    }
    @objc private func myJobsTapped() {
        let vc = MyApplicationsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func didTapPosted() {
        let vc = PostedJobsDashboardViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func openSavedPosts() {
        let vc = SavedPostViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Filter sheet
    @objc private func openFilter() {
        let vc = FilterScrollViewController()
        filterVC = vc
        
        dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        view.addSubview(dimView)
        dimView.alpha = 0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeFilter))
        dimView.addGestureRecognizer(tap)
        
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        let height: CGFloat = view.frame.height * 0.72
        vc.view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        vc.view.layer.cornerRadius = 20
        vc.view.clipsToBounds = true
        
        UIView.animate(withDuration: 0.28) {
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.32)
            self.dimView.alpha = 1
            vc.view.frame.origin.y = self.view.frame.height - height
        }
    }
    
    @objc private func closeFilter() {
        guard let vc = filterVC else { return }
        let height = vc.view.frame.height
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView.alpha = 0
            vc.view.frame.origin.y = self.view.frame.height
        }) { _ in
            self.dimView.removeFromSuperview()
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
    }
    
    // Scroll fade header
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

// MARK: - UISearchResultsUpdating
extension jobsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        // TODO: Implement search filtering logic here
        print("Searching for: \(searchText)")
    }
}
