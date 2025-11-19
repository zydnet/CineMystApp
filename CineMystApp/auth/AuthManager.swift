//
//  AuthManager.swift
//  CineMystApp
//
//  Created by user@50 on 19/11/25.
//

// AuthManager.swift
// CineMystApp
//
// Minimal wrapper around the official `supabase` global client.
// Avoids depending on internal SDK type names so it compiles across SDK versions.

import Foundation
import Supabase

final class AuthManager {
    static let shared = AuthManager()
    private init() {}

    // Use the single global client you defined in Supabase.swift
    private var client: SupabaseClient { supabase }

    // MARK: - Sign Up
    /// May send confirmation email depending on your project settings.
    func signUp(email: String, password: String, redirectTo: URL? = nil) async throws {
        if let redirect = redirectTo {
            try await client.auth.signUp(email: email, password: password, redirectTo: redirect)
        } else {
            try await client.auth.signUp(email: email, password: password)
        }
    }

    // MARK: - Sign In
    /// Sign in with email/password. The SDK returns a session or nothing depending on project settings.
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    // MARK: - Passwordless / Magic Link (OTP)
    func signInWithMagicLink(email: String, redirectTo: URL? = nil) async throws {
        if let redirect = redirectTo {
            try await client.auth.signInWithOTP(email: email, redirectTo: redirect)
        } else {
            try await client.auth.signInWithOTP(email: email)
        }
    }

    // MARK: - Reset Password (send email)
    func resetPassword(email: String) async throws {
        // Preferred public API:
        try await client.auth.resetPasswordForEmail(email)
    }

    // MARK: - Sign Out
    func signOut() async throws {
        try await client.auth.signOut()
    }

    // MARK: - Current user/session (read-only helpers)
    var currentUser: User? {
        client.auth.currentUser
    }

    // If you need to access the session async (some SDK versions have session as async property)
    func currentSession() async throws -> Session? {
        // Note: this `session` accessor may be async in the version you have.
        // If your SDK exposes a synchronous `client.auth.session` remove `await`.
        return try await client.auth.session
    }

    // MARK: - Auth state listening
    /// Post a NotificationCenter notification when auth state changes.
    /// We store the subscription as `Any` to avoid referencing internal subscription types.
    private var subscriptionStorage: Any?

    func startListening() {
        Task {
            // `onAuthStateChange` is an async factory that returns a subscription object in many SDK versions.
            // We intentionally accept the returned subscription as `Any` to avoid compile-time coupling.
            let subs = await client.auth.onAuthStateChange { event, session in
                NotificationCenter.default.post(name: .authStateChanged,
                                                object: nil,
                                                userInfo: ["event": event, "session": session as Any])
            }
            self.subscriptionStorage = subs
        }
    }

    func stopListening() {
        // If you want to unsubscribe you can attempt to call `subscription.remove()` or similar using reflection,
        // but exact unsubscribe API differs by SDK. For most apps letting it be is fine for simple flows.
        subscriptionStorage = nil
    }
}

extension Notification.Name {
    static let authStateChanged = Notification.Name("AuthManager.authStateChanged")
}
