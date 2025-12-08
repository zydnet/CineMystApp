import UIKit

class JobDetailsViewController: UIViewController {
    
    // UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Details"
        lbl.font = UIFont.boldSystemFont(ofSize: 28)
        lbl.textColor = UIColor(red: 67/255, green: 0/255, blue: 34/255, alpha: 1)
        return lbl
    }()
    
    private let applyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Apply Now", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.backgroundColor = UIColor(red: 67/255, green: 0/255, blue: 34/255, alpha: 1)
        btn.addTarget(nil, action: #selector(applyTapped), for: .touchUpInside)
        return btn
   }()
    @objc private func applyTapped() {
        let vc = ApplicationStartedViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupScrollView()
        setupLayout()
        buildContentCards()
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // Hide tab bar only
            tabBarController?.tabBar.isHidden = true

            // If you also have a floating button on your custom TabBarController,
            // you'll need to hide/show it here as well. Example:
            // (Assuming your tabBar controller has a `floatingButton` property)
            //
            // if let tb = tabBarController as? CineMystTabBarController {
            //     tb.setFloatingButton(hidden: true)
            // }
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

}

extension JobDetailsViewController {
    
    // ScrollView Setup
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    // Main Layout
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(applyButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            applyButton.topAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -100)
        ])
    }
    
    // Build the Cards Section
    private func buildContentCards() {
        
        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.spacing = 28
        
        contentView.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            cardStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardStack.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -40)
        ])
        
        // Create cards exactly matching your UI
        cardStack.addArrangedSubview(makeCard(
            title: "Lead Role in Indie Film",
            body: """
Seeking a versatile actor for the lead role in an upcoming independent film. The project explores themes of identity and belonging, set against the backdrop of a bustling city. The role requires a nuanced performance, capable of conveying a wide range of emotions.
"""
        ))
        
        cardStack.addArrangedSubview(makeRequirementsCard())
        
        cardStack.addArrangedSubview(makeCard(
            title: "Compensation",
            body: "Paid role; compensation details will be discussed upon application."
        ))
        
        cardStack.addArrangedSubview(makeCard(
            title: "Deadline",
            body: "Applications must be received by July 15, 2024."
        ))
        
        // Bottom apply button constraints
        NSLayoutConstraint.activate([
            applyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            applyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            applyButton.heightAnchor.constraint(equalToConstant: 54),
            applyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // Card Builder
    private func makeCard(title: String, body: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 5
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.numberOfLines = 0
        bodyLabel.font = UIFont.systemFont(ofSize: 15)
        bodyLabel.textColor = .darkGray
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 8
        
        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        
        return card
    }
    
    // Requirements Card (Custom Layout)
    private func makeRequirementsCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 5
        
        let title = UILabel()
        title.text = "Requirements"
        title.font = UIFont.boldSystemFont(ofSize: 18)
        
        let skillsTitle = makeSmallSectionTitle("SKILLS")
        
        let skill1 = makeTag("Acting")
        let skill2 = makeTag("Dancing")
        
        let skillsRow = UIStackView(arrangedSubviews: [skill1, skill2])
        skillsRow.axis = .horizontal
        skillsRow.spacing = 8
        skillsRow.alignment = .leading          // prevents stretching vertically
        skillsRow.distribution = .fillEqually // prevents full-width stretching
        
        let expTitle = makeSmallSectionTitle("EXPERIENCE")
        
        let expBody = UILabel()
        expBody.text = "3+ years in film or theatre\nOpen to all types"
        expBody.numberOfLines = 0
        expBody.font = UIFont.systemFont(ofSize: 15)
        expBody.textColor = .darkGray
        
        let stack = UIStackView(arrangedSubviews: [title, skillsTitle, skillsRow, expTitle, expBody])
        stack.axis = .vertical
        stack.spacing = 10
        
        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        
        return card
    }
    
    // Helpers
    private func makeSmallSectionTitle(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.boldSystemFont(ofSize: 13)
        lbl.textColor = UIColor(red: 67/255, green: 0/255, blue: 34/255, alpha: 1)
        return lbl
    }
    
    private func makeTag(_ text: String) -> UIView {
            let container = UIView()
            
            let lbl = UILabel()
            lbl.text = "  \(text)  "
            lbl.font = UIFont.systemFont(ofSize: 14)
            lbl.textColor = .darkGray
            lbl.textAlignment = .center
            lbl.backgroundColor = UIColor(white: 0.93, alpha: 1)
            lbl.layer.cornerRadius = 12
            lbl.clipsToBounds = true
            
            container.addSubview(lbl)
            lbl.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                lbl.topAnchor.constraint(equalTo: container.topAnchor),
                lbl.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                lbl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                lbl.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                lbl.heightAnchor.constraint(equalToConstant: 30)
            ])
            
            return container
        }
}
