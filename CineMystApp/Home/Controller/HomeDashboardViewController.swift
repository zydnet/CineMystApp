//
//  HomeDashboardViewController.swift
//  CineMystApp
//
//  Created by Devanshi on 11/11/25.
//



//
//  HomeDashboardViewController.swift
//  CineMystApp
//
//  Created by Devanshi on 11/11/25.
//

import UIKit
import SwiftUI
import PhotosUI

final class HomeDashboardViewController: UIViewController {

    // MARK: - Views
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)

    /// SwiftUI floating menu
    private var floatingMenuContainer: UIView!

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
        setupFloatingMenu()

        navigationItem.backButtonTitle = ""
    }

    // MARK: - Floating Menu Setup
    private func setupFloatingMenu() {
        
        let swiftUIView = FloatingMenuButton(
            didTapStory: { [weak self] in
                self?.openCamera()
            },
            didTapPost: { [weak self] in
                print("📝 Post button tapped (optional screen)")
            },
            didTapGallery: { [weak self] in
                self?.openGallery()
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 70),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 110),
            hostingController.view.widthAnchor.constraint(equalToConstant: 220),
            hostingController.view.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        hostingController.didMove(toParent: self)
    }

    // MARK: - Navigation Bar
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

        searchController.searchBar.placeholder = "Search posts or jobs"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    // MARK: - Table Setup
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .systemBackground

        tableView.register(PostCellTableViewCell.self,
                           forCellReuseIdentifier: PostCellTableViewCell.reuseId)

        tableView.register(JobCardCell.self,
                           forCellReuseIdentifier: JobCardCell.reuseId)

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
                 caption: "Just wrapped filming my short film!",
                 likes: 120, comments: 35, shares: 15,
                 imageName: "emma",
                 userImageName: "avatar_rani"),

            Post(username: "Ava Raj",
                 title: "Director • 2h",
                 caption: "Next casting call incoming 🎬",
                 likes: 86, comments: 12, shares: 5,
                 imageName: "city",
                 userImageName: "avatar_ava")
        ]

        jobs = [
            Job(role: "Lead Actor - City of Dreams",
                company: "YRF Casting",
                location: "Mumbai",
                pay: "₹5k/day",
                tag: "Web Series",
                applicants: 8,
                daysLeft: 2,
                logoName: "jobicon"),

            Job(role: "Assistant Director - Feature Film",
                company: "Red Chillies Entertainment",
                location: "Mumbai",
                pay: "₹3k/day",
                tag: "Film",
                applicants: 15,
                daysLeft: 5,
                logoName: "jobicon")
        ]

        tableView.reloadData()
    }

    // MARK: - Header Button Actions
    @objc private func profileTapped() {
        navigationController?.pushViewController(ProfileViewController(), animated: true)
    }

    @objc private func bellTapped() {
        let vc = NotificationsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Comment / Share Actions
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

// MARK: - Search Delegate
extension HomeDashboardViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        navigationController?.pushViewController(SearchViewController(), animated: true)
        return false
    }
}

// MARK: - Table Delegates
extension HomeDashboardViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? posts.count : jobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PostCellTableViewCell.reuseId,
                for: indexPath
            ) as! PostCellTableViewCell

            let post = posts[indexPath.row]
            cell.configure(with: post)

            cell.profileTapped = { [weak self] in
                self?.navigationController?.pushViewController(ProfileViewController(), animated: true)
            }
            cell.commentTapped = { [weak self] in
                self?.openComments(for: post)
            }
            cell.shareTapped = { [weak self] in
                self?.openShareSheet(for: post)
            }

            return cell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: JobCardCell.reuseId,
            for: indexPath) as! JobCardCell

        cell.configure(with: jobs[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 440 : 180
    }
}

//
// MARK: - CAMERA + GALLERY + INSTAGRAM POST FLOW
//
extension HomeDashboardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    // MARK: - CAMERA
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        
        present(picker, animated: true)
    }

    // MARK: - MULTI SELECT GALLERY
    func openGallery() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0   // Instagram style unlimited
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        present(picker, animated: true)
    }

    // MARK: - PHPicker RESULT
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        var images: [UIImage] = []
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                if let img = image as? UIImage {
                    images.append(img)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.openCreatePost(images: images)
        }
    }

    // MARK: - CAMERA RESULT
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            openCreatePost(images: [image])
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    // MARK: - MOVE TO INSTAGRAM-LIKE POST SCREEN
    func openCreatePost(images: [UIImage]) {
        let vc = NewPostViewController(images: images)
        vc.modalPresentationStyle = .fullScreen
        
        vc.onPostCompleted = { [weak self] in
            self?.dismiss(animated: true)
            self?.tableView.reloadData()
        }
        
        present(vc, animated: true)
    }
}
