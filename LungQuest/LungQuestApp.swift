import SwiftUI
import SuperwallKit

@main
struct LungQuestApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        Superwall.configure(apiKey: "pk_632iyoKuponK4hKuK_GL9")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
