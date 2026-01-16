import Foundation
import SwiftUI
import Combine

class TabNavigationManager: ObservableObject {
    static let shared = TabNavigationManager()
    
    @Published var selectedTab: Int = 0
    
    private init() {}
    
    func switchToTab(_ tab: Int) {
        DispatchQueue.main.async {
            self.selectedTab = tab
        }
    }
    
    func switchToLearnTab() {
        switchToTab(1)
    }
    
    func switchToProgressTab() {
        switchToTab(2)
    }
}

