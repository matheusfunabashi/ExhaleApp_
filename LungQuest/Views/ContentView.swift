import SwiftUI
import SuperwallKit
import Combine

// Simple shared tab coordinator to keep programmatic tab changes in sync.
final class TabNavigationManager: ObservableObject {
    static let shared = TabNavigationManager()
    @Published var selectedTab: Int = 0
    private init() {}
    
    func switchToTab(_ index: Int) {
        selectedTab = max(0, min(index, 3))
    }
    
    func switchToLearnTab() {
        switchToTab(1)
    }
    
    func switchToProgressTab() {
        switchToTab(2)
    }
}

struct ContentView: View {
    @EnvironmentObject var flowManager: AppFlowManager
    @EnvironmentObject var dataStore: AppDataStore
    
    var body: some View {
        Group {
            if flowManager.isLoading {
                LoadingView()
            } else if flowManager.isOnboarding {
                OnboardingView(onSkipAll: { name, age in
                    flowManager.completeOnboarding(name: name, age: age)
                })
                .environmentObject(flowManager)
                .environmentObject(dataStore)
            } else if flowManager.isSubscribed {
                MainTabView()
                    .environmentObject(flowManager)
                    .environmentObject(dataStore)
            } else {
                PaywallGateView()
                    .environmentObject(flowManager)
                    .environmentObject(dataStore)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: flowManager.isOnboarding)
        .animation(.easeInOut(duration: 0.3), value: flowManager.isLoading)
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            Image("LungBuddy_100")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 96)
                .scaleEffect(isAnimating ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedTab: Int = 0
    @State private var showPanic: Bool = false
    
    var body: some View {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                LearningView()
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Learn")
                    }
                    .tag(1)
                
                ProgressView()
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Progress")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(3)
            }
        .accentColor(Color(red: 0.45, green: 0.72, blue: 0.99))
        .onAppear {
            selectedTab = TabNavigationManager.shared.selectedTab
        }
        .onReceive(TabNavigationManager.shared.$selectedTab) { newTab in
            if selectedTab != newTab {
                withAnimation(.interactiveSpring()) {
                    selectedTab = newTab
                }
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            if TabNavigationManager.shared.selectedTab != newValue {
                TabNavigationManager.shared.selectedTab = newValue
            }
        }
        .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    PanicButton { showPanic = true }
                    Spacer()
                }
            .padding(.bottom, 8)
            .background(Color.clear)
            .allowsHitTesting(true)
        }
        .fullScreenCover(isPresented: $showPanic) {
            PanicHelpView(isPresented: $showPanic)
        }
        // Swipe between tabs with animated transition.
        .simultaneousGesture(
            DragGesture(minimumDistance: 15)
                .onEnded { value in
                    let threshold: CGFloat = 40
                    if value.translation.width < -threshold {
                        let next = min(selectedTab + 1, 3)
                        if next != selectedTab {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedTab = next
                            }
                        }
                    } else if value.translation.width > threshold {
                        let prev = max(selectedTab - 1, 0)
                        if prev != selectedTab {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedTab = prev
                            }
                        }
                    }
                }
        )
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

#Preview {
    let store = AppDataStore()
    let flow = AppFlowManager(dataStore: store)
    return ContentView()
        .environmentObject(flow)
        .environmentObject(store)
}

struct PaywallGateView: View {
    @EnvironmentObject var flowManager: AppFlowManager
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.blue)
            Text("Unlock Exhale Premium")
                .font(.title2.weight(.semibold))
            Text("Subscribe to continue past onboarding.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 12) {
                Button(action: {
                    Superwall.shared.register(placement: "onboarding_end")
                }) {
                    Text("Show Paywall")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    SubscriptionManager.shared.refresh()
                }) {
                    Text("Restore Purchases")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding()
    }
}
