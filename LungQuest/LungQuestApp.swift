import SwiftUI
import SuperwallKit
import UserNotifications

/// Listens to Superwall events and updates app subscription state immediately on purchase completion.
final class SuperwallDelegateHandler: SuperwallDelegate {
    static let shared = SuperwallDelegateHandler()
    private init() {}
    
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .transactionComplete:
            // Unlock immediately, then verify via StoreKit entitlements in the background.
            Task { @MainActor in
                SubscriptionManager.shared.markSubscribedOptimistically()
            }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 500_000_000) // allow receipt/entitlements to update
                await SubscriptionManager.shared.refreshEntitlements()
            }
        case .paywallClose:
            // Refresh after closing in case user completed or restored elsewhere.
            Task { @MainActor in
                await SubscriptionManager.shared.refreshEntitlements()
            }
        default:
            break
        }
    }
}

@main
struct ExhaleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var dataStore: AppDataStore
    @StateObject private var flowManager: AppFlowManager
    
    init() {
        Superwall.configure(apiKey: "pk_632iyoKuponK4hKuK_GL9")
        Superwall.shared.delegate = SuperwallDelegateHandler.shared
        let store = AppDataStore()
        _dataStore = StateObject(wrappedValue: store)
        _flowManager = StateObject(wrappedValue: AppFlowManager(dataStore: store))
        
        // Track app launch for review prompt
        ReviewManager.shared.trackAppLaunch()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(flowManager)
                .environmentObject(dataStore)
                .preferredColorScheme(.light) // Force light mode
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        center.removeAllDeliveredNotifications()
        completionHandler()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
