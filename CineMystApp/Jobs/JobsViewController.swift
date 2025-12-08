import UIKit

// MARK: - Colors & Helpers
fileprivate extension UIColor {
    static let themePlum = UIColor(red: 67/255, green: 22/255, blue: 49/255, alpha: 1)
    static let softGrayBg = UIColor(red: 247/255, green: 245/255, blue: 247/255, alpha: 1)
}

fileprivate func makeShadow(on view: UIView, radius: CGFloat = 6, yOffset: CGFloat = 4, opacity: Float = 0.12) {
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
        l.text = "Explore jobs"
        l.font = UIFont.boldSystemFont(ofSize: 34)
        return l
    }()
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Discover your next role"
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor.systemGray
        return l
    }()
    private lazy var bookmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "bookmark"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 26).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 26).isActive = true
        return btn
    }()
    private lazy var filterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 26).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 26).isActive = true
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
        l.text = "Curated for you"
        l.font = UIFont.boldSystemFont(ofSize: 22)
        return l
    }()
    private let curatedSubtitle: UILabel = {
        let l = UILabel()
        l.text = "Opportunities that match your expertise and aspirations"
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .systemGray
        l.numberOfLines = 2
        return l
    }()
    
    // Job list
    private let jobListStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        return s
    }()
    
    // Dim + Filter
    private var dimView = UIView()
    private var filterVC: FilterScrollViewController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        applyTheme()
        
        setupSearchController()
        setupScrollView()
        setupTitleBar()
        setupSearchBar()
        setupPostButtons()
        setupCuratedAndJobs()
        setupBottomSpacing()
        
        filterButton.addTarget(self, action: #selector(openFilter), for: .touchUpInside)
        bookmarkButton.addTarget(self, action: #selector(openSavedPosts), for: .touchUpInside)
        
        // Add sample job cards
        addJobCards()
    }
    
    private func applyTheme() {
        titleLabel.textColor = themeColor
        curatedLabel.textColor = themeColor
        bookmarkButton.tintColor = .black
        filterButton.tintColor = .black
    }
    
    // MARK: - Search Controller Setup
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search opportunities"
        searchController.searchBar.tintColor = themeColor
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    // MARK: - ScrollView & Content
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        
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
        titleBar.spacing = 12
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleBar)
        contentView.addSubview(subtitleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleBar.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleBar.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
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
            searchBarContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            searchBarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            searchBarContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
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
            postButtonsStack.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor, constant: 18),
            postButtonsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            postButtonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            postButtonsStack.heightAnchor.constraint(equalToConstant: 42)
        ])
        
        let titles = ["Post a job", "My Jobs", "Posted"]
        for t in titles {
            let btn = UIButton(type: .system)
            btn.setTitle(t, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            btn.setTitleColor(.black, for: .normal)
            btn.layer.cornerRadius = 12
            btn.backgroundColor = .white
            
            btn.contentEdgeInsets = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18)
            // shadow
            makeShadow(on: btn, radius: 6, yOffset: 4, opacity: 0.12)
            btn.layer.borderWidth = 0.3
            btn.layer.borderColor = UIColor.systemGray4.cgColor
            
            switch t {
            case "Post a job": btn.addTarget(self, action: #selector(postJobTapped), for: .touchUpInside)
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
        
        NSLayoutConstraint.activate([
            curatedLabel.topAnchor.constraint(equalTo: postButtonsStack.bottomAnchor, constant: 34),
            curatedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            curatedSubtitle.topAnchor.constraint(equalTo: curatedLabel.bottomAnchor, constant: 6),
            curatedSubtitle.leadingAnchor.constraint(equalTo: curatedLabel.leadingAnchor),
            curatedSubtitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            jobListStack.topAnchor.constraint(equalTo: curatedSubtitle.bottomAnchor, constant: 30),
            jobListStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            jobListStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
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
    
    // MARK: - Sample job cards (uses your JobCardView)
    private func addJobCards() {
        let jobs = [
            ("Lead Actor - Drama Series City of Dreams", "YRF Casting", "Mumbai, India", "₹ 5k/day", "2 days left", "Web Series"),
            ("Assistant Director- Feature Film", "Red Chillies Entertainment", "Delhi, India", "₹ 8k/day", "5 days left", "Feature Film"),
            ("Background Dancer", "T-Series", "Pune, India", "₹ 3k/day", "1 day left", "Music Video"),
            ("Camera Operator", "Balaji Motion Pictures", "Hyderabad, India", "₹ 6k/day", "3 days left", "Web Series")
        ]
        
        for job in jobs {
            let card = JobCardView() // <-- your existing view; keep as is
            card.configure(
                image: UIImage(named: "rani2"),
                title: job.0,
                company: job.1,
                location: job.2,
                salary: job.3,
                daysLeft: job.4,
                tag: job.5
            )
            
            card.onTap = { [weak self] in
                let vc = JobDetailsViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            card.onApplyTap = { [weak self] in
                let vc = ApplicationStartedViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            jobListStack.addArrangedSubview(card)
        }
    }
    
    // MARK: - Actions
    @objc private func postJobTapped() {
        let vc = ProfileInfoViewController()
        navigationController?.pushViewController(vc, animated: true)
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
