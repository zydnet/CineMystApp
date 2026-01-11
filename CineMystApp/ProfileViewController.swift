//
//  ProfileViewController.swift
//  CineMystApp
//
//  Created by Devanshi on 11/11/25.
//

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    private let coverLabel = UILabel()
    private let profileImageView = UIImageView()
    private let verifiedBadge = UIImageView()

    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let connectionsLabel = UILabel()

    private let connectButton = UIButton(type: .system)
    private let portfolioButton = UIButton(type: .system)

    private let aboutTitle = UILabel()
    private let aboutText = UILabel()

    private let locationIcon = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
    private let experienceIcon = UIImageView(image: UIImage(systemName: "briefcase"))
    private let locationLabel = UILabel()
    private let experienceLabel = UILabel()

    private let segmentControl = UISegmentedControl(items: ["Gallery", "Flicks", "Tagged"])
    private let collectionView: UICollectionView

    private var galleryImages = ["rani1", "rani2", "rani3", "rani4", "rani5", "rani6"]
    
    // MARK: - Profile Data
    private var userProfile: UserProfileData?

    // MARK: - Init
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        hidesBottomBarWhenPushed = true

        setupNavigationBar()
        setupScrollView()
        setupUI()
        layoutUI()
        
        fetchProfileData()
    }

    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = ""
        navigationItem.backButtonTitle = ""

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }

    // MARK: - Setup Scroll View
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Setup UI
    private func setupUI() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        coverLabel.text = "Loading..."
        coverLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        coverLabel.textAlignment = .center

        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .systemGray3
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        verifiedBadge.image = UIImage(systemName: "checkmark.seal.fill")
        verifiedBadge.tintColor = UIColor.systemBlue
        verifiedBadge.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.text = "..."
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textAlignment = .center

        usernameLabel.text = "..."
        usernameLabel.font = .systemFont(ofSize: 13)
        usernameLabel.textColor = .secondaryLabel
        usernameLabel.textAlignment = .center

        connectionsLabel.text = "0 Connections"
        connectionsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        connectionsLabel.textAlignment = .center
        connectionsLabel.textColor = .secondaryLabel

        connectButton.setTitle("Connected", for: .normal)
        connectButton.backgroundColor = UIColor(named: "AccentColor") ?? UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1.0)
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.layer.cornerRadius = 10
        connectButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)

        portfolioButton.setTitle("View Portfolio", for: .normal)
        portfolioButton.backgroundColor = UIColor(named: "AccentColor") ?? UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1.0)
        portfolioButton.setTitleColor(.white, for: .normal)
        portfolioButton.layer.cornerRadius = 10
        portfolioButton.layer.shadowOpacity = 0.2
        portfolioButton.layer.shadowRadius = 2
        portfolioButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        portfolioButton.addTarget(self, action: #selector(openPortfolio), for: .touchUpInside)

        aboutTitle.text = "About"
        aboutTitle.font = .systemFont(ofSize: 17, weight: .semibold)

        aboutText.text = "Loading profile information..."
        aboutText.numberOfLines = 0
        aboutText.font = .systemFont(ofSize: 14)

        locationIcon.tintColor = .label
        experienceIcon.tintColor = .label

        locationLabel.text = "..."
        locationLabel.font = .systemFont(ofSize: 13)

        experienceLabel.text = "..."
        experienceLabel.font = .systemFont(ofSize: 13)

        segmentControl.selectedSegmentIndex = 0
        segmentControl.backgroundColor = .clear
        segmentControl.selectedSegmentTintColor = .clear
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.systemPurple, .font: UIFont.boldSystemFont(ofSize: 15)], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "GalleryCell")

        [coverLabel, profileImageView, verifiedBadge, nameLabel, usernameLabel, connectionsLabel,
         connectButton, portfolioButton, aboutTitle, aboutText, locationIcon, experienceIcon,
         locationLabel, experienceLabel, segmentControl, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    // MARK: - Layout
    private func layoutUI() {
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            coverLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            coverLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            profileImageView.topAnchor.constraint(equalTo: coverLabel.bottomAnchor, constant: 16),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            verifiedBadge.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 6),
            verifiedBadge.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            verifiedBadge.widthAnchor.constraint(equalToConstant: 20),
            verifiedBadge.heightAnchor.constraint(equalToConstant: 20),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            connectionsLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 6),
            connectionsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            connectButton.topAnchor.constraint(equalTo: connectionsLabel.bottomAnchor, constant: 16),
            connectButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            connectButton.widthAnchor.constraint(equalToConstant: 140),
            connectButton.heightAnchor.constraint(equalToConstant: 38),

            portfolioButton.centerYAnchor.constraint(equalTo: connectButton.centerYAnchor),
            portfolioButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            portfolioButton.widthAnchor.constraint(equalToConstant: 140),
            portfolioButton.heightAnchor.constraint(equalToConstant: 38),

            aboutTitle.topAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: 30),
            aboutTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            aboutText.topAnchor.constraint(equalTo: aboutTitle.bottomAnchor, constant: 6),
            aboutText.leadingAnchor.constraint(equalTo: aboutTitle.leadingAnchor),
            aboutText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            locationIcon.topAnchor.constraint(equalTo: aboutText.bottomAnchor, constant: 16),
            locationIcon.leadingAnchor.constraint(equalTo: aboutText.leadingAnchor),
            locationIcon.widthAnchor.constraint(equalToConstant: 16),
            locationIcon.heightAnchor.constraint(equalToConstant: 16),

            locationLabel.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 6),

            experienceIcon.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            experienceIcon.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -10),
            experienceIcon.widthAnchor.constraint(equalToConstant: 16),
            experienceIcon.heightAnchor.constraint(equalToConstant: 16),

            experienceLabel.centerYAnchor.constraint(equalTo: experienceIcon.centerYAnchor),
            experienceLabel.leadingAnchor.constraint(equalTo: experienceIcon.trailingAnchor, constant: 6),

            segmentControl.topAnchor.constraint(equalTo: locationIcon.bottomAnchor, constant: 24),
            segmentControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            collectionView.heightAnchor.constraint(equalToConstant: 600),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Fetch Profile Data
    private func fetchProfileData() {
        loadingIndicator.startAnimating()
        scrollView.alpha = 0.5
        
        Task {
            do {
                print("🔍 Fetching profile data...")
                
                guard let session = try await AuthManager.shared.currentSession() else {
                    throw ProfileError.invalidSession
                }
                
                let userId = session.user.id
                print("👤 User ID: \(userId)")
                
                // ✅ FIX: Decode as ARRAY first, then get first element
                let profileResponse = try await supabase
                    .from("profiles")
                    .select()
                    .eq("id", value: userId.uuidString)
                    .execute()
                
                // Decode as array
                let profileArray = try JSONDecoder().decode([ProfileRecord].self, from: profileResponse.data)
                
                guard let profile = profileArray.first else {
                    throw ProfileError.noProfileFound
                }
                
                print("✅ Profile fetched: \(profile.role)")
                print("   Username: \(profile.username ?? "nil")")
                print("   Full Name: \(profile.fullName ?? "nil")")
                
                // Fetch role-specific data
                var artistProfile: ArtistProfileRecord?
                var castingProfile: CastingProfileRecord?
                
                if profile.role == "artist" {
                    do {
                        let artistResponse = try await supabase
                            .from("artist_profiles")
                            .select()
                            .eq("id", value: userId.uuidString)
                            .execute()
                        
                        // Decode as array
                        let artistArray = try JSONDecoder().decode([ArtistProfileRecord].self, from: artistResponse.data)
                        artistProfile = artistArray.first
                        print("✅ Artist profile fetched")
                    } catch {
                        print("⚠️ No artist profile found: \(error)")
                    }
                } else if profile.role == "casting_professional" {
                    do {
                        let castingResponse = try await supabase
                            .from("casting_profiles")
                            .select()
                            .eq("id", value: userId.uuidString)
                            .execute()
                        
                        // Decode as array
                        let castingArray = try JSONDecoder().decode([CastingProfileRecord].self, from: castingResponse.data)
                        castingProfile = castingArray.first
                        print("✅ Casting profile fetched")
                    } catch {
                        print("⚠️ No casting profile found: \(error)")
                    }
                }
                
                let userData = UserProfileData(
                    profile: profile,
                    artistProfile: artistProfile,
                    castingProfile: castingProfile,
                    email: session.user.email ?? ""
                )
                
                await MainActor.run {
                    self.userProfile = userData
                    self.updateUI(with: userData)
                    self.loadingIndicator.stopAnimating()
                    
                    UIView.animate(withDuration: 0.3) {
                        self.scrollView.alpha = 1.0
                    }
                }
                
            } catch {
                print("❌ Error fetching profile: \(error)")
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.scrollView.alpha = 1.0
                    self.showError(message: "Failed to load profile data")
                }
            }
        }
    }

    
    // MARK: - Update UI with Profile Data
    private func updateUI(with data: UserProfileData) {
        print("🎨 Updating UI with profile data")
        
        if data.profile.role == "artist" {
            let primaryRole = data.artistProfile?.primaryRoles.first ?? "Actor"
            coverLabel.text = "\(primaryRole) for Life"
        } else {
            coverLabel.text = data.castingProfile?.specificRole ?? "Casting Professional"
        }
        
        let displayName = data.profile.fullName ?? data.email.components(separatedBy: "@").first?.capitalized ?? "User"
        nameLabel.text = displayName
        
        let username = data.profile.username ?? data.email.components(separatedBy: "@").first ?? "user"
        let roleDisplay = data.profile.role == "artist" ? "Professional Actor" : "Casting Professional"
        usernameLabel.text = "@\(username) • \(roleDisplay)"
        
        if let profilePicUrl = data.profile.profilePictureUrl,
           let url = URL(string: profilePicUrl) {
            loadProfileImage(from: url)
        }
        
        if let city = data.profile.locationCity, let state = data.profile.locationState {
            locationLabel.text = "\(city), \(state)"
        } else if let state = data.profile.locationState {
            locationLabel.text = state
        }
        
        if let experience = data.artistProfile?.experienceYears {
            experienceLabel.text = "\(experience) years"
        } else {
            experienceLabel.text = "Experience"
        }
        
        var aboutComponents: [String] = []
        
        if data.profile.role == "artist", let artist = data.artistProfile {
            let stage = artist.careerStage?.capitalized ?? "Professional"
            let roles = artist.primaryRoles.joined(separator: ", ")
            let experience = artist.experienceYears ?? "0"
            
            aboutComponents.append("\(stage) \(roles.lowercased()) with \(experience) years of experience in")
            
            if !artist.skills.isEmpty {
                aboutComponents.append(artist.skills.prefix(3).joined(separator: ", ").lowercased() + ".")
            } else {
                aboutComponents.append("theater, film, and television.")
            }
            
            aboutComponents.append("Passionate about storytelling and bringing characters to life.")
            
        } else if let casting = data.castingProfile {
            let company = casting.companyName ?? "the industry"
            let types = casting.castingTypes.joined(separator: ", ")
            
            aboutComponents.append("Casting professional")
            if !company.isEmpty {
                aboutComponents.append("at \(company).")
            }
            if !types.isEmpty {
                aboutComponents.append("Specializing in \(types.lowercased()).")
            }
            
            if let radius = casting.castingRadius {
                aboutComponents.append("Working within \(radius)km radius.")
            }
        }
        
        aboutText.text = aboutComponents.joined(separator: " ")
        
        print("✅ UI updated successfully")
    }
    
    // MARK: - Load Profile Image
    private func loadProfileImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.profileImageView.image = image
                        self.profileImageView.tintColor = nil
                    }
                    print("✅ Profile image loaded")
                }
            } catch {
                print("❌ Error loading profile image: \(error)")
            }
        }
    }
    
    // MARK: - Error Handling
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchProfileData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Navigation
    @objc private func openPortfolio() {
        let portfolioVC = PortfolioViewController()
        portfolioVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(portfolioVC, animated: true)
    }
}

// MARK: - UICollectionView
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        galleryImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.configure(imageName: galleryImages[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 6) / 3
        return CGSize(width: width, height: width)
    }
}

// MARK: - User Profile Data Model
struct UserProfileData {
    let profile: ProfileRecord
    let artistProfile: ArtistProfileRecord?
    let castingProfile: CastingProfileRecord?
    let email: String
}
