//
// PaymentConfirmationViewController.swift
// Creates a Session on Done. Uses mentor.imageName when available (falls back to demo "Image").
//

import UIKit

final class PaymentConfirmationViewController: UIViewController {

    // optional callback
    var onDone: (() -> Void)?

    // data passed by caller (may be nil)
    var mentor: Mentor?
    var scheduledDate: Date?

    // demo mentors if real mentor missing
    private let demoMentors: [Mentor] = [
        Mentor(name: "Nathan Hales", role: "Actor", rating: 4.8, imageName: "Image"),
        Mentor(name: "Ava Johnson", role: "Casting Director", rating: 4.9, imageName: "Image"),
        Mentor(name: "Maya Patel", role: "Actor", rating: 5.0, imageName: "Image"),
        Mentor(name: "Riya Sharma", role: "Actor", rating: 4.9, imageName: "Image")
    ]

    // UI
    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0, alpha: 0.45)
        v.alpha = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let checkBox: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.94, green: 0.9, blue: 0.98, alpha: 1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let checkImage: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tintColor = UIColor(red: 0.4, green: 0.15, blue: 0.31, alpha: 1)
        iv.contentMode = .center
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Your payment has been done!"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "We've sent you a confirmation mail."
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let doneButton: UIButton = {
        var c = UIButton.Configuration.filled()
        c.cornerStyle = .capsule
        c.title = "Done"
        c.baseBackgroundColor = UIColor(red: 0x43/255.0, green: 0x16/255.0, blue: 0x31/255.0, alpha: 1)
        c.baseForegroundColor = .white
        let b = UIButton(configuration: c)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        view.backgroundColor = .clear
        setupViews()
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimTapped(_:)))
        dimView.addGestureRecognizer(tap)

        print("[PaymentConfirmation] presented mentor=\(String(describing: mentor?.name)) scheduledDate=\(String(describing: scheduledDate))")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateIn()
    }

    private func setupViews() {
        view.addSubview(dimView)
        view.addSubview(cardView)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.widthAnchor.constraint(lessThanOrEqualToConstant: 320),
            cardView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])

        cardView.addSubview(checkBox)
        checkBox.addSubview(checkImage)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(doneButton)

        NSLayoutConstraint.activate([
            checkBox.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            checkBox.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            checkBox.widthAnchor.constraint(equalToConstant: 48),
            checkBox.heightAnchor.constraint(equalToConstant: 48),

            checkImage.centerXAnchor.constraint(equalTo: checkBox.centerXAnchor),
            checkImage.centerYAnchor.constraint(equalTo: checkBox.centerYAnchor),
            checkImage.widthAnchor.constraint(equalToConstant: 18),
            checkImage.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.topAnchor.constraint(equalTo: checkBox.bottomAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            doneButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 18),
            doneButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 48),
            doneButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -48),
            doneButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }

    private func animateIn() {
        cardView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92).concatenating(CGAffineTransform(translationX: 0, y: 20))
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) { self.dimView.alpha = 1.0 }
        UIView.animate(withDuration: 0.32, delay: 0.06, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.8, options: []) {
            self.cardView.transform = .identity
        }
    }

    private func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.18, animations: {
            self.cardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96).concatenating(CGAffineTransform(translationX: 0, y: 8))
            self.dimView.alpha = 0
            self.cardView.alpha = 0
        }) { _ in completion?() }
    }

    // MARK: Actions
    @objc private func didTapDone() {
        // choose mentor (provided or demo)
        let usedMentor: Mentor
        if let m = mentor { usedMentor = m; print("[PaymentConfirmation] using provided mentor: \(m.name)") }
        else {
            usedMentor = demoMentors.randomElement()!
            print("[PaymentConfirmation] mentor nil — using demo: \(usedMentor.name)")
        }

        // choose date (provided or now)
        let usedDate = scheduledDate ?? Date()
        if scheduledDate == nil { print("[PaymentConfirmation] scheduledDate nil — using now: \(usedDate)") }

        // create session including mentor image name (fallback to "Image")
        let session = SessionM(
            id: UUID().uuidString,
            mentorId: usedMentor.name,
            mentorName: usedMentor.name,
            mentorRole: usedMentor.role,
            date: usedDate,
            createdAt: Date(),
            mentorImageName: usedMentor.imageName ?? "Image"
        )

        SessionStore.shared.add(session)
        print("[PaymentConfirmation] created session id=\(session.id) mentor=\(session.mentorName)")

        // Replace Mentorship tab to show post-booking screen
        replaceMentorshipTabWithPostBookingScreen()

        animateOut {
            self.dismiss(animated: false) {
                self.onDone?()
            }
        }
    }

    @objc private func dimTapped(_ g: UITapGestureRecognizer) { didTapDone() }

    // Helper that replaces the Mentorship tab root and selects it, preserving its tabBarItem
    private func replaceMentorshipTabWithPostBookingScreen() {
        let postBookingVC = PostBookingMentorshipViewController()
        let newNav = UINavigationController(rootViewController: postBookingVC)

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let tabBar = window.rootViewController as? UITabBarController,
              let tabs = tabBar.viewControllers else {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: postBookingVC)
                nav.modalPresentationStyle = .fullScreen
                UIApplication.shared.windows.first?.rootViewController?.present(nav, animated: true, completion: nil)
            }
            return
        }

        var newTabs = tabs
        var replaced = false

        for (index, child) in tabs.enumerated() {
            if let nav = child as? UINavigationController, let root = nav.viewControllers.first {
                if root is MentorshipHomeViewController || String(describing: type(of: root)).lowercased().contains("mentorship") {
                    newNav.tabBarItem = nav.tabBarItem
                    newTabs[index] = newNav
                    tabBar.setViewControllers(newTabs, animated: false)
                    tabBar.selectedIndex = index
                    replaced = true
                    break
                }
            } else {
                if child is MentorshipHomeViewController || String(describing: type(of: child)).lowercased().contains("mentorship") {
                    newNav.tabBarItem = child.tabBarItem
                    newTabs[index] = newNav
                    tabBar.setViewControllers(newTabs, animated: false)
                    tabBar.selectedIndex = index
                    replaced = true
                    break
                }
            }
        }

        if !replaced {
            for (index, child) in tabs.enumerated() {
                let title = (child.tabBarItem.title ?? "").lowercased()
                if title.contains("mentor") || title.contains("mentorship") {
                    newNav.tabBarItem = child.tabBarItem
                    newTabs[index] = newNav
                    tabBar.setViewControllers(newTabs, animated: false)
                    tabBar.selectedIndex = index
                    replaced = true
                    break
                }
            }
        }

        if !replaced {
            newNav.tabBarItem = UITabBarItem(title: "Mentorship", image: UIImage(systemName: "person.2.fill"), tag: 99)
            newTabs.append(newNav)
            tabBar.setViewControllers(newTabs, animated: false)
            tabBar.selectedIndex = newTabs.count - 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            postBookingVC.reloadSessions()
        }
    }
}
