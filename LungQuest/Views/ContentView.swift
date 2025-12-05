import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isLoading {
                LoadingView()
            } else if appState.isOnboarding {
                OnboardingView(onSkipAll: { name, age in
                    appState.completeOnboarding(name: name, age: age)
                })
                .environmentObject(appState)
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
            .overlay(
                HStack {
                    Spacer()
                    PanicButton { showPanic = true }
                    Spacer()
                }
                .padding(.bottom, 24),
                alignment: .bottom
            )
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

