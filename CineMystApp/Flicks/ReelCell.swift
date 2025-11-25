//
//  ReelCell.swift
//  CineMystApp
//
//  Updated to match Instagram Reels design
//  Second pass: fixed bottom alignment and safe-area issues
//

import UIKit
import AVFoundation

// MARK: - Delegate Protocol
protocol ReelCellDelegate: AnyObject {
    func didTapComment(on cell: ReelCell)
    func didTapShare(on cell: ReelCell)
}

final class ReelCell: UICollectionViewCell {
    
    static let identifier = "ReelCell"
    
    // Delegates for button actions
    weak var delegate: ReelCellDelegate?
    
    // State
    private var isLiked = false
    
    // Video player
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    
    // Small layout tune constants
    private enum Layout {
        static let rightStackBottom: CGFloat = -130   // move icons up from safe area
        static let bottomInfoBottom: CGFloat = -96    // bottom-left info baseline above tab bar
        static let musicDiscBottom: CGFloat = -20
        static let horizontalMargin: CGFloat = 12
    }
    
    // UI Elements
    private let playIconView: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 120, weight: .ultraLight)
        iv.image = UIImage(systemName: "play.fill", withConfiguration: cfg)
        iv.tintColor = UIColor(white: 1, alpha: 0.85)
        iv.contentMode = .center
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()
    
    // Top bar
    private let topBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let snapsLabel: UILabel = {
        let l = UILabel()
        l.text = "Snaps"
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let dropdownIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.down")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let shareIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "paperplane")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Right action stack
    private let actionStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 24
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let likeButton = ReelCell.actionButton(systemName: "heart.fill", value: "253K")
    private let commentButton = ReelCell.actionButton(systemName: "message", value: "1,139")
    private let shareButton = ReelCell.actionButton(systemName: "paperplane", value: "29")
    private let moreButton = ReelCell.actionButton(systemName: "ellipsis", value: "")
    
    // Music disc at bottom of action stack
    private let musicDiscView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    // Bottom info section
    private let bottomInfoContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let connectButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Connect", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 0.9)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        b.contentEdgeInsets = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
        b.layer.cornerRadius = 4
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let captionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .white
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let likedByLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let audioContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0, alpha: 0.3)
        v.layer.cornerRadius = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let audioIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "music.note")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let audioLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let giftIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "gift")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let sendGiftLabel: UILabel = {
        let l = UILabel()
        l.text = "Send gift"
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let musicThumb: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 5
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.backgroundColor = .black
        
        // Play icon
        contentView.addSubview(playIconView)
        
        // Top bar
        contentView.addSubview(topBar)
        topBar.addSubview(snapsLabel)
        topBar.addSubview(dropdownIcon)
        topBar.addSubview(shareIcon)
        
        // Action stack
        contentView.addSubview(actionStack)
        actionStack.addArrangedSubview(likeButton)
        actionStack.addArrangedSubview(commentButton)
        actionStack.addArrangedSubview(shareButton)
        actionStack.addArrangedSubview(moreButton)
        
        // Music disc
        contentView.addSubview(musicDiscView)
        
        // Bottom info
        contentView.addSubview(bottomInfoContainer)
        bottomInfoContainer.addSubview(avatarImageView)
        bottomInfoContainer.addSubview(nameLabel)
        bottomInfoContainer.addSubview(connectButton)
        bottomInfoContainer.addSubview(captionLabel)
        bottomInfoContainer.addSubview(likedByLabel)
        bottomInfoContainer.addSubview(audioContainer)
        
        audioContainer.addSubview(audioIcon)
        audioContainer.addSubview(audioLabel)
        audioContainer.addSubview(giftIcon)
        audioContainer.addSubview(sendGiftLabel)
        audioContainer.addSubview(musicThumb)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // ensure autoresizing masks are off
        [playIconView, topBar, snapsLabel, dropdownIcon, shareIcon, actionStack, musicDiscView,
         bottomInfoContainer, avatarImageView, nameLabel, connectButton, captionLabel, likedByLabel,
         audioContainer, audioIcon, audioLabel, giftIcon, sendGiftLabel, musicThumb]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            // Play icon
            playIconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playIconView.widthAnchor.constraint(equalToConstant: 150),
            playIconView.heightAnchor.constraint(equalToConstant: 150),
            
            // Top bar
            topBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            topBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            topBar.heightAnchor.constraint(equalToConstant: 44),
            
            snapsLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            snapsLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            
            dropdownIcon.leadingAnchor.constraint(equalTo: snapsLabel.trailingAnchor, constant: 8),
            dropdownIcon.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            dropdownIcon.widthAnchor.constraint(equalToConstant: 16),
            dropdownIcon.heightAnchor.constraint(equalToConstant: 16),
            
            shareIcon.trailingAnchor.constraint(equalTo: topBar.trailingAnchor),
            shareIcon.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            shareIcon.widthAnchor.constraint(equalToConstant: 24),
            shareIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // Action stack pinned to bottom-right (raised above tab bar by a fixed amount)
            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalMargin),
            actionStack.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: Layout.rightStackBottom),
            
            // Music disc
            musicDiscView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalMargin),
            musicDiscView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: Layout.musicDiscBottom),
            musicDiscView.widthAnchor.constraint(equalToConstant: 40),
            musicDiscView.heightAnchor.constraint(equalToConstant: 40),
            
            // Bottom info container pinned to bottom-left and raised above the tab bar
            bottomInfoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalMargin),
            bottomInfoContainer.trailingAnchor.constraint(equalTo: actionStack.leadingAnchor, constant: -12),
            bottomInfoContainer.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: Layout.bottomInfoBottom),
            
            // Avatar & name
            avatarImageView.leadingAnchor.constraint(equalTo: bottomInfoContainer.leadingAnchor),
            avatarImageView.topAnchor.constraint(equalTo: bottomInfoContainer.topAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            
            // connect button should not push out of container: allow it to compress if needed
            connectButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            connectButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            connectButton.heightAnchor.constraint(equalToConstant: 26),
            connectButton.trailingAnchor.constraint(lessThanOrEqualTo: bottomInfoContainer.trailingAnchor),
            
            // Caption
            captionLabel.leadingAnchor.constraint(equalTo: bottomInfoContainer.leadingAnchor),
            captionLabel.trailingAnchor.constraint(equalTo: bottomInfoContainer.trailingAnchor),
            captionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            
            // Liked by
            likedByLabel.leadingAnchor.constraint(equalTo: bottomInfoContainer.leadingAnchor),
            likedByLabel.trailingAnchor.constraint(equalTo: bottomInfoContainer.trailingAnchor),
            likedByLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 6),
            
            // Audio container
            audioContainer.leadingAnchor.constraint(equalTo: bottomInfoContainer.leadingAnchor),
            audioContainer.trailingAnchor.constraint(lessThanOrEqualTo: bottomInfoContainer.trailingAnchor),
            audioContainer.topAnchor.constraint(equalTo: likedByLabel.bottomAnchor, constant: 8),
            audioContainer.bottomAnchor.constraint(equalTo: bottomInfoContainer.bottomAnchor),
            audioContainer.heightAnchor.constraint(equalToConstant: 40),
            
            // Audio icon
            audioIcon.leadingAnchor.constraint(equalTo: audioContainer.leadingAnchor, constant: 10),
            audioIcon.centerYAnchor.constraint(equalTo: audioContainer.centerYAnchor),
            audioIcon.widthAnchor.constraint(equalToConstant: 16),
            audioIcon.heightAnchor.constraint(equalToConstant: 16),
            
            // Audio label
            audioLabel.leadingAnchor.constraint(equalTo: audioIcon.trailingAnchor, constant: 6),
            audioLabel.centerYAnchor.constraint(equalTo: audioContainer.centerYAnchor),
            
            // Gift icon
            giftIcon.leadingAnchor.constraint(equalTo: audioLabel.trailingAnchor, constant: 16),
            giftIcon.centerYAnchor.constraint(equalTo: audioContainer.centerYAnchor),
            giftIcon.widthAnchor.constraint(equalToConstant: 16),
            giftIcon.heightAnchor.constraint(equalToConstant: 16),
            
            // Send gift label
            sendGiftLabel.leadingAnchor.constraint(equalTo: giftIcon.trailingAnchor, constant: 6),
            sendGiftLabel.centerYAnchor.constraint(equalTo: audioContainer.centerYAnchor),
            
            // Music thumb
            musicThumb.leadingAnchor.constraint(equalTo: sendGiftLabel.trailingAnchor, constant: 12),
            musicThumb.trailingAnchor.constraint(equalTo: audioContainer.trailingAnchor, constant: -8),
            musicThumb.centerYAnchor.constraint(equalTo: audioContainer.centerYAnchor),
            musicThumb.widthAnchor.constraint(equalToConstant: 28),
            musicThumb.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        // prevent "Connect" from growing past the available space
        connectButton.setContentCompressionResistancePriority(.required, for: .vertical)
        connectButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tap)
        
        // Add button actions
        if let likeBtn = likeButton.arrangedSubviews.first as? UIButton {
            likeBtn.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        }
        if let commentBtn = commentButton.arrangedSubviews.first as? UIButton {
            commentBtn.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        }
        if let shareBtn = shareButton.arrangedSubviews.first as? UIButton {
            shareBtn.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        }
    }
    
    @objc private func handleTap() {
        togglePlayPause()
    }
    
    @objc private func handleLike() {
        isLiked.toggle()
        
        if let likeBtn = likeButton.arrangedSubviews.first as? UIButton {
            UIView.animate(withDuration: 0.1, animations: {
                likeBtn.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    likeBtn.transform = .identity
                }
            }
            
            likeBtn.tintColor = isLiked ? .systemRed : .white
        }
    }
    
    @objc private func handleComment() {
        delegate?.didTapComment(on: self)
    }
    
    @objc private func handleShare() {
        delegate?.didTapShare(on: self)
    }
    
    // MARK: - Configuration
    func configure(with reel: Reel) {
        nameLabel.text = reel.authorName
        avatarImageView.image = reel.authorAvatar
        musicThumb.image = reel.authorAvatar
        musicDiscView.image = reel.authorAvatar
        audioLabel.text = reel.audioTitle
        captionLabel.text = "Try at your own risk..."
        
        // Create attributed string for "Liked by" label
        let likedText = "Liked by your friend and 25,513 others"
        let attributedString = NSMutableAttributedString(string: likedText)
        if let range = likedText.range(of: "your friend") {
            let nsRange = NSRange(range, in: likedText)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12, weight: .semibold), range: nsRange)
        }
        likedByLabel.attributedText = attributedString
        
        if let likeLabel = likeButton.arrangedSubviews.last as? UILabel {
            likeLabel.text = reel.likes
        }
        if let commentLabel = commentButton.arrangedSubviews.last as? UILabel {
            commentLabel.text = reel.comments
        }
        if let shareLabel = shareButton.arrangedSubviews.last as? UILabel {
            shareLabel.text = reel.shares
        }
        
        setupVideoPlayer(with: reel.videoURL)
    }
    
    // MARK: - Video Player
    private func setupVideoPlayer(with videoFileName: String) {
        cleanupPlayer()
        
        guard let url = Bundle.main.url(forResource: videoFileName, withExtension: "mp4") else {
            print("❌ Video not found: \(videoFileName).mp4")
            return
        }
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = contentView.bounds
        
        if let playerLayer = playerLayer {
            contentView.layer.insertSublayer(playerLayer, at: 0)
        }
        
        queuePlayer?.isMuted = false
    }
    
    func play() {
        queuePlayer?.play()
        playIconView.isHidden = true
    }
    
    func pause() {
        queuePlayer?.pause()
        playIconView.isHidden = false
    }
    
    private func togglePlayPause() {
        guard let player = queuePlayer else { return }
        
        if player.rate > 0 {
            pause()
        } else {
            play()
        }
    }
    
    private func cleanupPlayer() {
        queuePlayer?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        queuePlayer = nil
        playerLooper = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanupPlayer()
    }
    
    deinit {
        cleanupPlayer()
    }
    
    // MARK: - Helper
    private static func actionButton(systemName: String, value: String) -> UIStackView {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        btn.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 44).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let lbl = UILabel()
        lbl.text = value
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        let sv = UIStackView(arrangedSubviews: [btn, lbl])
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 2
        return sv
    }
}
