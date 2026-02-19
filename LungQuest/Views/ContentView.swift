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
                OnboardingView(onSkipAll: { name, age, weeklyCost, currency in
                    flowManager.completeOnboarding(name: name, age: age, weeklyCost: weeklyCost, currency: currency)
                })
                .environmentObject(flowManager)
                .environmentObject(dataStore)
            } else if flowManager.shouldShowPaywall {
                // Only show paywall when subscription state is definitively .inactive
                // Never show during .unknown (prevents race condition flashing)
                PaywallHostView()
                    .environmentObject(flowManager)
                    .environmentObject(dataStore)
            } else {
                MainTabView()
                    .environmentObject(flowManager)
                    .environmentObject(dataStore)
            }
        }
        .modifier(ResponsiveContentWidth())
        .animation(.easeInOut(duration: 0.3), value: flowManager.isOnboarding)
        .animation(.easeInOut(duration: 0.3), value: flowManager.isLoading)
        .animation(.easeInOut(duration: 0.3), value: flowManager.shouldShowPaywall)
    }
}

/// Dedicated view to host Superwall paywall presentation
private struct PaywallHostView: View {
    @EnvironmentObject var flowManager: AppFlowManager
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
        }
        .onAppear {
            // Trigger Superwall paywall immediately
            Superwall.shared.register(placement: "onboarding_end")
        }
    }
}

// MARK: - iPad-responsive layout (iPhone unchanged)
/// On wide screens (e.g. iPad, width > 600pt), constrains content to max 600pt and centers it.
/// On iPhone, content uses full width with no visual change.
private struct ResponsiveContentWidth: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geo in
            let isWide = geo.size.width > 600
            content
                .frame(maxWidth: isWide ? 600 : .infinity)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, isWide ? 24 : 0)
        }
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
    /// Defer safe area inset until after first layout so the tab bar is laid out and hit-testable first.
    /// Prevents first-launch / fresh-install bug where tab bar taps were blocked (inset view in hierarchy over tab bar).
    @State private var tabBarReadyForInset: Bool = false

    var body: some View {
        tabViewContent
        .accentColor(Color(red: 0.45, green: 0.72, blue: 0.99))
        .onAppear {
            selectedTab = TabNavigationManager.shared.selectedTab
            // Diagnostics: log hierarchy on appear and after delays to compare first launch vs later.
            if TabBarDiagnostics.enabled {
                TabBarDiagnostics.logHierarchy(label: "MainTabView.onAppear")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    TabBarDiagnostics.logHierarchy(label: "MainTabView +0.5s")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    TabBarDiagnostics.logHierarchy(label: "MainTabView +1.5s")
                }
            }
            // Lifecycle fix: apply safe area inset only after the TabView has completed its first layout.
            // This ensures the underlying UITabBar is in the hierarchy and hit-testable before we add the inset view.
            DispatchQueue.main.async {
                tabBarReadyForInset = true
            }
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
        .modifier(ConditionalSafeAreaInset(apply: tabBarReadyForInset, spacing: 6, content: { panicButtonInset }))
        .fullScreenCover(isPresented: $showPanic) {
            PanicHelpView(isPresented: $showPanic)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }

    private var tabViewContent: some View {
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
    }

    @ViewBuilder
    private var panicButtonInset: some View {
        HStack {
            Spacer()
            PanicButton { showPanic = true }
            Spacer()
        }
        .padding(.top, 14)
        .padding(.bottom, 18)
        .background(Color.clear)
    }
}

// MARK: - Deferred safe area inset (lifecycle fix for tab bar touches)
/// Applies safe area inset only when `apply` is true. Used so the tab bar is laid out and
/// hit-testable before the inset view is added, avoiding first-launch tap failures.
private struct ConditionalSafeAreaInset<InsetContent: View>: ViewModifier {
    let apply: Bool
    let spacing: CGFloat
    @ViewBuilder let content: () -> InsetContent

    func body(content: Content) -> some View {
        if apply {
            content
                .safeAreaInset(edge: .bottom, spacing: spacing, content: self.content)
        } else {
            content
        }
    }
}

#Preview {
    let store = AppDataStore()
    let flow = AppFlowManager(dataStore: store)
    return ContentView()
        .environmentObject(flow)
        .environmentObject(store)
}

