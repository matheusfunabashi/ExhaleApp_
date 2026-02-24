import SwiftUI
import SuperwallKit
import Combine
import Network

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @MainActor @Published private(set) var isOnline: Bool = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}

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
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var flowManager: AppFlowManager
    @EnvironmentObject var dataStore: AppDataStore
    @State private var lastEntitlementRefreshAt: Date = .distantPast
    
    /// Controls when to show the fallback PaywallGateView.
    /// Only shows if: no internet, Superwall failed, or user closed paywall without subscribing.
    @State private var shouldShowFallbackGate: Bool = false
    @State private var hasAttemptedPaywallPresentation: Bool = false
    
    /// CRITICAL: Prevents content flash before Superwall evaluates.
    /// Keeps app on loading screen until Superwall either shows paywall or confirms user is subscribed.
    @State private var isPaywallResolved: Bool = false
    
    var body: some View {
        ZStack {
            Group {
                if flowManager.isLoading {
                    LoadingView()
                } else if flowManager.isOnboarding {
                    OnboardingView(onSkipAll: { name, age, weeklyCost, currency in
                        flowManager.completeOnboarding(name: name, age: age, weeklyCost: weeklyCost, currency: currency)
                    })
                    .environmentObject(flowManager)
                    .environmentObject(dataStore)
                } else if !isPaywallResolved {
                    // CRITICAL FIX: Show loading screen until Superwall resolves
                    // Prevents flash of HomeView before paywall appears
                    LoadingView()
                } else {
                    MainTabView()
                        .environmentObject(flowManager)
                        .environmentObject(dataStore)
                }
            }
            .modifier(ResponsiveContentWidth())
            .animation(.easeInOut(duration: 0.3), value: flowManager.isOnboarding)
            .animation(.easeInOut(duration: 0.3), value: flowManager.isLoading)
            
            // CRITICAL FIX: Only show PaywallGateView as fallback, not immediately.
            // Superwall paywall should appear directly without showing this gate first.
            if !flowManager.isOnboarding && flowManager.accessState != .subscribed && shouldShowFallbackGate {
                PaywallGateView(onDismiss: {
                    shouldShowFallbackGate = false
                })
                    .environmentObject(flowManager)
                    .environmentObject(dataStore)
                    .transition(.opacity)
                    .zIndex(1000)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            // Refresh entitlements on foreground so expirations are detected even without new transactions.
            let now = Date()
            if now.timeIntervalSince(lastEntitlementRefreshAt) < 20 { return }
            lastEntitlementRefreshAt = now
            flowManager.subscriptionManager.refresh()
        }
        .onChange(of: flowManager.isOnboarding) { _, isOnboarding in
            if !isOnboarding {
                handlePostOnboardingPaywall()
            }
        }
        .onChange(of: flowManager.accessState) { _, newState in
            // If user is already subscribed, allow immediate access
            if newState == .subscribed {
                isPaywallResolved = true
            } else if newState == .notSubscribed && !flowManager.isOnboarding && !hasAttemptedPaywallPresentation {
                handlePostOnboardingPaywall()
            }
        }
    }
    
    /// Attempts to present Superwall paywall directly without showing gate UI.
    /// Uses PaywallPresentationHandler to know when Superwall has made its decision.
    /// Only shows content after Superwall resolves (shows paywall, user dismisses, or user is subscribed).
    private func handlePostOnboardingPaywall() {
        guard !hasAttemptedPaywallPresentation else { return }
        guard flowManager.accessState != .subscribed else {
            isPaywallResolved = true
            return
        }
        
        hasAttemptedPaywallPresentation = true
        
        print("🚀 [CONTENTVIEW] Presenting Superwall with handler to prevent content flash")
        
        // Create handler to track when Superwall resolves
        let handler = PaywallPresentationHandler()
        
        handler.onPresent { paywallInfo in
            print("✅ [SUPERWALL] Paywall presented - user will see paywall")
        }
        
        handler.onDismiss { paywallInfo, paywallResult in
            print("👋 [SUPERWALL] Paywall dismissed with result: \(paywallResult)")
            
            // CRITICAL FIX: Multi-layer defense against TestFlight race condition
            Task { @MainActor in
                // Layer 1: Check if purchase JUST completed via delegate
                // This catches the happy path where .transactionComplete fired before .onDismiss
                if SuperwallDelegateHandler.justCompletedPurchase {
                    print("✅ [SUPERWALL] Purchase flag set - user subscribed (instant access)")
                    SuperwallDelegateHandler.justCompletedPurchase = false
                    isPaywallResolved = true
                    return
                }
                
                // Layer 2: Poll accessState multiple times with delays
                // This handles race conditions in TestFlight where state updates are slower
                print("🔍 [SUPERWALL] Polling subscription state (up to 6 attempts over 3 seconds)")
                
                for attempt in 1...6 {
                    // Check if subscribed
                    if flowManager.accessState == .subscribed {
                        print("✅ [SUPERWALL] User subscribed detected on attempt \(attempt)")
                        isPaywallResolved = true
                        return
                    }
                    
                    // Check purchase flag again (in case .transactionComplete is delayed)
                    if SuperwallDelegateHandler.justCompletedPurchase {
                        print("✅ [SUPERWALL] Purchase flag detected on attempt \(attempt)")
                        SuperwallDelegateHandler.justCompletedPurchase = false
                        isPaywallResolved = true
                        return
                    }
                    
                    // Wait before next attempt (exponential backoff)
                    let delay: UInt64 = attempt <= 3 ? 300_000_000 : 600_000_000 // 300ms then 600ms
                    try? await Task.sleep(nanoseconds: delay)
                }
                
                // Layer 3: Final check after all attempts
                // If we still don't see .subscribed after 3+ seconds, user likely closed without purchasing
                if flowManager.accessState == .subscribed || SuperwallDelegateHandler.justCompletedPurchase {
                    print("✅ [SUPERWALL] User subscribed (final check)")
                    SuperwallDelegateHandler.justCompletedPurchase = false
                    isPaywallResolved = true
                } else {
                    print("⚠️ [SUPERWALL] User closed without subscribing after \(6) attempts - showing fallback gate")
                    shouldShowFallbackGate = true
                    // Don't set isPaywallResolved - keep on loading screen with gate overlay
                }
            }
        }
        
        handler.onError { error in
            print("❌ [SUPERWALL] Error: \(error.localizedDescription)")
            // On error, show fallback gate after delay
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if flowManager.accessState != .subscribed {
                    shouldShowFallbackGate = true
                }
            }
        }
        
        handler.onSkip { skipReason in
            print("⏭️ [SUPERWALL] Paywall skipped: \(skipReason.description)")
            // Paywall was skipped (e.g., user already subscribed, holdout, etc.)
            Task { @MainActor in
                if flowManager.accessState == .subscribed {
                    isPaywallResolved = true
                } else {
                    // Shouldn't happen, but show fallback if needed
                    shouldShowFallbackGate = true
                }
            }
        }
        
        // Present paywall with handler
        Superwall.shared.register(placement: "onboarding_end", handler: handler)
    }
}

private struct PaywallGateView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var flowManager: AppFlowManager
    @StateObject private var network = NetworkMonitor.shared
    @State private var lastAttemptAt: Date = .distantPast
    
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Exhale Premium")
                    .font(.title2.weight(.semibold))
                
                switch flowManager.accessState {
                case .unknown:
                    ProgressView()
                    Text("Checking your subscription…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                case .notSubscribed:
                    if network.isOnline {
                        ProgressView()
                        Text("Loading paywall…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Show paywall") { 
                            attemptPaywall(force: true)
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("Requires connection")
                            .font(.headline)
                        Text("Connect to the internet to load the paywall and continue.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        Button("Retry") { 
                            attemptPaywall(force: true)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!network.isOnline)
                    }
                    
                case .subscribed:
                    EmptyView()
                }
                
                Button("Restore Purchases") {
                    Task { @MainActor in
                        await flowManager.subscriptionManager.refreshEntitlements()
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 24)
        }
        .onAppear {
            attemptPaywall(force: false)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                attemptPaywall(force: false)
            }
        }
        .onChange(of: network.isOnline) { _, isOnline in
            if isOnline {
                attemptPaywall(force: false)
            }
        }
        .onChange(of: flowManager.accessState) { _, newState in
            if newState == .subscribed {
                onDismiss()
            } else if newState == .notSubscribed {
                attemptPaywall(force: false)
            }
        }
    }
    
    private func attemptPaywall(force: Bool) {
        guard flowManager.accessState == .notSubscribed else { return }
        guard network.isOnline else { return }
        
        let now = Date()
        if !force, now.timeIntervalSince(lastAttemptAt) < 10 {
            return
        }
        lastAttemptAt = now
        
        Superwall.shared.register(placement: "onboarding_end")
    }
}

// MARK: - iPad-responsive layout (iPhone unchanged)
/// On wide screens (e.g. iPad, width > 600pt), constrains content to max 600pt and centers it.
/// On iPhone, content uses full width with no visual change.
/// Uses @State to cache isWide calculation and avoid repeated GeometryReader evaluations.
private struct ResponsiveContentWidth: ViewModifier {
    @State private var isWide: Bool = false
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .frame(maxWidth: isWide ? 600 : .infinity)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, isWide ? 24 : 0)
                .onAppear {
                    isWide = geo.size.width > 600
                }
                .onChange(of: geo.size) { _, newSize in
                    let newIsWide = newSize.width > 600
                    if newIsWide != isWide {
                        isWide = newIsWide
                    }
                }
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
    /// Ensures tab bar is fully rendered and hit-testable before adding overlays.
    /// Fixed: use double-async + delay to guarantee UITabBar layout completion on all devices.
    @State private var tabBarReadyForInset: Bool = false

    var body: some View {
        tabViewContent
        .modifier(ConditionalSafeAreaInset(apply: tabBarReadyForInset, spacing: 6, content: { panicButtonInset }))
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
            // CRITICAL FIX: Double-async + minimal delay ensures TabView AND UITabBar are fully rendered
            // before applying safeAreaInset. Single async is insufficient on slower devices.
            // This guarantees the UITabBar is in the responder chain and can receive touches.
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    tabBarReadyForInset = true
                }
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
        // CRITICAL: Ensure this view never intercepts tab bar touches
        .allowsHitTesting(true)
        // Ensure proper z-ordering so tab bar is always on top
        .zIndex(-1)
    }
}

// MARK: - Deferred safe area inset (lifecycle fix for tab bar touches)
/// Applies safe area inset only when `apply` is true. Used so the tab bar is laid out and
/// hit-testable before the inset view is added, avoiding first-launch tap failures.
/// The inset content is explicitly placed behind the tab bar (zIndex -1) to never intercept touches.
private struct ConditionalSafeAreaInset<InsetContent: View>: ViewModifier {
    let apply: Bool
    let spacing: CGFloat
    @ViewBuilder let content: () -> InsetContent

    func body(content: Content) -> some View {
        if apply {
            content
                .safeAreaInset(edge: .bottom, spacing: spacing) {
                    self.content()
                        // Ensure inset content never blocks tab bar touches
                        .zIndex(-10)
                }
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

