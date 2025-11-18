import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isLoading {
                LoadingView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isOnboarding)
        .animation(.easeInOut(duration: 0.3), value: appState.isLoading)
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            LungShape(healthLevel: 50)
                .frame(width: 100, height: 80)
                .foregroundColor(.pink.opacity(0.7))
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            
            Text("LungQuest")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Loading your progress...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPanic: Bool = false
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            if appState.isOnboarding {
                IntakeView()
                    .environmentObject(appState)
            } else if !appState.isSubscribed {
                IntakeView()
                    .environmentObject(appState)
                    .onAppear {
                        // If questionnaire is completed, immediately show paywall
                        if appState.questionnaire.isCompleted {
                            // Present paywall on first render using fullScreenCover from parent
                        }
                    }
            } else {
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
                .accentColor(Color(red: 0.16, green: 0.36, blue: 0.87))
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("SwitchToLearnTab"))) { _ in
                    selectedTab = 1
                }
            
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        PanicButton { showPanic = true }
                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
                .allowsHitTesting(true)
            }
        }
        .fullScreenCover(isPresented: $showPanic) {
            PanicHelpView(isPresented: $showPanic)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

