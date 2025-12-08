import UIKit
//main first job screen
class JobCardView: UIView {
    
    private let profileImageView = UIImageView()
    private let titleLabel = UILabel()
    private let companyTagContainer = UIView()
    private let companyTagLabel = UILabel()
    private let bookmarkButton = UIButton(type: .system)
    private let locationIcon = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
    private let locationLabel = UILabel()
    private let salaryLabel = UILabel()
    private let clockIcon = UIImageView(image: UIImage(systemName: "clock"))
    private let daysLeftLabel = UILabel()
    private let tagLabel = UILabel()
    private let appliedLabel = UILabel()
    private let applyButton = UIButton(type: .system)
    
    var onTap: (() -> Void)?
    var onApplyTap: (() -> Void)?
    var onBookmarkTap: (() -> Void)?


    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(
        image: UIImage?,
        title: String,
        company: String,
        location: String,
        salary: String,
        daysLeft: String,
        tag: String,
        appliedCount: String = "0 applied"
    ) {
        profileImageView.image = image
        titleLabel.text = title
        companyTagLabel.text = company
        locationLabel.text = location
        salaryLabel.text = salary
        daysLeftLabel.text = daysLeft
        tagLabel.text = "• \(tag)"
        appliedLabel.text = appliedCount
    }

    
    // MARK: - Add Tap Gesture
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    @objc private func cardTapped() {
        onTap?()    // 👈 triggers navigation
    }
    @objc private func applyTapped() {
        onApplyTap?()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // Image
        profileImageView.layer.cornerRadius = 28
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .systemGray5
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        
        // Company label (simple text, no rounded tag box)
        companyTagLabel.font = UIFont.systemFont(ofSize: 13)
        companyTagLabel.textColor = .darkGray
        
        // Bookmark button - top right floating
        bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        bookmarkButton.tintColor = UIColor(red: 80/255, green: 25/255, blue: 60/255, alpha: 1)
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bookmarkButton)
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        
        // Location + Salary row (clean, compact)
        locationIcon.tintColor = .gray
        clockIcon.tintColor = .gray
        
        locationLabel.font = UIFont.systemFont(ofSize: 13)
        locationLabel.textColor = .darkGray
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        clockIcon.translatesAutoresizingMaskIntoConstraints = false
        
        salaryLabel.font = UIFont.boldSystemFont(ofSize: 14)
        salaryLabel.textColor = UIColor(red: 113/255, green: 30/255, blue: 96/255, alpha: 1)
        
        daysLeftLabel.font = UIFont.systemFont(ofSize: 13)
        daysLeftLabel.textColor = .gray
        
        tagLabel.font = UIFont.systemFont(ofSize: 12)
        tagLabel.textColor = .darkGray
        tagLabel.backgroundColor = UIColor.systemGray6
        tagLabel.layer.cornerRadius = 10
        tagLabel.clipsToBounds = true
        tagLabel.textAlignment = .center
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        appliedLabel.font = UIFont.systemFont(ofSize: 12)
        appliedLabel.textColor = .gray
        
        // Apply button — compact style
        applyButton.setTitle("Apply", for: .normal)
        applyButton.backgroundColor = UIColor(red: 47/255, green: 9/255, blue: 32/255, alpha: 1)
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        applyButton.layer.cornerRadius = 8
        applyButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        
        // ---------- STACK LAYOUT ----------
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, companyTagLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 4
        
        let salaryLocationRow = UIStackView(arrangedSubviews: [
            iconLabelStack(icon: locationIcon, label: locationLabel),
            salaryLabel
        ])
        salaryLocationRow.axis = .horizontal
        salaryLocationRow.spacing = 10
        salaryLocationRow.alignment = .center
        
        let tagAppliedRow = UIStackView(arrangedSubviews: [
            tagLabel,
            appliedLabel
        ])
        tagAppliedRow.axis = .horizontal
        tagAppliedRow.distribution = .equalSpacing
        
        let topRow = UIStackView(arrangedSubviews: [profileImageView, titleStack])
        topRow.axis = .horizontal
        topRow.spacing = 12
        
        let mainStack = UIStackView(arrangedSubviews: [
            topRow,
            salaryLocationRow,
            tagAppliedRow,
            applyButton
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
                locationIcon.widthAnchor.constraint(equalToConstant: 14),
                locationIcon.heightAnchor.constraint(equalToConstant: 14),
                clockIcon.widthAnchor.constraint(equalToConstant: 14),
                clockIcon.heightAnchor.constraint(equalToConstant: 14),
                
            profileImageView.widthAnchor.constraint(equalToConstant: 56),
            profileImageView.heightAnchor.constraint(equalToConstant: 56),
            
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            bookmarkButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            bookmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 22),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    
    private func iconLabelStack(icon: UIImageView, label: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }
    @objc private func bookmarkTapped() {
        onBookmarkTap?()
    }
    func updateBookmark(isBookmarked: Bool) {
        let icon = isBookmarked ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: icon), for: .normal)
    }

}
