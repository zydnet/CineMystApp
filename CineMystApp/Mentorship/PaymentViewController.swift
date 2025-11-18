//
//  PaymentViewController.swift
//  CineMystApp
//
//  Created by You on Today.
//  Updated: hide tab bar & floating button while payment screen is visible.
//           present confirmation VC and navigate back to MentorshipHomeViewController properly.
//

import UIKit

final class PaymentViewController: UIViewController {

    // MARK: Theme
    private let plum = UIColor(red: 0x43/255.0, green: 0x16/255.0, blue: 0x31/255.0, alpha: 1.0)
    private let accentGray = UIColor(white: 0.4, alpha: 1.0)

    // MARK: Data passed from Schedule screen
    private let selectedArea: String?
    private let selectedDate: Date?
    private let selectedTime: String?

    /// NEW: accept mentor (set this before pushing/presenting PaymentViewController)
    var mentor: Mentor?

    init(area: String? = nil, date: Date? = nil, time: String? = nil) {
        self.selectedArea = area
        self.selectedDate = date
        self.selectedTime = time
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.selectedArea = nil
        self.selectedDate = nil
        self.selectedTime = nil
        super.init(coder: coder)
    }

    // MARK: UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Payment"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        return l
    }()

    private let segment: UISegmentedControl = {
        let s = UISegmentedControl(items: ["Card", "UPI"])
        s.selectedSegmentIndex = 0
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // --- Card Section ---
    private let cardView = UIView()
    private let cardHolder = UILabel()
    private let cardNumber = UILabel()
    private let cardExpiry = UILabel()
    private let cardCVV = UILabel()

    private let editButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Edit card info", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13)
        return b
    }()
    private let addAnotherButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("+ Add another card", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13)
        return b
    }()
    private lazy var cardActionsRow: UIStackView = {
        let row = UIStackView(arrangedSubviews: [editButton, UIView(), addAnotherButton])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }()

    // --- Total + Pay Button ---
    private let totalTitle: UILabel = {
        let l = UILabel()
        l.text = "Total"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        return l
    }()
    private let amountLabel: UILabel = {
        let l = UILabel()
        l.text = "₹155"
        l.font = .systemFont(ofSize: 32, weight: .bold)
        return l
    }()
    private let payButton: UIButton = {
        var c = UIButton.Configuration.filled()
        c.title = "Pay"
        c.cornerStyle = .capsule
        c.baseForegroundColor = .white
        c.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
        let b = UIButton(configuration: c)
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = ""
        navigationItem.backButtonDisplayMode = .minimal
        view.tintColor = accentGray

        setupLayout()
        setupCard()
        wireActions()

        payButton.configuration?.baseBackgroundColor = plum
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide tab bar only
        tabBarController?.tabBar.isHidden = true
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Restore tab bar only
        tabBarController?.tabBar.isHidden = false
    }


    // MARK: Actions
    private func wireActions() {
        segment.addTarget(self, action: #selector(segChanged), for: .valueChanged)
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
    }

    @objc private func segChanged() {
        // If you later add a UPI view, toggle here.
        // For now we keep Card visible.
    }

    @objc private func payTapped() {
        // create & present the confirmation screen instead of using alert
        let confirmationVC = PaymentConfirmationViewController()
        confirmationVC.mentor = self.mentor
        confirmationVC.scheduledDate = self.selectedDate

        // optional: set onDone if you still want additional behavior
        confirmationVC.onDone = { [weak self] in
            print("[PaymentViewController] confirmation done callback")
        }

        present(confirmationVC, animated: true, completion: nil)
    }

    // MARK: - Layout
    private func setupLayout() {
        // bottom Pay button
        view.addSubview(payButton)
        NSLayoutConstraint.activate([
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            payButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        // scroll content
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -12)
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

        // Segmented control container
        let segContainer = UIView()
        segContainer.backgroundColor = UIColor.secondarySystemBackground
        segContainer.layer.cornerRadius = 12
        segContainer.translatesAutoresizingMaskIntoConstraints = false
        segContainer.addSubview(segment)
        segment.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segment.topAnchor.constraint(equalTo: segContainer.topAnchor, constant: 6),
            segment.leadingAnchor.constraint(equalTo: segContainer.leadingAnchor, constant: 6),
            segment.trailingAnchor.constraint(equalTo: segContainer.trailingAnchor, constant: -6),
            segment.bottomAnchor.constraint(equalTo: segContainer.bottomAnchor, constant: -6)
        ])

        // Card box
        cardView.backgroundColor = plum
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowRadius = 6
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 180)
        ])

        // Totals
        let totalStack = UIStackView(arrangedSubviews: [totalTitle, amountLabel])
        totalStack.axis = .vertical
        totalStack.spacing = 4
        totalStack.alignment = .center

        // Main vertical layout (no step header now)
        let actionsRow = cardActionsRow
        let main = UIStackView(arrangedSubviews: [
            titleLabel,
            UIView(height: 16),
            segContainer,
            UIView(height: 16),
            cardView,
            UIView(height: 8),
            actionsRow,
            UIView(height: 24),
            totalStack
        ])
        main.axis = .vertical
        main.spacing = 10

        contentView.addSubview(main)
        main.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            main.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            main.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            main.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            main.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setupCard() {
        [cardHolder, cardNumber, cardExpiry, cardCVV].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .white
        }
        cardHolder.font = .systemFont(ofSize: 12, weight: .semibold)
        cardHolder.text = "CARD HOLDER\nANSH GAUTAM"
        cardHolder.numberOfLines = 0

        cardNumber.font = .monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
        cardNumber.text = "3096 4347 8180"

        cardExpiry.font = .systemFont(ofSize: 12, weight: .semibold)
        cardExpiry.text = "Expires\n02/27"
        cardExpiry.numberOfLines = 0

        cardCVV.font = .systemFont(ofSize: 12, weight: .semibold)
        cardCVV.text = "CVV\n••••"
        cardCVV.numberOfLines = 0

        // Fake brand dots
        let dot1 = UIView(); dot1.backgroundColor = .systemOrange; dot1.layer.cornerRadius = 8
        let dot2 = UIView(); dot2.backgroundColor = .systemRed;    dot2.layer.cornerRadius = 8
        [dot1, dot2].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 16).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 16).isActive = true
        }
        let dots = UIStackView(arrangedSubviews: [dot1, dot2])
        dots.axis = .horizontal; dots.spacing = -6
        dots.translatesAutoresizingMaskIntoConstraints = false

        [cardHolder, cardNumber, cardExpiry, cardCVV, dots].forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardHolder.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            cardHolder.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            cardNumber.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardNumber.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            cardExpiry.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardExpiry.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            cardCVV.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardCVV.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            dots.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            dots.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16)
        ])
    }
}

// Small spacer helper
private extension UIView {
    convenience init(height: CGFloat) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
