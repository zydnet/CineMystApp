import UIKit
import Supabase

class ApplicationStartedViewController: UIViewController {
    
    // MARK: - Properties
    var job: Job?
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://kyhyunyobgouumgwcigk.supabase.co")!,
        supabaseKey: "sb_publishable_oJe1X9aiPdKm6wqR1zvFhA_aIiej9-d"
    )
    
    @objc private func goToTask() {
        let vc = TaskDetailsViewController()
        vc.job = job // Pass job data to task details
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private let checkContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 249/255, green: 244/255, blue: 252/255, alpha: 1)
        view.layer.cornerRadius = 22
        view.layer.shadowColor = UIColor(red: 190/255, green: 160/255, blue: 210/255, alpha: 0.4).cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        return view
    }()
    
    private let checkIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tintColor = UIColor(red: 70/255, green: 20/255, blue: 60/255, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Application Started"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(" Submit Portfolio", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)

        btn.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        
        btn.layer.cornerRadius = 24
        btn.clipsToBounds = true
        
        // Button shadow
        btn.layer.shadowColor = UIColor(red: 160/255, green: 90/255, blue: 170/255, alpha: 0.4).cgColor
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowRadius = 10
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)

        return btn
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    private let taskButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Go to Task", for: .normal)
        btn.setTitleColor(UIColor(red: 70/255, green: 20/255, blue: 60/255, alpha: 1), for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        
        btn.layer.cornerRadius = 24
        btn.layer.borderWidth = 1.4
        btn.layer.borderColor = UIColor(red: 220/255, green: 190/255, blue: 245/255, alpha: 1).cgColor
        
        // Arrow icon
        let arrow = UIImage(systemName: "arrow.right")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 17, weight: .medium))
        btn.setImage(arrow, for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigation()
        setupLayout()
        
        submitButton.addTarget(self, action: #selector(portfolioSubmitted), for: .touchUpInside)
        taskButton.addTarget(self, action: #selector(goToTask), for: .touchUpInside)
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

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = submitButton.bounds
    }
    
    
    // MARK: - Navigation
    private func setupNavigation() {
        title = "Application"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(red: 70/255, green: 20/255, blue: 60/255, alpha: 1),
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        // Back arrow (not X)
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(closeTapped))
        back.tintColor = UIColor(red: 70/255, green: 20/255, blue: 60/255, alpha: 1)
        navigationItem.leftBarButtonItem = back
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
    
    
    // MARK: - Actions
    @objc private func portfolioSubmitted() {
        Task {
            await submitPortfolio()
        }
    }
    
    private func submitPortfolio() async {
        guard let job = job,
              let currentUser = supabase.auth.currentUser else {
            showAlert(title: "Error", message: "Missing job or user information")
            return
        }
        
        do {
            let actorId = currentUser.id
            
            print("📝 Submitting Portfolio:")
            print("  - Actor ID: \(actorId.uuidString)")
            print("  - Job ID: \(job.id.uuidString)")
            
            // Step 1: Check if application already exists
            let existingApps: [Application] = try await supabase
                .from("applications")
                .select()
                .eq("job_id", value: job.id.uuidString)
                .eq("actor_id", value: actorId.uuidString)
                .execute()
                .value
            
            print("  - Existing apps found: \(existingApps.count)")
            
            if let existingApp = existingApps.first {
                // Step 2: Update existing application with portfolio_submitted status
                let updatedApplication = Application(
                    id: existingApp.id,
                    jobId: existingApp.jobId,
                    actorId: existingApp.actorId,
                    status: .portfolioSubmitted,
                    portfolioUrl: currentUser.userMetadata["portfolio_url"] as? String,
                    portfolioSubmittedAt: Date(),
                    appliedAt: existingApp.appliedAt,
                    updatedAt: Date()
                )
                
                let _: Application = try await supabase
                    .from("applications")
                    .update(updatedApplication)
                    .eq("id", value: existingApp.id.uuidString)
                    .single()
                    .execute()
                    .value
                
                print("  ✅ Updated existing application")
            } else {
                // Step 3: Create new application record with portfolio_submitted status
                let application = Application(
                    id: UUID(),
                    jobId: job.id,
                    actorId: actorId,
                    status: .portfolioSubmitted,
                    portfolioUrl: currentUser.userMetadata["portfolio_url"] as? String,
                    portfolioSubmittedAt: Date(),
                    appliedAt: Date(),
                    updatedAt: Date()
                )
                
                print("  - Creating new application with:")
                print("    - App ID: \(application.id.uuidString)")
                print("    - Job ID: \(application.jobId.uuidString)")
                print("    - Actor ID: \(application.actorId.uuidString)")
                
                let _: Application = try await supabase
                    .from("applications")
                    .insert(application)
                    .single()
                    .execute()
                    .value
                
                print("  ✅ Created new application")
            }
            
            // Show success message
            showSuccessAlert(title: "Success", message: "Portfolio submitted! Your application is now visible in Active section.") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } catch {
            showAlert(title: "Error", message: "Failed to submit portfolio: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Layout
    private func setupLayout() {
        
        view.addSubview(checkContainer)
        checkContainer.addSubview(checkIcon)
        view.addSubview(statusLabel)
        view.addSubview(submitButton)
        view.addSubview(taskButton)
        
        checkContainer.translatesAutoresizingMaskIntoConstraints = false
        checkIcon.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        taskButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Gradient for submit button
        gradientLayer.colors = [
            UIColor(red: 67/255, green: 22/255, blue: 49/255, alpha: 1).cgColor,
            UIColor(red: 57/255, green: 14/255, blue: 71/255, alpha: 1).cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        submitButton.layer.insertSublayer(gradientLayer, at: 0)
        
        
        NSLayoutConstraint.activate([
            
            checkContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            checkContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkContainer.widthAnchor.constraint(equalToConstant: 95),
            checkContainer.heightAnchor.constraint(equalToConstant: 95),
            
            checkIcon.centerXAnchor.constraint(equalTo: checkContainer.centerXAnchor),
            checkIcon.centerYAnchor.constraint(equalTo: checkContainer.centerYAnchor),
            checkIcon.widthAnchor.constraint(equalToConstant: 32),
            checkIcon.heightAnchor.constraint(equalToConstant: 32),
            
            statusLabel.topAnchor.constraint(equalTo: checkContainer.bottomAnchor, constant: 35),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            submitButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 45),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            submitButton.heightAnchor.constraint(equalToConstant: 52),
            
            taskButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 22),
            taskButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            taskButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            taskButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}

