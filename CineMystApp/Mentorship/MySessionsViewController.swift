//
//  MySessionViewController.swift
//  CineMystApp
//
//  Updated: hide tab bar while displayed; canceled card matches Figma (red "Canceled", no services/note row).
//

import UIKit

// MARK: - Models
enum SessionStatus {
    case upcoming
    case completed
    case canceled
}

struct SessionModel {
    let mentorName: String
    let role: String
    let date: Date
    let imageName: String?
    let rating: Double
    let services: [String]
    let note: String?
    let status: SessionStatus
}


// MARK: - SessionCardView
final class SessionCardView: UIView {

    // callback for review button (controller will set)
    var onReviewTapped: (() -> Void)?

    private let shadowContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 12
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.backgroundColor = .clear
        return v
    }()

    private let contentContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 0.98, alpha: 1)
        v.layer.cornerRadius = 14
        v.layer.masksToBounds = true
        return v
    }()

    private let avatar: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let roleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(red: 0.36, green: 0.17, blue: 0.28, alpha: 1)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let starImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = UIColor(red: 0.09, green: 0.48, blue: 1, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let ratingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var rightStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 6
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let leftDivider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.85, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let rightDivider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.85, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let servicesLabel: UILabel = {
        let l = UILabel()
        l.text = "Services"
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tagsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // action button (review)
    let actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor(red: 0x43/255, green: 0x16/255, blue: 0x31/255, alpha: 1)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        b.layer.cornerRadius = 18
        b.clipsToBounds = true
        b.isHidden = true
        b.titleLabel?.numberOfLines = 1
        b.titleLabel?.lineBreakMode = .byClipping
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        b.setContentHuggingPriority(.required, for: .horizontal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        return b
    }()

    private let noteLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.lineBreakMode = .byTruncatingTail
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(shadowContainer)
        shadowContainer.addSubview(contentContainer)

        contentContainer.addSubview(avatar)
        contentContainer.addSubview(nameLabel)
        contentContainer.addSubview(roleLabel)
        contentContainer.addSubview(dateLabel)
        contentContainer.addSubview(rightStack)
        contentContainer.addSubview(statusLabel)
        contentContainer.addSubview(leftDivider)
        contentContainer.addSubview(rightDivider)
        contentContainer.addSubview(servicesLabel)
        contentContainer.addSubview(tagsStack)
        contentContainer.addSubview(actionButton)
        contentContainer.addSubview(noteLabel)

        NSLayoutConstraint.activate([
            // shadow container fills this view
            shadowContainer.topAnchor.constraint(equalTo: topAnchor),
            shadowContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            shadowContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            // content container
            contentContainer.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),

            // avatar top-right
            avatar.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 16),
            avatar.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            avatar.widthAnchor.constraint(equalToConstant: 76),
            avatar.heightAnchor.constraint(equalToConstant: 76),

            // Name / right stack (rating)
            nameLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 18),
            nameLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: rightStack.leadingAnchor, constant: -8),

            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.trailingAnchor.constraint(lessThanOrEqualTo: avatar.leadingAnchor, constant: -12),

            rightStack.trailingAnchor.constraint(equalTo: avatar.leadingAnchor, constant: -12),
            rightStack.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            starImageView.widthAnchor.constraint(equalToConstant: 14),
            starImageView.heightAnchor.constraint(equalToConstant: 14),

            // date/status row (below role)
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 8),

            statusLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8),
            statusLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),

            // divider: left segment ends at avatar leading - 12
            leftDivider.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 14),
            leftDivider.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 12),
            leftDivider.trailingAnchor.constraint(equalTo: avatar.leadingAnchor, constant: -12),
            leftDivider.heightAnchor.constraint(equalToConstant: 1),

            // right divider (kept to visually line up across avatar if needed)
            rightDivider.centerYAnchor.constraint(equalTo: leftDivider.centerYAnchor),
            rightDivider.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            rightDivider.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -12),
            rightDivider.heightAnchor.constraint(equalToConstant: 1),

            // services row sits below the divider
            servicesLabel.topAnchor.constraint(equalTo: leftDivider.bottomAnchor, constant: 12),
            servicesLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 12),

            tagsStack.centerYAnchor.constraint(equalTo: servicesLabel.centerYAnchor),
            tagsStack.leadingAnchor.constraint(equalTo: servicesLabel.trailingAnchor, constant: 12),
            tagsStack.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8),

            // action button: inline with Services (for completed)
            actionButton.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: servicesLabel.centerYAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 34),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 84),

            // note label below services (left side)
            noteLabel.topAnchor.constraint(equalTo: servicesLabel.bottomAnchor, constant: 12),
            noteLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 12),
            noteLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentContainer.trailingAnchor, constant: -16),
            noteLabel.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -14)
        ])

        contentContainer.bringSubviewToFront(avatar)
        actionButton.addTarget(self, action: #selector(handleReviewTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func handleReviewTapped() {
        onReviewTapped?()
    }

    // MARK: - configure
    func configure(with model: SessionModel) {
        nameLabel.text = model.mentorName
        roleLabel.text = model.role

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        dateLabel.text = df.string(from: model.date)

        ratingLabel.text = String(format: "%.1f", model.rating)

        switch model.status {
        case .upcoming:
            statusLabel.isHidden = true
            actionButton.isHidden = true
            leftDivider.isHidden = false
            rightDivider.isHidden = false
            servicesLabel.isHidden = false
            tagsStack.isHidden = false
            noteLabel.isHidden = model.note?.isEmpty ?? true
        case .completed:
            statusLabel.isHidden = false
            statusLabel.text = "Completed"
            statusLabel.textColor = UIColor.systemGreen
            actionButton.isHidden = false
            actionButton.setTitle("Give review", for: .normal)
            leftDivider.isHidden = false
            rightDivider.isHidden = false
            servicesLabel.isHidden = false
            tagsStack.isHidden = false
            noteLabel.isHidden = model.note?.isEmpty ?? true
        case .canceled:
            // canceled card — match Figma: show name/role/date + red "Canceled", hide services/note/review
            statusLabel.isHidden = false
            statusLabel.text = "Canceled"
            statusLabel.textColor = UIColor.systemRed
            actionButton.isHidden = true
            leftDivider.isHidden = true
            rightDivider.isHidden = true
            servicesLabel.isHidden = true
            tagsStack.isHidden = true
            noteLabel.isHidden = true
        }

        if let name = model.imageName, let img = UIImage(named: name) {
            avatar.image = img
            avatar.contentMode = .scaleAspectFill
        } else {
            let cfg = UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)
            avatar.image = UIImage(systemName: "person.crop.rectangle", withConfiguration: cfg)
            avatar.tintColor = .systemGray3
            avatar.contentMode = .center
        }

        // tags
        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for s in model.services {
            let l = PaddingLabel()
            l.text = s
            l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            l.textColor = UIColor(red: 0x43/255, green: 0x16/255, blue: 0x31/255, alpha: 1)
            l.layer.cornerRadius = 12
            l.layer.masksToBounds = true
            l.translatesAutoresizingMaskIntoConstraints = false
            l.topInset = 6
            l.bottomInset = 6
            l.leftInset = 10
            l.rightInset = 10
            tagsStack.addArrangedSubview(l)
        }

        if let n = model.note, !n.isEmpty {
            noteLabel.text = "Note  \(n)"
        } else {
            noteLabel.text = ""
        }

        contentContainer.bringSubviewToFront(avatar)
    }
}

// simple padded label
final class PaddingLabel: UILabel {
    var topInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    var leftInset: CGFloat = 0
    var rightInset: CGFloat = 0

    override func drawText(in rect: CGRect) {
        let inset = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: inset))
    }

    override var intrinsicContentSize: CGSize {
        let sz = super.intrinsicContentSize
        return CGSize(width: sz.width + leftInset + rightInset, height: sz.height + topInset + bottomInset)
    }
}


// MARK: - MySessionViewController
final class MySessionViewController: UIViewController {

    // theme
    private let plum = UIColor(red: 0x43/255, green: 0x16/255, blue: 0x31/255, alpha: 1)

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "My Sessions"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Track your upcoming sessions"
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var sessionSegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Upcoming", "Past", "Canceled"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentTintColor = .white
        sc.backgroundColor = UIColor.systemGray5
        sc.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .normal)
        sc.layer.cornerRadius = 18
        sc.layer.masksToBounds = true
        return sc
    }()

    private let sessionsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 18
        s.alignment = .fill
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Data
    private var upcomingSessions: [SessionModel] = []
    private var pastSessions: [SessionModel] = []
    private var canceledSessions: [SessionModel] = []

    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        titleLabel.textColor = plum

        setupViews()
        setupConstraints()
        setupData()

        sessionSegment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }

    // HIDE tab bar while this controller is visible
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    // RESTORE tab bar when leaving
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: setup
    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(sessionSegment)
        contentView.addSubview(sessionsStack)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            sessionSegment.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            sessionSegment.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            sessionSegment.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -40),
            sessionSegment.heightAnchor.constraint(equalToConstant: 40),

            sessionsStack.topAnchor.constraint(equalTo: sessionSegment.bottomAnchor, constant: 18),
            sessionsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sessionsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sessionsStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setupData() {
        let cal = Calendar.current
        let now = Date()
        let d1 = cal.date(byAdding: .day, value: 3, to: now) ?? now
        let d2 = cal.date(byAdding: .day, value: 7, to: now) ?? now
        let dPast = cal.date(byAdding: .day, value: -5, to: now) ?? now

        upcomingSessions = [
            SessionModel(mentorName: "Sanya Sawi", role: "Senior Director", date: d1, imageName: "Image", rating: 4.9, services: ["Acting", "Dubbing"], note: "Meet link shared on your mail id", status: .upcoming),
            SessionModel(mentorName: "Swati Jha", role: "Senior Actor", date: d2, imageName: "Image", rating: 4.9, services: ["Acting", "Dubbing"], note: "Meet link shared on your mail id", status: .upcoming)
        ]

        pastSessions = [
            SessionModel(mentorName: "Amit Sawi", role: "Actor", date: dPast, imageName: "Image", rating: 4.9, services: ["Acting", "Dubbing"], note: nil, status: .completed)
        ]

        canceledSessions = [
            SessionModel(mentorName: "Amit Sawi", role: "Actor", date: d1, imageName: "Image", rating: 4.9, services: [], note: nil, status: .canceled)
        ]

        buildSessionsUI(for: .upcoming)
    }

    // Builds session cards for the chosen status
    private func buildSessionsUI(for status: SessionStatus) {
        switch status {
        case .upcoming: subtitleLabel.text = "Track your upcoming sessions"
        case .completed: subtitleLabel.text = "Track your past sessions"
        case .canceled:  subtitleLabel.text = "Track your canceled sessions"
        }

        sessionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let source: [SessionModel]
        switch status {
        case .upcoming: source = upcomingSessions
        case .completed: source = pastSessions
        case .canceled:  source = canceledSessions
        }

        if source.isEmpty {
            let l = UILabel()
            l.text = "No sessions"
            l.font = .systemFont(ofSize: 14)
            l.textColor = .secondaryLabel
            l.translatesAutoresizingMaskIntoConstraints = false
            sessionsStack.addArrangedSubview(l)
            return
        }

        for s in source {
            let card = SessionCardView()
            card.configure(with: s)

            // if user taps Give review -> open ReviewViewController
            card.onReviewTapped = { [weak self] in
                guard let self = self else { return }
                let reviewVC = ReviewViewController(mentorName: s.mentorName)
                self.navigationController?.pushViewController(reviewVC, animated: true)
            }

            sessionsStack.addArrangedSubview(card)
            card.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                // min height (lets card expand if note exists)
                card.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
                card.leadingAnchor.constraint(equalTo: sessionsStack.leadingAnchor),
                card.trailingAnchor.constraint(equalTo: sessionsStack.trailingAnchor)
            ])
        }

        sessionsStack.setNeedsLayout()
        sessionsStack.layoutIfNeeded()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    // MARK: - Actions
    @objc private func segmentChanged(_ s: UISegmentedControl) {
        switch s.selectedSegmentIndex {
        case 0: buildSessionsUI(for: .upcoming)
        case 1: buildSessionsUI(for: .completed)
        case 2: buildSessionsUI(for: .canceled)
        default: break
        }
        scrollView.setContentOffset(.zero, animated: true)
    }
}
