//
//  HomeDashboardViewController.swift
//  CineMystApp
//
//  Created by Devanshi on 11/11/25.
//

import UIKit

final class HomeDashboardViewController: UIViewController {

    // MARK: - Views
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Data
    private var posts: [Post] = []
    private var jobs: [Job] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTable()
        loadDummyData()
        navigationItem.backButtonTitle = ""
    }

    // MARK: - Navigation Bar (Header + Search)
    private func setupNavigationBar() {
        navigationItem.title = "CineMyst"
        navigationController?.navigationBar.prefersLargeTitles = true

        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        let bellButton = UIBarButtonItem(
            image: UIImage(systemName: "bell"),
            style: .plain,
            target: self,
            action: #selector(bellTapped)
        )

        navigationItem.rightBarButtonItems = [bellButton, profileButton]

        // Configure SearchController
        searchController.searchBar.placeholder = "Search posts or jobs"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    // MARK: - Setup Table
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .systemBackground

        tableView.register(PostCellTableViewCell.self, forCellReuseIdentifier: PostCellTableViewCell.reuseId)
        tableView.register(JobCardCell.self, forCellReuseIdentifier: JobCardCell.reuseId)

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Dummy Data
    private func loadDummyData() {
        posts = [
            Post(username: "Rani HBO",
                 title: "Professional Actor • 4h",
                 caption: "Just wrapped filming my latest short film! So grateful to the team.",
                 likes: 120, comments: 35, shares: 15,
                 imageName: "emma",
                 userImageName: "avatar_rani"),

            Post(username: "Ava Raj",
                 title: "Director • 2h",
                 caption: "Excited to announce our next casting call!",
                 likes: 86, comments: 12, shares: 5,
                 imageName: "city",
                 userImageName: "avatar_ava")
        ]

        jobs = [
            Job(role: "Lead Actor - Drama Series 'City of Dreams'",
                company: "YRF Casting",
                location: "Mumbai, India",
                pay: "₹5k/day",
                tag: "Web Series",
                applicants: 8,
                daysLeft: 2,
                logoName: "jobicon"),

            Job(role: "Assistant Director - Feature Film",
                company: "Red Chillies Entertainment",
                location: "Mumbai, India",
                pay: "₹3k/day",
                tag: "Film",
                applicants: 15,
                daysLeft: 5,
                logoName: "jobicon")
        ]

        tableView.reloadData()
    }

    // MARK: - Top Bar Actions
    @objc private func profileTapped() {
        let myProfileVC = ProfileViewController()
        navigationController?.pushViewController(myProfileVC, animated: true)
    }

    @objc private func bellTapped() {
        print("🔔 Notifications tapped")
    }

    // MARK: - Navigation to Comment or Share
    func openComments(for post: Post) {
        let vc = CommentViewController(post: post)
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }

    func openShareSheet(for post: Post) {
        let vc = ShareBottomSheetController(post: post)
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension HomeDashboardViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // Navigate to Search Screen when search bar is tapped
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
        return false
    }
}

// MARK: - TableView
extension HomeDashboardViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? posts.count : jobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PostCellTableViewCell.reuseId, for: indexPath) as! PostCellTableViewCell
            let post = posts[indexPath.row]
            cell.configure(with: post)

            // ✅ Handle profile tap navigation
            cell.profileTapped = { [weak self] in
                guard let self = self else { return }
                let profileVC = ProfileViewController()
                profileVC.hidesBottomBarWhenPushed = true

                // ✅ Hide floating button while in profile
                if let tabBarController = self.tabBarController as? CineMystTabBarController {
                    tabBarController.setFloatingButtonVisible(false)
                }

                self.navigationController?.pushViewController(profileVC, animated: true)
            }

            // ✅ Handle comment tap
            cell.commentTapped = { [weak self] in
                guard let self = self else { return }
                self.openComments(for: post)
            }

            // ✅ Handle share tap
            cell.shareTapped = { [weak self] in
                guard let self = self else { return }
                self.openShareSheet(for: post)
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: JobCardCell.reuseId, for: indexPath) as! JobCardCell
            cell.configure(with: jobs[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 440 : 180
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Recent Posts" : "Casting Calls"
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            header.textLabel?.textColor = .label
        }
    }
}
