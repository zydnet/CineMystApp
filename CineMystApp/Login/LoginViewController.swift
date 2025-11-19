//
//  LoginViewController.swift
//  CineMystApp
//
//  Created by user@50 on 11/11/25.
//

import UIKit
import Supabase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Gradient Layer
    private var gradientLayer: CAGradientLayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        applyGradientBackground()
        setupUI()
        setupActivityIndicator()
      }
      
      override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          // ensure gradient resizes on rotation or layout changes
          updateGradientFrame()
      }
      
      // MARK: - Gradient Layer
      
      
      
      private func applyGradientBackground() {
          let gradient = CAGradientLayer()
          
          gradient.colors = [
            UIColor(red: 54/255, green: 18/255, blue: 52/255, alpha: 1).cgColor, // top color
            UIColor(red: 22/255, green: 8/255, blue: 35/255, alpha: 1).cgColor   // bottom color
          ]
          gradient.startPoint = CGPoint(x: 0, y: 0)
          gradient.endPoint = CGPoint(x: 1, y: 1)
          gradient.frame = view.bounds
          
          // Clean old layers if you hot-reload
          view.layer.sublayers?
              .filter { $0 is CAGradientLayer }
              .forEach { $0.removeFromSuperlayer() }
          
          view.layer.insertSublayer(gradient, at: 0)
          gradientLayer = gradient
      }
      
      private func updateGradientFrame() {
          gradientLayer?.frame = view.bounds
      }
    
    // MARK: - UI SETUP
    private func setupUI() {
           emailTextField.keyboardType = .emailAddress
           emailTextField.autocapitalizationType = .none
           emailTextField.delegate = self

           passwordTextField.isSecureTextEntry = true
           passwordTextField.delegate = self

           let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tap)
       }

       private func setupActivityIndicator() {
           activityIndicator = UIActivityIndicatorView(style: .large)
           activityIndicator.color = .white
           activityIndicator.center = view.center
           activityIndicator.hidesWhenStopped = true
           view.addSubview(activityIndicator)
       }

       @objc private func dismissKeyboard() {
           view.endEditing(true)
       }
    
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespaces),
                      !email.isEmpty,
                      let password = passwordTextField.text,
                      !password.isEmpty else {
                    showAlert(message: "Please enter email and password")
                    return
                }

                guard isValidEmail(email) else {
                    showAlert(message: "Enter a valid email address")
                    return
                }

                signIn(email: email, password: password)

    }
    
    
    @IBAction func forgetPasswordButtonTapped(_ sender: UIButton) {
        showResetPasswordAlert()
        
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
               navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    
    
    @IBAction func facebookLoginTapped(_ sender: UIButton) {
        showAlert(message: "facebook Sign In coming soon")
    }
    
    
    
    @IBAction func instagramLoginTapped(_ sender: UIButton) {
        showAlert(message: "instagram Sign In coming soon")
    }
    
    
    @IBAction func appleLoginTapped(_ sender: UIButton) {
        showAlert(message: "Apple Sign In coming soon")
    }
    
    
    
    @IBAction func googleLoginTapped(_ sender: UIButton) {
        
        showAlert(message: "Google Sign In coming soon")
    }
    
    // MARK: - SUPABASE LOGIN
        private func signIn(email: String, password: String) {
            showLoading(true)
            disableUI()

            Task {
                do {
                    // Use the single global client 'supabase'
                    // The SDK returns a session/object depending on the version; we don't rely on concrete type here
                    let _ = try await supabase.auth.signIn(
                        email: email,
                        password: password
                    )

                    await MainActor.run {
                        showLoading(false)
                        enableUI()
                        navigateToHome()
                    }
                } catch {
                    await MainActor.run {
                        showLoading(false)
                        enableUI()
                        handleAuthError(error)
                    }
                }
            }
        }

        // MARK: - RESET PASSWORD
        private func showResetPasswordAlert() {
            let alert = UIAlertController(title: "Reset Password",
                                          message: "Enter your email",
                                          preferredStyle: .alert)

            alert.addTextField { tf in
                tf.placeholder = "Email"
                tf.keyboardType = .emailAddress
                tf.autocapitalizationType = .none
            }

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
                guard let email = alert.textFields?.first?.text, !email.isEmpty else { return }
                self?.resetPassword(email: email)
            })

            present(alert, animated: true)
        }

        private func resetPassword(email: String) {
            guard isValidEmail(email) else {
                showAlert(message: "Invalid email")
                return
            }

            showLoading(true)

            Task {
                do {
                    // Preferred call in many SDK versions:
                    try await supabase.auth.resetPasswordForEmail(email)
                    // If Xcode complains, try autocomplete—some SDK versions use:
                    // try await supabase.auth.resetPassword(email)
                    // or
                    // try await supabase.auth.api.resetPasswordForEmail(email)

                    await MainActor.run {
                        showLoading(false)
                        showAlert(title: "Check Email", message: "We sent you a reset password link.")
                    }
                } catch {
                    await MainActor.run {
                        showLoading(false)
                        showAlert(message: "Failed to send reset email")
                    }
                }
            }
        }

        // MARK: - NAVIGATION
    private func navigateToHome() {
        let tabBarVC = CineMystTabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true)
    }


        // MARK: - ERROR HANDLING
        private func handleAuthError(_ error: Error) {
            let message: String
            if let supabaseError = error as? AuthError {
                message = supabaseError.localizedDescription
            } else {
                message = error.localizedDescription
            }
            showAlert(message: message)
        }

        // MARK: - HELPERS
        private func isValidEmail(_ email: String) -> Bool {
            let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
        }

        private func showLoading(_ show: Bool) {
            show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }

        private func disableUI() {
            view.isUserInteractionEnabled = false
        }

        private func enableUI() {
            view.isUserInteractionEnabled = true
        }

        private func showAlert(title: String = "CineMyst", message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - TEXTFIELD DELEGATE
    extension LoginViewController: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == emailTextField {
                passwordTextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
                signInButtonTapped(signInButton)
            }
            return true
        }
    }
