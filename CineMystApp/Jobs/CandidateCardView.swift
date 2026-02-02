import UIKit
import AVFoundation
import AVKit

class CandidateCardView: UIView {

    private let model: CandidateModel
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    init(model: CandidateModel) {
        self.model = model
        super.init(frame: .zero)

        layer.cornerRadius = 20
        layer.masksToBounds = true
        backgroundColor = .clear

        setupUI()
        setupVideo()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI Elements

    private let videoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    // Dark gradient overlay for better text visibility
    private let gradientLayer = CAGradientLayer()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 22)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let locationLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = UIColor(white: 0.9, alpha: 0.9)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let experienceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = UIColor(white: 0.9, alpha: 0.9)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let verifyIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let submittedBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Task Submitted", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let profileBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("View Profile", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.backgroundColor = UIColor(red: 70/255, green: 0, blue: 70/255, alpha: 0.9)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Setup Video

    private func setupVideo() {
        // Prefer remote URL if available, else fall back to bundled asset
        let urlToPlay: URL?
        if let remote = model.videoURL {
            urlToPlay = remote
        } else {
            urlToPlay = Bundle.main.url(forResource: model.videoName, withExtension: "mp4")
        }

        guard let videoURL = urlToPlay else {
            print("❌ CandidateCardView: No valid video URL for model \(model.name)")
            return
        }

        // Create player
        player = AVPlayer(url: videoURL)

        // Create player layer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = videoContainerView.bounds

        if let playerLayer = playerLayer {
            videoContainerView.layer.addSublayer(playerLayer)
        }

        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }

        // Start playing
        player?.play()

        // Mute by default (optional)
        player?.isMuted = true
    }

    // MARK: - Setup UI

    private func setupUI() {

        // VIDEO CONTAINER
        addSubview(videoContainerView)

        // GRADIENT
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.locations = [0.4, 1.0]
        layer.addSublayer(gradientLayer)

        // TEXT OVER VIDEO
        addSubview(nameLabel)
        addSubview(verifyIcon)
        addSubview(locationLabel)
        addSubview(experienceLabel)
        addSubview(submittedBtn)
        addSubview(profileBtn)

        nameLabel.text = model.name
        locationLabel.text = model.location
        experienceLabel.text = model.experience

        // MARK: Constraints

        NSLayoutConstraint.activate([

            // VIDEO CONTAINER → FILL ENTIRE CARD
            videoContainerView.topAnchor.constraint(equalTo: topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameLabel.bottomAnchor.constraint(equalTo: locationLabel.topAnchor, constant: -6),

            verifyIcon.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 6),
            verifyIcon.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            verifyIcon.widthAnchor.constraint(equalToConstant: 18),
            verifyIcon.heightAnchor.constraint(equalToConstant: 18),

            locationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            locationLabel.bottomAnchor.constraint(equalTo: experienceLabel.topAnchor, constant: -6),

            experienceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            experienceLabel.bottomAnchor.constraint(equalTo: submittedBtn.topAnchor, constant: -12),

            submittedBtn.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            submittedBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            submittedBtn.widthAnchor.constraint(equalToConstant: 120),
            submittedBtn.heightAnchor.constraint(equalToConstant: 32),

            profileBtn.leadingAnchor.constraint(equalTo: submittedBtn.trailingAnchor, constant: 12),
            profileBtn.centerYAnchor.constraint(equalTo: submittedBtn.centerYAnchor),
            profileBtn.widthAnchor.constraint(equalToConstant: 120),
            profileBtn.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        playerLayer?.frame = videoContainerView.bounds
    }

    // MARK: - Video Control

    func playVideo() {
        player?.play()
    }

    func pauseVideo() {
        player?.pause()
    }

    // Clean up when card is removed
    deinit {
        player?.pause()
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
}
