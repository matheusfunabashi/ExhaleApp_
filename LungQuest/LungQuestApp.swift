import SwiftUI

@main
struct LungQuestApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // No-op init. Firebase intentionally disabled for MVP frontend-only build.
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
