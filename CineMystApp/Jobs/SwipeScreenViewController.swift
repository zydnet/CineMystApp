import UIKit

class SwipeScreenViewController: UIViewController {

    private var cardData: [CandidateModel] = CandidateModel.sampleData
    private var cardViews: [CandidateCardView] = []
    private let maxCardsOnScreen = 3
    private var cardsLoaded = false

    // MARK: - NEW COUNTERS
    private var shortlistedCount = 0
    private var passedCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 44/255, green: 5/255, blue: 35/255, alpha: 1)

        setupNavigationBar()
        setupUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Restore tab bar only
        tabBarController?.tabBar.isHidden = false

        // Restore floating button if you hid it above:
        // if let tb = tabBarController as? CineMystTabBarController {
        //     tb.setFloatingButton(hidden: false)
        // }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !cardsLoaded {
            loadCards()
            cardsLoaded = true
        }
    }

    // MARK: Navigation Bar
    private func setupNavigationBar() {

        let titleLabel = UILabel()
        titleLabel.text = "Shortlist Candidates"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Lead Actor - Drama Series City of Dre"
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center

        navigationItem.titleView = stack

        let backBtn = UIButton(type: .system)
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .white
        backBtn.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)

        let listBtn = UIButton(type: .system)
        listBtn.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        listBtn.tintColor = .white
        listBtn.addTarget(self, action: #selector(openApplicationsScreen), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: listBtn)
    }

    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: UI Elements

    private let shortlistedContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        return v
    }()

    private let passedContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        return v
    }()

    private let shortlistedCountLabel = SwipeScreenViewController.makeCountLabel()
    private let passedCountLabel = SwipeScreenViewController.makeCountLabel()

    private static func makeCountLabel() -> UILabel {
        let lbl = UILabel()
        lbl.text = "0"
        lbl.textColor = .white
        lbl.font = .boldSystemFont(ofSize: 20)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    private let shortlistedTextLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Shortlisted"
        lbl.textColor = .white.withAlphaComponent(0.7)
        lbl.font = .systemFont(ofSize: 13)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let passedTextLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Passed"
        lbl.textColor = .white.withAlphaComponent(0.7)
        lbl.font = .systemFont(ofSize: 13)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let dislikeButton: UIButton = {
        let btn = SwipeScreenViewController.makeCircleButton(symbol: "xmark", tint: .white)
        return btn
    }()

    private let likeButton: UIButton = {
        let btn = SwipeScreenViewController.makeCircleButton(symbol: "heart.fill", tint: .systemPink)
        return btn
    }()

    private static func makeCircleButton(symbol: String, tint: UIColor) -> UIButton {

        let size: CGFloat = 70
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.setImage(UIImage(systemName: symbol), for: .normal)
        btn.tintColor = tint

        btn.backgroundColor = .clear
        btn.clipsToBounds = false
        btn.layer.cornerRadius = size / 2

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        blurView.layer.cornerRadius = size / 2
        blurView.clipsToBounds = true
        blurView.alpha = 0.22
        btn.insertSubview(blurView, at: 0)

        btn.layer.shadowColor = tint.withAlphaComponent(0.25).cgColor
        btn.layer.shadowOpacity = 0.25
        btn.layer.shadowRadius = 6
        btn.layer.shadowOffset = .zero

        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = tint.withAlphaComponent(0.35).cgColor

        return btn
    }

    // MARK: UI Setup
    private func setupUI() {
        
        view.addSubview(shortlistedContainer)
        view.addSubview(passedContainer)
        view.addSubview(dislikeButton)
        view.addSubview(likeButton)

        shortlistedContainer.addSubview(shortlistedCountLabel)
        shortlistedContainer.addSubview(shortlistedTextLabel)
        passedContainer.addSubview(passedCountLabel)
        passedContainer.addSubview(passedTextLabel)

        NSLayoutConstraint.activate([
            shortlistedContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45),
            shortlistedContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),

            shortlistedContainer.widthAnchor.constraint(equalToConstant: 150),
            shortlistedContainer.heightAnchor.constraint(equalToConstant: 38),

            shortlistedCountLabel.centerYAnchor.constraint(equalTo: shortlistedContainer.centerYAnchor),
            shortlistedCountLabel.leadingAnchor.constraint(equalTo: shortlistedContainer.leadingAnchor, constant: 12),

            shortlistedTextLabel.centerYAnchor.constraint(equalTo: shortlistedContainer.centerYAnchor),
            shortlistedTextLabel.leadingAnchor.constraint(equalTo: shortlistedCountLabel.trailingAnchor, constant: 6),

            passedContainer.leadingAnchor.constraint(equalTo: shortlistedContainer.trailingAnchor, constant: 15),
            passedContainer.topAnchor.constraint(equalTo: shortlistedContainer.topAnchor),
            passedContainer.widthAnchor.constraint(equalToConstant: 150),
            passedContainer.heightAnchor.constraint(equalToConstant: 38),

            passedCountLabel.centerYAnchor.constraint(equalTo: passedContainer.centerYAnchor),
            passedCountLabel.leadingAnchor.constraint(equalTo: passedContainer.leadingAnchor, constant: 12),

            passedTextLabel.centerYAnchor.constraint(equalTo: passedContainer.centerYAnchor),
            passedTextLabel.leadingAnchor.constraint(equalTo: passedCountLabel.trailingAnchor, constant: 6),

            dislikeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -70),
            dislikeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            dislikeButton.widthAnchor.constraint(equalToConstant: 70),
            dislikeButton.heightAnchor.constraint(equalToConstant: 70),

            likeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 70),
            likeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            likeButton.widthAnchor.constraint(equalToConstant: 70),
            likeButton.heightAnchor.constraint(equalToConstant: 70),
        ])

        dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
    }

    // MARK: Load Cards
    private func loadCards() {
        cardViews.removeAll()

        for (index, model) in cardData.prefix(maxCardsOnScreen).enumerated() {
            let card = CandidateCardView(model: model)
            let position = maxCardsOnScreen - 1 - index
            setupCardFrame(card, position: position)
            addPanGesture(to: card)
            view.addSubview(card)
            cardViews.append(card)
        }

        bringUIElementsToFront()
    }

    private func bringUIElementsToFront() {
        view.bringSubviewToFront(shortlistedContainer)
        view.bringSubviewToFront(passedContainer)
        view.bringSubviewToFront(dislikeButton)
        view.bringSubviewToFront(likeButton)
    }

    private func setupCardFrame(_ card: UIView, position: Int) {
        let inset: CGFloat = CGFloat(position) * 10
        let cardWidth: CGFloat = view.bounds.width - 90 - inset * 2
        let cardHeight: CGFloat = 470

        card.frame = CGRect(
            x: (view.bounds.width - cardWidth) / 2 + inset,
            y: 220 + inset,
            width: cardWidth,
            height: cardHeight
        )
    }

    private func addPanGesture(to card: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        card.addGestureRecognizer(pan)
    }

    // MARK: Swipe handling
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view else { return }

        let translation = gesture.translation(in: view)
        let percent = translation.x / view.bounds.width

        switch gesture.state {
        case .changed:
            card.center = CGPoint(
                x: view.center.x + translation.x,
                y: view.center.y + translation.y
            )
            card.transform = CGAffineTransform(rotationAngle: percent * 0.3)

        case .ended:
            if translation.x > 120 { animateSwipe(card, direction: 1) }
            else if translation.x < -120 { animateSwipe(card, direction: -1) }
            else { resetCard(card) }

        default: break
        }
    }

    // MARK: - UPDATED SWIPE LOGIC WITH COUNTERS
    private func animateSwipe(_ card: UIView, direction: CGFloat) {

        // 👉 UPDATE COUNTERS
        if direction > 0 {
            shortlistedCount += 1
            shortlistedCountLabel.text = "\(shortlistedCount)"
        } else {
            passedCount += 1
            passedCountLabel.text = "\(passedCount)"
        }

        UIView.animate(withDuration: 0.3, animations: {
            card.center.x += direction * 500
            card.alpha = 0
        }, completion: { _ in
            card.removeFromSuperview()
            self.pushNextCard()
        })
    }

    private func resetCard(_ card: UIView) {
        UIView.animate(withDuration: 0.25) {
            card.center = self.view.center
            card.transform = .identity
        }
    }

    private func pushNextCard() {
        if cardViews.isEmpty { return }

        cardViews.removeLast()
        cardData.removeFirst()

        for (i, card) in cardViews.enumerated() {
            let position = cardViews.count - 1 - i
            UIView.animate(withDuration: 0.2) { self.setupCardFrame(card, position: position) }
        }

        if cardViews.count < maxCardsOnScreen && cardViews.count < cardData.count {
            let model = cardData[cardViews.count]
            let newCard = CandidateCardView(model: model)

            setupCardFrame(newCard, position: 0)
            addPanGesture(to: newCard)

            view.insertSubview(newCard, at: 0)
            cardViews.insert(newCard, at: 0)
        }

        bringUIElementsToFront()
    }

    // MARK: Button Actions
    @objc private func handleDislike() {
        guard let top = cardViews.last else { return }
        animateSwipe(top, direction: -1)
    }

    @objc private func handleLike() {
        guard let top = cardViews.last else { return }
        animateSwipe(top, direction: 1)
    }

    @objc private func openApplicationsScreen() {
        let vc = ApplicationsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
