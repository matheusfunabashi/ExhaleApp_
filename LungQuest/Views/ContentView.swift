import SwiftUI

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
            } else {
                MainTabView()
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
    @EnvironmentObject var dataStore: AppDataStore
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
    let store = AppDataStore()
    let flow = AppFlowManager(dataStore: store)
    return ContentView()
        .environmentObject(flow)
        .environmentObject(store)
}

