import SwiftUI
import SuperwallKit
import UserNotifications

@main
struct ExhaleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var dataStore: AppDataStore
    @StateObject private var flowManager: AppFlowManager
    
    init() {
        Superwall.configure(apiKey: "pk_632iyoKuponK4hKuK_GL9")
        let store = AppDataStore()
        let flow = AppFlowManager(dataStore: store)
        _dataStore = StateObject(wrappedValue: store)
        _flowManager = StateObject(wrappedValue: flow)
        
        // Set up Superwall delegate to update subscription status
        Superwall.shared.delegate = SuperwallDelegateHandler(flowManager: flow)
        
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

// MARK: - Superwall Delegate
class SuperwallDelegateHandler: SuperwallDelegate {
    weak var flowManager: AppFlowManager?
    
    init(flowManager: AppFlowManager) {
        self.flowManager = flowManager
    }
    
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .transactionComplete:
            // User successfully subscribed
            Task { @MainActor in
                await SubscriptionManager.shared.refreshEntitlements()
                if SubscriptionManager.shared.isSubscribed {
                    flowManager?.setSubscription(active: true)
                }
            }
        case .transactionRestore:
            // User restored their subscription
            Task { @MainActor in
                await SubscriptionManager.shared.refreshEntitlements()
                if SubscriptionManager.shared.isSubscribed {
                    flowManager?.setSubscription(active: true)
                }
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
