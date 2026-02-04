//
//  AllCallsPanelViewController.swift
//  ProgrammaticMentorship
//
//  Created by You on 2025-11-17.
//  Shows "All calls" with segmented filter: Upcoming | Past | Canceled
//

import UIKit

// MARK: - Model (unique name: CallItem)
struct CallItem {
    let id: String
    let mentorName: String
    let mentorRole: String
    let date: Date
    let services: [String]
    let avatarName: String? // asset name
    let status: CallItemStatus

    enum CallItemStatus: Equatable {
        case upcoming
        case ended
        case canceled

        var text: String {
            switch self {
            case .upcoming: return "Upcoming"
            case .ended: return "Ended"
            case .canceled: return "Canceled"
            }
        }

        var color: UIColor {
            switch self {
            case .upcoming: return UIColor.systemGreen
            case .ended: return UIColor.systemRed
            case .canceled: return UIColor.systemOrange
            }
        }
    }
}

// MARK: - CallItemCell (unique)
final class CallItemCell: UITableViewCell {
    static let reuseIdentifier = "CallItemCell"

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.systemGray6
        v.layer.cornerRadius = 18
        v.layer.masksToBounds = true
        return v
    }()

    private let avatarView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 32 // half of width/height (64)
        iv.layer.masksToBounds = true
        iv.widthAnchor.constraint(equalToConstant: 64).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 64).isActive = true
        iv.backgroundColor = UIColor.systemGray5
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.numberOfLines = 1
        return l
    }()

    private let roleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        return l
    }()

    private let dateIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "calendar"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 14).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 14).isActive = true
        iv.tintColor = .secondaryLabel
        return iv
    }()

    private let timeIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "clock"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 12).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 12).isActive = true
        iv.tintColor = .secondaryLabel
        return iv
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        return l
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        return l
    }()

    private let servicesLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        return l
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l.textAlignment = .right
        return l
    }()

    // Stacks
    private lazy var titleStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        s.axis = .vertical
        s.spacing = 4
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private lazy var dateRow: UIStackView = {
        let left = UIStackView(arrangedSubviews: [dateIcon, dateLabel])
        left.axis = .horizontal
        left.spacing = 6
        left.alignment = .center
        left.translatesAutoresizingMaskIntoConstraints = false

        let right = UIStackView(arrangedSubviews: [timeIcon, timeLabel])
        right.axis = .horizontal
        right.spacing = 6
        right.alignment = .center
        right.translatesAutoresizingMaskIntoConstraints = false

        let s = UIStackView(arrangedSubviews: [left, right])
        s.axis = .horizontal
        s.spacing = 12
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private lazy var leftColumn: UIStackView = {
        let s = UIStackView(arrangedSubviews: [titleStack, dateRow, servicesLabel])
        s.axis = .vertical
        s.spacing = 8
        s.alignment = .leading
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        contentView.addSubview(cardView)
        cardView.addSubview(avatarView)
        cardView.addSubview(leftColumn)
        cardView.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            // card
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            // avatar
            avatarView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            avatarView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            // left column (to right of avatar)
            leftColumn.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            leftColumn.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            leftColumn.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16),
            leftColumn.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -12),

            // status label (right)
            statusLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            statusLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 66)
        ])
    }

    func configure(with call: CallItem) {
        nameLabel.text = call.mentorName
        roleLabel.text = call.mentorRole

        // date formatting to "19 Nov 2025" and time as short
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy"
        let datePart = df.string(from: call.date)

        let tf = DateFormatter()
        tf.timeStyle = .short
        let timePart = tf.string(from: call.date)

        dateLabel.text = datePart
        timeLabel.text = timePart

        // Services string: "Services  Acting , Voice Over" with services semibold
        let servicesPrefix = "Services  "
        let servicesText = call.services.joined(separator: " , ")
        let full = servicesPrefix + servicesText
        let attr = NSMutableAttributedString(string: full)
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: servicesPrefix.count))
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: NSRange(location: servicesPrefix.count, length: servicesText.count))
        servicesLabel.attributedText = attr

        // status
        statusLabel.text = call.status.text
        statusLabel.textColor = call.status.color

        // avatar
        if let name = call.avatarName, let img = UIImage(named: name) {
            avatarView.image = img
            avatarView.contentMode = .scaleAspectFill
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
            avatarView.image = UIImage(systemName: "person.crop.circle", withConfiguration: config)
            avatarView.tintColor = UIColor.systemGray3
            avatarView.contentMode = .center
            avatarView.backgroundColor = UIColor.systemGray5
        }
    }
}

// MARK: - AllCallsPanelViewController (unique)
final class AllCallsPanelViewController: UIViewController {

    // MARK: UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "All calls"
        l.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Track all your calls"
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Upcoming", "Past", "Canceled"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false

        // pill styling
        sc.selectedSegmentTintColor = .white
        sc.backgroundColor = UIColor.systemGray5
        sc.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .normal)
        sc.layer.cornerRadius = 20
        sc.layer.masksToBounds = true

        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(CallItemCell.self, forCellReuseIdentifier: CallItemCell.reuseIdentifier)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.tableFooterView = UIView()

        // dynamic height for cells (fixes clipping)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 140

        return tv
    }()

    // MARK: Data
    private var allCalls: [CallItem] = []
    private var displayedCalls: [CallItem] = []

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Keep this too — safe if this VC is pushed from elsewhere
        self.hidesBottomBarWhenPushed = true

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonDisplayMode = .default

        setupHierarchy()
        setupConstraints()

        tableView.dataSource = self
        tableView.delegate = self

        loadSampleData()
        applyFilterForSelectedSegment()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Hide the tab bar while this screen is visible
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Restore the tab bar only when this VC is being removed from its parent (popped/dismissed).
        // Do not restore if only pushing another controller (pushed VCs typically set hidesBottomBarWhenPushed = true).
        if isMovingFromParent || isBeingDismissed {
            tabBarController?.tabBar.isHidden = false
        }
    }

    private func setupHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        let pad: CGFloat = 20

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            segmentedControl.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),
            segmentedControl.widthAnchor.constraint(equalToConstant: 320),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 18),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Data Loading
    private func loadSampleData() {
        let cal = Calendar.current
        allCalls = [
            CallItem(id: "1",
                     mentorName: "Amit Sawi",
                     mentorRole: "Junior Artist",
                     date: cal.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                     services: ["Acting", "Voice Over"],
                     avatarName: "Image",     // ← USE YOUR ASSET NAMED "Image"
                     status: .upcoming),
            CallItem(id: "2",
                     mentorName: "Amit Sawi",
                     mentorRole: "Junior Artist",
                     date: cal.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                     services: ["Acting", "Voice Over"],
                     avatarName: "Image",     // ← USE YOUR ASSET NAMED "Image"
                     status: .ended),
            CallItem(id: "3",
                     mentorName: "Amit Sawi",
                     mentorRole: "Junior Artist",
                     date: cal.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                     services: ["Acting"],
                     avatarName: "Image",     // ← USE YOUR ASSET NAMED "Image"
                     status: .canceled),
            CallItem(id: "4",
                     mentorName: "Amit Sawi",
                     mentorRole: "Junior Artist",
                     date: cal.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                     services: ["Voice Over"],
                     avatarName: "Image",     // ← USE YOUR ASSET NAMED "Image"
                     status: .ended)
        ]
    }

    // MARK: - Segment handling
    @objc private func segmentChanged(_ s: UISegmentedControl) {
        applyFilterForSelectedSegment()
        animateTableTransition()
    }

    private func applyFilterForSelectedSegment() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            displayedCalls = allCalls.filter { $0.status == .upcoming }
        case 1:
            displayedCalls = allCalls.filter { $0.status == .ended }
        case 2:
            displayedCalls = allCalls.filter { $0.status == .canceled }
        default:
            displayedCalls = allCalls
        }
        tableView.reloadData()
    }

    private func animateTableTransition() {
        tableView.alpha = 0
        UIView.animate(withDuration: 0.18) {
            self.tableView.alpha = 1
        }
    }
}

// MARK: - UITableViewDataSource / Delegate
extension AllCallsPanelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedCalls.count
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tv.dequeueReusableCell(withIdentifier: CallItemCell.reuseIdentifier, for: indexPath) as? CallItemCell else {
            return UITableViewCell()
        }
        let call = displayedCalls[indexPath.row]
        cell.configure(with: call)
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        let call = displayedCalls[indexPath.row]
        let vc = CallItemDetailViewController()
        vc.call = call
        // ensure pushed detail also hides bottom bar
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    // removed fixed height methods so automaticDimension can size the rows correctly
}

// MARK: - CallItemDetailViewController (unique)
final class CallItemDetailViewController: UIViewController {
    var call: CallItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // keep this here as well (harmless if already handled)
        self.hidesBottomBarWhenPushed = true

        view.backgroundColor = .systemBackground
        title = "Call"

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        if let c = call {
            label.text = "\(c.mentorName)\n\(c.mentorRole)\n\(c.status.text)"
        } else {
            label.text = "Call details"
        }
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
