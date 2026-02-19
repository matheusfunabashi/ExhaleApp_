import SwiftUI
import SuperwallKit
import UserNotifications

@main
struct ExhaleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var dataStore: AppDataStore
    @StateObject private var flowManager: AppFlowManager
    
    init() {
        // Configure Superwall
        Superwall.configure(apiKey: "pk_632iyoKuponK4hKuK_GL9")
        
        let store = AppDataStore()
        _dataStore = StateObject(wrappedValue: store)
        
        let flow = AppFlowManager(dataStore: store)
        _flowManager = StateObject(wrappedValue: flow)
        
        // Set Superwall delegate to track subscription status
        Superwall.shared.delegate = SuperwallDelegateHandler.shared
        SuperwallDelegateHandler.shared.flowManager = flow
        
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

/// Handles Superwall events and updates AppFlowManager
final class SuperwallDelegateHandler: SuperwallDelegate {
    static let shared = SuperwallDelegateHandler()
    weak var flowManager: AppFlowManager?
    
    private init() {}
    
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .transactionComplete:
            // User completed a purchase
            flowManager?.setSubscription(active: true)
            flowManager?.dismissPaywall()
        case .paywallClose:
            // User closed paywall - check if they subscribed
            Task { @MainActor in
                await flowManager?.subscriptionManager.refreshEntitlements()
            }
        default:
            break
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
