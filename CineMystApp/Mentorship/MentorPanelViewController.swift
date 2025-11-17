//
//  MentorPanelViewController.swift
//  ProgrammaticMentorship
//

import UIKit

final class MentorPanelViewController: UIViewController {

    private let plum = UIColor(red: 0x43/255, green: 0x16/255, blue: 0x31/255, alpha: 1)

    // Header
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Mentorship"
        l.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Discover & learn from your mentor"
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private lazy var segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Mentee", "Mentor"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .white
        sc.backgroundColor = UIColor.systemGray5
        sc.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .normal)
        sc.layer.cornerRadius = 18
        sc.layer.masksToBounds = true
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    // My Session / Calls header
    private let sessionsTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "My Session"
        l.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let sessionsSeeAllButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("See all", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private lazy var sessionsTableView: UITableView = {
        let tv = UITableView()
        tv.register(SessionCell.self, forCellReuseIdentifier: SessionCell.reuseIdentifier)
        tv.register(CallCell.self, forCellReuseIdentifier: CallCell.reuseIdentifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.estimatedRowHeight = 100
        tv.rowHeight = UITableView.automaticDimension
        return tv
    }()

    // Mentors list
    private let mentorsLabel: UILabel = {
        let l = UILabel()
        l.text = "Mentors"
        l.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let mentorsSeeAllButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("See all", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MentorCell.self, forCellWithReuseIdentifier: MentorCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        // disable vertical scrolling because we will size the collection view to fit exactly one row
        cv.isScrollEnabled = false
        cv.alwaysBounceVertical = false
        return cv
    }()

    // Data - only 2 mentors to show at once (one row of two cards)
    private var sessions: [Session] = []
    private var calls: [Call] = []
    private var mentors: [Mentor] = [
        Mentor(name: "Nathan Hales", role: "Actor", rating: 4.9, imageName: "Image"),
        Mentor(name: "Ava Johnson", role: "Casting Director", rating: 4.8, imageName: "Image")
    ]

    private var sessionsTableHeightConstraint: NSLayoutConstraint!
    private var collectionViewHeightConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        titleLabel.textColor = plum

        setupHierarchy()
        setupConstraints()
        wireDelegates()

        sessions = SessionStore.shared.all()
        loadSampleCallsIfNeeded()
        updateSessionsLayout()

        // ensure the segment initial state is applied
        segmentChanged(segmentControl)

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSessionNotification(_:)), name: .sessionUpdated, object: nil)

        // Hide back button / disable interactive pop so this panel behaves as a tab's root
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSessions()

        // Ensure this VC is the root of navigation stack to avoid showing a back button
        if let nav = navigationController {
            if nav.viewControllers.first != self {
                nav.setViewControllers([self], animated: false)
            }
            nav.interactivePopGestureRecognizer?.isEnabled = false
        }

        // ensure tab bar is visible
        tabBarController?.tabBar.isHidden = false
    }

    // adjust collection view height to exactly one row of items
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // compute the item height for one row with the current collection view width
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let insets = layout.sectionInset.left + layout.sectionInset.right
        let spacing = layout.minimumInteritemSpacing

        // width for each item (2 columns)
        let columnWidth = floor((collectionView.bounds.width - insets - spacing) / 2.0)
        let itemHeight = columnWidth * 0.85

        // total collectionView height = top inset + itemHeight + bottom inset
        let totalHeight = layout.sectionInset.top + itemHeight + layout.sectionInset.bottom

        collectionViewHeightConstraint.constant = ceil(totalHeight)
    }

    // MARK: - Setup
    private func setupHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(segmentControl)

        view.addSubview(sessionsTitleLabel)
        view.addSubview(sessionsSeeAllButton)
        view.addSubview(sessionsTableView)

        view.addSubview(mentorsLabel)
        view.addSubview(mentorsSeeAllButton)
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        let pad: CGFloat = 20

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            segmentControl.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 18),
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalToConstant: 220),
            segmentControl.heightAnchor.constraint(equalToConstant: 36),

            sessionsTitleLabel.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 18),
            sessionsTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),

            sessionsSeeAllButton.centerYAnchor.constraint(equalTo: sessionsTitleLabel.centerYAnchor),
            sessionsSeeAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            sessionsTableView.topAnchor.constraint(equalTo: sessionsTitleLabel.bottomAnchor, constant: 12),
            sessionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            sessionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            mentorsLabel.topAnchor.constraint(equalTo: sessionsTableView.bottomAnchor, constant: 22),
            mentorsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),

            mentorsSeeAllButton.centerYAnchor.constraint(equalTo: mentorsLabel.centerYAnchor),
            mentorsSeeAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            collectionView.topAnchor.constraint(equalTo: mentorsLabel.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            // bottom is not pinned because we'll set a fixed height to avoid scrolling
        ])

        // height constraints
        sessionsTableHeightConstraint = sessionsTableView.heightAnchor.constraint(equalToConstant: 0)
        sessionsTableHeightConstraint.isActive = true

        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 200)
        collectionViewHeightConstraint.isActive = true

        // bottom spacing under collection ensures content doesn't run to the bottom edge
        let bottomGap = collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        bottomGap.priority = .defaultLow
        bottomGap.isActive = true
    }

    private func wireDelegates() {
        sessionsTableView.dataSource = self
        sessionsTableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self

        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        sessionsSeeAllButton.addTarget(self, action: #selector(didTapSessionsSeeAll), for: .touchUpInside)
        mentorsSeeAllButton.addTarget(self, action: #selector(didTapMentorsSeeAll), for: .touchUpInside)
    }

    // MARK: - Notifications / Data
    @objc private func didReceiveSessionNotification(_ n: Notification) {
        reloadSessions()
    }

    func reloadSessions() {
        sessions = SessionStore.shared.all()
        updateSessionsLayout()
    }

    private func updateSessionsLayout() {
        DispatchQueue.main.async {
            self.sessionsTableView.reloadData()
            self.sessionsTableView.layoutIfNeeded()
            self.sessionsTableHeightConstraint.constant = self.sessionsTableView.contentSize.height
        }
    }

    @objc private func segmentChanged(_ s: UISegmentedControl) {
        if s.selectedSegmentIndex == 0 {
            sessionsTitleLabel.text = "My Session"
        } else {
            sessionsTitleLabel.text = "Calls"
        }
        updateSessionsLayout()
    }

    @objc private func didTapSessionsSeeAll() {
        if segmentControl.selectedSegmentIndex == 0 {
            let vc = UpcomingViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // <-- updated: push the AllCalls screen (use the panel controller we added earlier)
            let vc = AllCallsPanelViewController() // if you want AllCallsViewController() instead, swap here
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func didTapMentorsSeeAll() {
        let vc = AllMentorsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func loadSampleCallsIfNeeded() {
        guard calls.isEmpty else { return }
        let calendar = Calendar.current
        calls = [
            Call(id: "1", mentorName: "Amit Sawi", mentorRole: "Junior Artist", date: calendar.date(byAdding: .day, value: 2, to: Date())!, services: ["Acting", "Voice Over"], avatarName: "Image", status: .upcoming),
            Call(id: "2", mentorName: "Amit Sawi", mentorRole: "Junior Artist", date: calendar.date(byAdding: .day, value: -2, to: Date())!, services: ["Acting", "Voice Over"], avatarName: "Image", status: .ended)
        ]
    }
}

// MARK: - Table + Collection delegates
extension MentorPanelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentControl.selectedSegmentIndex == 0 ? sessions.count : calls.count
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentControl.selectedSegmentIndex == 0 {
            let cell = tv.dequeueReusableCell(withIdentifier: SessionCell.reuseIdentifier, for: indexPath) as! SessionCell
            cell.configure(with: sessions[indexPath.row])
            return cell
        } else {
            let cell = tv.dequeueReusableCell(withIdentifier: CallCell.reuseIdentifier, for: indexPath) as! CallCell
            cell.configure(with: calls[indexPath.row])
            return cell
        }
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)

        if segmentControl.selectedSegmentIndex == 0 {
            let vc = SessionDetailViewController()
            vc.session = sessions[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CallDetailViewController()
            vc.call = calls[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MentorPanelViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mentors.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = cv.dequeueReusableCell(withReuseIdentifier: MentorCell.reuseIdentifier, for: indexPath) as! MentorCell
        c.configure(with: mentors[indexPath.item])
        return c
    }

    func collectionView(_ cv: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 160, height: 170)
        }
        let insets = layout.sectionInset.left + layout.sectionInset.right
        let spacing = layout.minimumInteritemSpacing
        let width = floor((cv.bounds.width - insets - spacing) / 2.0)
        return CGSize(width: width, height: width * 0.85)
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = BookViewController()
        vc.mentor = mentors[indexPath.item]
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
