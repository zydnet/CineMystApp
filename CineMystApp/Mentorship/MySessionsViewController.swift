import UIKit

class SessionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Models
    enum SessionStatus {
        case upcoming, past, canceled
    }

    struct Session {
        let name: String
        let title: String
        let date: String
        let time: String
        let services: [String]
        let note: String
        let rating: Double
        let status: SessionStatus
        let image: UIImage?
    }

    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Sessions"
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Upcoming", "Past", "Canceled"])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.systemGroupedBackground
        tv.separatorStyle = .none
        return tv
    }()

    // MARK: - Data
    private var allSessions: [Session] = []
    private var filteredSessions: [Session] = []
    private var currentStatus: SessionStatus = .upcoming

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        setupLayout()
        setupTable()
        loadData()
        filterSessions()
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(segmentControl)
        view.addSubview(tableView)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),

            segmentControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            segmentControl.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }

    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SessionCell.self, forCellReuseIdentifier: "SessionCell")
    }

    private func loadData() {
        allSessions = [
            Session(name: "Sanya Sawi", title: "Senior Director", date: "May 15 2025", time: "3:00 PM", services: ["Acting", "Dubbing"], note: "Meet link shared on your mail id", rating: 4.9, status: .upcoming, image: UIImage(named: "Image")),
            Session(name: "Swati Jha", title: "Senior Actor", date: "May 17 2025", time: "3:00 PM", services: ["Acting", "Dubbing"], note: "Meet link shared on your mail id", rating: 4.9, status: .upcoming, image: UIImage(named: "Image")),
            Session(name: "Amit Sawi", title: "Actor", date: "May 15 2025", time: "3:00 PM", services: ["Acting", "Dubbing"], note: "Completed", rating: 4.9, status: .past, image: UIImage(named: "Image")),
            Session(name: "Amit Sawi", title: "Actor", date: "May 15 2025", time: "3:00 PM", services: ["Acting", "Dubbing"], note: "Canceled", rating: 4.9, status: .canceled, image: UIImage(named: "Image"))
        ]
    }

    private func filterSessions() {
        filteredSessions = allSessions.filter { $0.status == currentStatus }
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc private func segmentChanged() {
        switch segmentControl.selectedSegmentIndex {
        case 0: currentStatus = .upcoming
        case 1: currentStatus = .past
        case 2: currentStatus = .canceled
        default: break
        }
        filterSessions()
    }

    // MARK: - Table DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSessions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let session = filteredSessions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath) as! SessionCell
        cell.configure(with: session)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

// MARK: - Custom Table Cell (inside same file)
class SessionCell: UITableViewCell {

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel = UILabel()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let servicesLabel = UILabel()
    private let noteLabel = UILabel()
    private let ratingLabel = UILabel()
    private let profileImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        contentView.addSubview(cardView)

        [nameLabel, titleLabel, dateLabel, servicesLabel, noteLabel, ratingLabel, profileImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }

        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .gray
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textColor = .darkGray
        servicesLabel.font = UIFont.systemFont(ofSize: 13)
        noteLabel.font = UIFont.systemFont(ofSize: 13)
        noteLabel.textColor = .systemGray
        ratingLabel.font = UIFont.systemFont(ofSize: 13)
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            profileImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            profileImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),

            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: profileImageView.leadingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            ratingLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            dateLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            servicesLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 6),
            servicesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            noteLabel.topAnchor.constraint(equalTo: servicesLabel.bottomAnchor, constant: 6),
            noteLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            noteLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with session: SessionsViewController.Session) {
        nameLabel.text = session.name
        titleLabel.text = session.title
        ratingLabel.text = "⭐️ \(session.rating)"
        dateLabel.text = "\(session.date)  \(session.time)"
        servicesLabel.text = "Services: " + session.services.joined(separator: ", ")
        noteLabel.text = session.note
        profileImageView.image = session.image

        switch session.status {
        case .upcoming:
            noteLabel.textColor = .systemGray
        case .past:
            noteLabel.text = "Completed"
            noteLabel.textColor = .systemGreen
        case .canceled:
            noteLabel.text = "Canceled"
            noteLabel.textColor = .systemRed
        }
    }
}
