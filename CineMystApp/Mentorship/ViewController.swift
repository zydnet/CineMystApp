//
//  BookViewController.swift
//  CineMystApp
//
//  Created by You on Today.
//

import UIKit

final class BookViewController: UIViewController {

    // Public property - set before presenting/pushing
    var mentor: Mentor? {
        didSet { applyMentorIfNeeded() }
    }

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Image")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    private var headerHeightConstraint: NSLayoutConstraint?

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let roleLabel: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        return l
    }()

    private let portfolioButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Portfolio"
        config.baseForegroundColor = .systemBlue
        let b = UIButton(configuration: config)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return b
    }()

    // starsView is a placeholder stack we can update when mentor is set
    private var starsView: UIStackView = {
        starStack(rating: 4.0, max: 5, size: 16)
    }()

    private let reviewsCountLabel: UILabel = {
        let l = UILabel()
        l.text = "15 reviews"
        l.font = .systemFont(ofSize: 11)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        return l
    }()

    private func statBlock(title: String, value: String) -> UIStackView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        valueLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        let v = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 4
        v.layoutMargins = .init(top: 8, left: 12, bottom: 8, right: 12)
        v.isLayoutMarginsRelativeArrangement = true
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 14
        return v
    }

    private lazy var statsRow: UIStackView = {
        let s1 = statBlock(title: "Year Exp", value: "10+")
        let s2 = statBlock(title: "Mentor", value: "4 ★")
        let s3 = statBlock(title: "Sessions", value: "50+")
        let h = UIStackView(arrangedSubviews: [s1, s2, s3])
        h.axis = .horizontal
        h.distribution = .fillEqually
        h.spacing = 12
        return h
    }()

    private let aboutTitle: UILabel = sectionTitle("About")
    private let aboutText: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 14)
        l.text = """
As a Senior Director, I lead cross-functional teams to craft user-centered digital experiences that balance business goals with user needs. With a strong background in design strategy, user research, and product development,
"""
        return l
    }()

    private let mentorshipTitle: UILabel = sectionTitle("Mentorship Area")
    private let mentorshipText: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 14)
        l.text = "Acting, Dubbing, Design Thinking, Career Guidance"
        return l
    }()

    private let reviewsTitle: UILabel = sectionTitle("Reviews")
    private lazy var reviewOne = reviewView(
        avatar: UIImage(systemName: "person.circle"),
        name: "Sophia Clark",
        timeAgo: "2 weeks ago",
        rating: 5,
        text: "The session was fantastic! The instructor was very knowledgeable and made the class enjoyable. I learned a lot and will definitely be booking another session soon."
    )
    private lazy var reviewTwo = reviewView(
        avatar: UIImage(systemName: "person.circle"),
        name: "Ethan Carter",
        timeAgo: "1 month ago",
        rating: 4,
        text: "The session was good overall. The instructor was helpful, but the class could have been more structured. I still learned a few things and would consider booking again."
    )

    private let moreReviewsButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "View more reviews"
        config.baseForegroundColor = .systemBlue
        let b = UIButton(configuration: config)
        b.contentHorizontalAlignment = .leading
        return b
    }()

    private let bookButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Book Session"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(red: 0x43/255.0, green: 0x16/255.0, blue: 0x31/255.0, alpha: 1.0)
        config.baseForegroundColor = .white
        let b = UIButton(configuration: config)
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        b.configurationUpdateHandler = { button in
            button.configuration?.baseBackgroundColor = button.isHighlighted
                ? UIColor(red: 0x43/255.0, green: 0x16/255.0, blue: 0x31/255.0, alpha: 0.85)
                : UIColor(red: 0x43/255.0, green: 0x16/255.0, blue: 0x31/255.0, alpha: 1.0)
        }
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        scrollView.contentInsetAdjustmentBehavior = .never
        navigationController?.navigationBar.isTranslucent = true

        // DO NOT show the nav title over the image
        navigationItem.title = ""
        if #available(iOS 14.0, *) {
            navigationItem.backButtonDisplayMode = .minimal
        } else {
            navigationController?.navigationBar.topItem?.title = ""
        }

        setupLayout()
        bookButton.addTarget(self, action: #selector(didTapBookSession), for: .touchUpInside)

        applyMentorIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide tab bar (if this VC was pushed with hidesBottomBarWhenPushed = true it will be hidden automatically)
        tabBarController?.tabBar.isHidden = true
        // Hide the floating button if our tab bar controller is CineMystTabBarController
       

        // Transparent navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Restore tab bar and floating button
        tabBarController?.tabBar.isHidden = false
      
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerHeightConstraint?.constant = 260 + view.safeAreaInsets.top
    }

    // MARK: Actions
    @objc private func didTapBookSession() {
        let vc = ScheduleSessionViewController() // ensure this exists in your project
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: Layout
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -72)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Header image
        contentView.addSubview(headerImageView)
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerHeightConstraint = headerImageView.heightAnchor.constraint(equalToConstant: 260)
        headerHeightConstraint?.isActive = true
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        // Card container
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 24
        card.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -24),
            card.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        // Stacks
        let headerStack = UIStackView(arrangedSubviews: [nameLabel, roleLabel, portfolioButton, starsView, reviewsCountLabel])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 6

        let aboutStack = UIStackView(arrangedSubviews: [aboutTitle, aboutText])
        aboutStack.axis = .vertical
        aboutStack.spacing = 8

        let mentorshipStack = UIStackView(arrangedSubviews: [mentorshipTitle, mentorshipText])
        mentorshipStack.axis = .vertical
        mentorshipStack.spacing = 8

        let reviewsStack = UIStackView(arrangedSubviews: [reviewsTitle, reviewOne, reviewTwo, moreReviewsButton])
        reviewsStack.axis = .vertical
        reviewsStack.spacing = 12

        let mainStack = UIStackView(arrangedSubviews: [headerStack, statsRow, aboutStack, mentorshipStack, reviewsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 18

        card.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        // Bottom Book button
        view.addSubview(bookButton)
        bookButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bookButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bookButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bookButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bookButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    // Called when mentor is set (and after view loads)
    private func applyMentorIfNeeded() {
        guard isViewLoaded else { return }
        applyMentor()
    }

    private func applyMentor() {
        guard let mentor = mentor else { return }

        // DO NOT set navigation title here (we previously did `title = mentor.name` which caused the label on the image).
        // Keep the name inside the card only:
        nameLabel.text = mentor.name
        roleLabel.text = mentor.role

        updateStarsView(with: mentor.rating)

        if let imgName = mentor.imageName, let img = UIImage(named: imgName) {
            headerImageView.image = img
            headerImageView.contentMode = .scaleAspectFill
        } else {
            headerImageView.image = UIImage(systemName: "person.crop.rectangle")
            headerImageView.tintColor = .systemGray3
            headerImageView.contentMode = .center
        }
    }

    private func updateStarsView(with rating: Double) {
        // clear existing arranged subviews
        while !starsView.arrangedSubviews.isEmpty {
            let v = starsView.arrangedSubviews[0]
            starsView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        let new = starStack(rating: rating, max: 5, size: 16)
        for v in new.arrangedSubviews {
            starsView.addArrangedSubview(v)
        }
    }
}

// MARK: - Helpers
private func sectionTitle(_ text: String) -> UILabel {
    let l = UILabel()
    l.text = text
    l.font = .systemFont(ofSize: 16, weight: .semibold)
    l.textColor = .label
    return l
}

private func starStack(rating: Double, max: Int, size: CGFloat = 14) -> UIStackView {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 2
    stack.alignment = .center

    let full = Int(rating.rounded(.down))
    let hasHalf = (rating - Double(full)) >= 0.25 && (rating - Double(full)) < 0.75

    for i in 0..<max {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemYellow
        if i < full {
            iv.image = UIImage(systemName: "star.fill")
        } else if i == full && hasHalf {
            iv.image = UIImage(systemName: "star.leadinghalf.filled")
        } else {
            iv.image = UIImage(systemName: "star")
            iv.tintColor = .tertiaryLabel
        }
        iv.widthAnchor.constraint(equalToConstant: size).isActive = true
        iv.heightAnchor.constraint(equalToConstant: size).isActive = true
        stack.addArrangedSubview(iv)
    }
    return stack
}

private func reviewView(avatar: UIImage?, name: String, timeAgo: String, rating: Int, text: String) -> UIView {
    let container = UIStackView()
    container.axis = .vertical
    container.spacing = 6
    container.alignment = .leading

    let topRow = UIStackView()
    topRow.axis = .horizontal
    topRow.alignment = .center
    topRow.spacing = 8

    let avatarView = UIImageView(image: avatar)
    avatarView.contentMode = .scaleAspectFill
    avatarView.tintColor = .secondaryLabel
    avatarView.layer.cornerRadius = 16
    avatarView.clipsToBounds = true
    avatarView.widthAnchor.constraint(equalToConstant: 32).isActive = true
    avatarView.heightAnchor.constraint(equalToConstant: 32).isActive = true

    let nameLabel = UILabel()
    nameLabel.text = name
    nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)

    let timeLabel = UILabel()
    timeLabel.text = timeAgo
    timeLabel.font = .systemFont(ofSize: 12)
    timeLabel.textColor = .secondaryLabel

    let nameTime = UIStackView(arrangedSubviews: [nameLabel, timeLabel])
    nameTime.axis = .vertical
    nameTime.spacing = 2

    topRow.addArrangedSubview(avatarView)
    topRow.addArrangedSubview(nameTime)

    let stars = starStack(rating: Double(rating), max: 5, size: 14)

    let textLabel = UILabel()
    textLabel.numberOfLines = 0
    textLabel.font = .systemFont(ofSize: 13)
    textLabel.text = text

    container.addArrangedSubview(topRow)
    container.addArrangedSubview(stars)
    container.addArrangedSubview(textLabel)
    return container
}
