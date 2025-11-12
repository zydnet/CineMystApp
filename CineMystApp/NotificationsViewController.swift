//
//  NotificationsViewController.swift
//  CineMystApp
//
//  Created by user@50 on 12/11/25.
//

//
//  NotificationsViewController.swift
//  CineMystApp
//
//  Created by Devanshi on 12/11/25.
//

import UIKit

struct NotificationItem {
    let imageName: String?   // systemName or asset name
    let title: String
    let message: String
    let timeAgo: String
    let showConnectButton: Bool
    let isSystemIcon: Bool
}

final class NotificationsViewController: UIViewController {
    
    // MARK: - Views
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: - Data
    private var notifications: [NotificationItem] = []
    private var filteredNotifications: [NotificationItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .systemBackground
        setupSearchController()
        setupTableView()
        loadDummyNotifications()
    }
    
    // MARK: - Setup UI
    private func setupSearchController() {
        searchController.searchBar.placeholder = "Search"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Load Dummy Notifications
    private func loadDummyNotifications() {
        notifications = [
            NotificationItem(imageName: "megaphone.fill",
                             title: "KGF Casting",
                             message: "You have a new job posting.",
                             timeAgo: "1 day ago",
                             showConnectButton: false,
                             isSystemIcon: true),
            
            NotificationItem(imageName: "checkmark.seal.fill",
                             title: "YRF Casting",
                             message: "Thanks for your application! We’ll be in touch with you shortly.",
                             timeAgo: "13 days ago",
                             showConnectButton: false,
                             isSystemIcon: true),
            
            NotificationItem(imageName: "avatar_adrea", // image in assets
                             title: "Adrea Marsi",
                             message: "Your mentoring session has been rescheduled. Kindly check your mail.",
                             timeAgo: "15 days ago",
                             showConnectButton: false,
                             isSystemIcon: false),
            
            NotificationItem(imageName: "avatar_potter",
                             title: "mis_potter started following you.",
                             message: "3d",
                             timeAgo: "",
                             showConnectButton: true,
                             isSystemIcon: false)
        ]
        filteredNotifications = notifications
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let item = filteredNotifications[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // You can navigate to a related screen depending on notification type
    }
}

// MARK: - UISearchResultsUpdating
extension NotificationsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            filteredNotifications = notifications
            tableView.reloadData()
            return
        }
        
        filteredNotifications = notifications.filter { $0.title.lowercased().contains(query.lowercased()) }
        tableView.reloadData()
    }
}
