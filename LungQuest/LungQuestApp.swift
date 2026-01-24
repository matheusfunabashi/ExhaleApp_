import SwiftUI
import SuperwallKit

@main
struct ExhaleApp: App {
    @StateObject private var dataStore: AppDataStore
    @StateObject private var flowManager: AppFlowManager
    
    init() {
        Superwall.configure(apiKey: "pk_632iyoKuponK4hKuK_GL9")
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
