import Foundation
import StoreKit
import UIKit

class ReviewManager {
    static let shared = ReviewManager()
    
    private let appLaunchCountKey = "appLaunchCount"
    private let reviewRequestedKey = "reviewRequested"
    
    private init() {}
    
    // MARK: - Track App Launch
    func trackAppLaunch() {
        let currentCount = UserDefaults.standard.integer(forKey: appLaunchCountKey)
        UserDefaults.standard.set(currentCount + 1, forKey: appLaunchCountKey)
    }
    
    // MARK: - Check if Review Should Be Requested
    func shouldRequestReview(
        onboardingCompleted: Bool,
        hasOpenedProgressView: Bool = false,
        hasCompletedCheckIn: Bool = false
    ) -> Bool {
        // Check if onboarding is completed
        guard onboardingCompleted else { return false }
        
        // Check if user has opened ProgressView or completed a check-in
        guard hasOpenedProgressView || hasCompletedCheckIn else { return false }
        
        // Check if app has been launched at least 2 times
        let launchCount = UserDefaults.standard.integer(forKey: appLaunchCountKey)
        guard launchCount >= 2 else { return false }
        
        // Check if review has never been requested before
        let reviewRequested = UserDefaults.standard.bool(forKey: reviewRequestedKey)
        guard !reviewRequested else { return false }
        
        return true
    }
    
    // MARK: - Request Review
    func requestReviewIfNeeded(
        onboardingCompleted: Bool,
        hasOpenedProgressView: Bool = false,
        hasCompletedCheckIn: Bool = false
    ) {
        guard shouldRequestReview(
            onboardingCompleted: onboardingCompleted,
            hasOpenedProgressView: hasOpenedProgressView,
            hasCompletedCheckIn: hasCompletedCheckIn
        ) else {
            return
        }
        
        // Mark as requested
        UserDefaults.standard.set(true, forKey: reviewRequestedKey)
        
        // Request review on main thread
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    
    // MARK: - Reset (for testing purposes)
    func reset() {
        UserDefaults.standard.removeObject(forKey: appLaunchCountKey)
        UserDefaults.standard.removeObject(forKey: reviewRequestedKey)
    }
}
