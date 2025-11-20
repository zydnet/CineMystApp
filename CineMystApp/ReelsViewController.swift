import UIKit
import AVFoundation

final class ReelsViewController: UIViewController {

    // MARK: - UI

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let dimOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0, alpha: 0.12)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // play triangle
    private let playTriangleView: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 78, weight: .light)
        iv.image = UIImage(systemName: "play", withConfiguration: cfg)
        iv.tintColor = UIColor(white: 1, alpha: 0.9)
        iv.contentMode = .center
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // right actions
    private let actionStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 18
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    private func actionButton(systemName: String, value: String) -> UIStackView {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: systemName), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 44).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let lbl = UILabel()
        lbl.text = value
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let sv = UIStackView(arrangedSubviews: [btn, lbl])
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 6
        return sv
    }

    // caption container
    private let captionContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()
    private let captionGradient: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(white: 0.00, alpha: 0.55).cgColor,
            UIColor(white: 0.00, alpha: 0.25).cgColor,
            UIColor(white: 0.00, alpha: 0.05).cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 1)
        g.endPoint = CGPoint(x: 0, y: 0)
        return g
    }()

    // profile row
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 18
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .darkGray
        return iv
    }()
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = "Emily Watson"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let connectButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Connect", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // small avatars + liked by
    private let smallAvatarsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = -8
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    private let likedByLabel: UILabel = {
        let l = UILabel()
        l.text = "Liked by your friend and 25,513 others"
        l.font = .systemFont(ofSize: 13)
        l.textColor = .white
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // audio row
    private let audioTagButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("🎵 Title · Original audio", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        b.backgroundColor = UIColor(white: 0, alpha: 0.25)
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private let sendGiftButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Send gift", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        b.backgroundColor = UIColor(white: 0, alpha: 0.18)
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private let musicThumb: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .black
        return iv
    }()

    // stored constraints
    private var captionContainerBottomConstraint: NSLayoutConstraint!
    private var actionStackBottomConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        setupConstraints()
        loadPlaceholderImage()
        loadPortraitExamples()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // use tabBar height so captions + icons always sit above the system tab bar
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        captionContainerBottomConstraint.constant = -(tabBarHeight + 12)

        // keep action stack anchored above the caption container (small gap)
        // set this constant to - (captionHeight + gap) — we constrain bottom to captionContainer.top
        actionStackBottomConstraint.constant = -20

        // update gradient frame
        captionGradient.frame = captionContainer.bounds
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(dimOverlay)
        view.addSubview(playTriangleView)

        // right actions
        view.addSubview(actionStack)
        actionStack.addArrangedSubview(actionButton(systemName: "heart.fill", value: "253K"))
        actionStack.addArrangedSubview(actionButton(systemName: "message", value: "1.139"))
        actionStack.addArrangedSubview(actionButton(systemName: "paperplane", value: "29"))
        actionStack.addArrangedSubview(actionButton(systemName: "bookmark", value: ""))

        // caption container contents
        view.addSubview(captionContainer)
        captionContainer.layer.insertSublayer(captionGradient, at: 0)

        captionContainer.addSubview(avatarImageView)
        captionContainer.addSubview(nameLabel)
        captionContainer.addSubview(connectButton)

        captionContainer.addSubview(smallAvatarsStack)
        captionContainer.addSubview(likedByLabel)

        captionContainer.addSubview(audioTagButton)
        captionContainer.addSubview(sendGiftButton)
        captionContainer.addSubview(musicThumb)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // background
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            dimOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            dimOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // play
            playTriangleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playTriangleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playTriangleView.widthAnchor.constraint(equalToConstant: 96),
            playTriangleView.heightAnchor.constraint(equalToConstant: 96),

            // action stack - keep trailing to view.trailing
            actionStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14)
        ])

        // caption container width (left side) — stays out of actionStack area
        NSLayoutConstraint.activate([
            captionContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            captionContainer.trailingAnchor.constraint(lessThanOrEqualTo: actionStack.leadingAnchor, constant: -18)
        ])

        // avatar, name, connect (row)
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: captionContainer.leadingAnchor, constant: 10),
            avatarImageView.topAnchor.constraint(equalTo: captionContainer.topAnchor, constant: 10),
            avatarImageView.widthAnchor.constraint(equalToConstant: 36),
            avatarImageView.heightAnchor.constraint(equalToConstant: 36),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),

            connectButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            connectButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            connectButton.trailingAnchor.constraint(lessThanOrEqualTo: captionContainer.trailingAnchor, constant: -10)
        ])

        // small avatars + likedBy
        NSLayoutConstraint.activate([
            smallAvatarsStack.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            smallAvatarsStack.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            smallAvatarsStack.heightAnchor.constraint(equalToConstant: 28),

            likedByLabel.leadingAnchor.constraint(equalTo: smallAvatarsStack.trailingAnchor, constant: 8),
            likedByLabel.centerYAnchor.constraint(equalTo: smallAvatarsStack.centerYAnchor),
            likedByLabel.trailingAnchor.constraint(lessThanOrEqualTo: captionContainer.trailingAnchor, constant: -10)
        ])

        // audio row
        NSLayoutConstraint.activate([
            audioTagButton.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            audioTagButton.topAnchor.constraint(equalTo: smallAvatarsStack.bottomAnchor, constant: 10),

            sendGiftButton.leadingAnchor.constraint(equalTo: audioTagButton.trailingAnchor, constant: 10),
            sendGiftButton.centerYAnchor.constraint(equalTo: audioTagButton.centerYAnchor),

            musicThumb.leadingAnchor.constraint(equalTo: sendGiftButton.trailingAnchor, constant: 10),
            musicThumb.widthAnchor.constraint(equalToConstant: 34),
            musicThumb.heightAnchor.constraint(equalToConstant: 34),
            musicThumb.centerYAnchor.constraint(equalTo: audioTagButton.centerYAnchor),

            musicThumb.trailingAnchor.constraint(lessThanOrEqualTo: captionContainer.trailingAnchor, constant: -10),
            musicThumb.bottomAnchor.constraint(equalTo: captionContainer.bottomAnchor, constant: -10),
        ])

        // bottom & action stack bottom constraints
        captionContainerBottomConstraint = captionContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -88)
        captionContainerBottomConstraint.isActive = true

        // anchor actionStack bottom to captionContainer.top (so icons sit above the caption container)
        actionStackBottomConstraint = actionStack.bottomAnchor.constraint(equalTo: captionContainer.topAnchor, constant: -20)
        actionStackBottomConstraint.isActive = true
    }

    // MARK: - Helpers / sample data

    private func loadPlaceholderImage() {
        let path = "/mnt/data/6e1783df-eca5-4630-9623-dbe39e50f04e.png"
        if let img = UIImage(contentsOfFile: path) {
            backgroundImageView.image = img
            musicThumb.image = img
            avatarImageView.image = img
        } else {
            backgroundImageView.image = UIImage(named: "flick")
            musicThumb.image = UIImage(named: "flick")
            avatarImageView.image = UIImage(named: "flick")
        }
    }

    private func loadPortraitExamples() {
        smallAvatarsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for _ in 0..<3 {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 28).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 28).isActive = true
            iv.layer.cornerRadius = 14
            iv.layer.masksToBounds = true
            iv.layer.borderColor = UIColor.white.cgColor
            iv.layer.borderWidth = 1.0
            iv.backgroundColor = .gray
            if let img = backgroundImageView.image { iv.image = img }
            smallAvatarsStack.addArrangedSubview(iv)
        }
    }
}
