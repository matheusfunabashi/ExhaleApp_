import SwiftUI

struct QuestView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: QuestCategory? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header with XP and level
                    HeaderSection()
                    
                    // Category filter
                    CategoryFilterSection(selectedCategory: $selectedCategory)
                    
                    // Active quests
                    ActiveQuestsSection(selectedCategory: selectedCategory)
                    
                    // Completed quests today
                    CompletedQuestsSection()
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Quests")
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.05), Color.pink.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct HeaderSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(appState.statistics.currentLevel)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("\(appState.statistics.totalXP) XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: xpProgress,
                    total: 100,
                    color: .orange
                )
                .frame(width: 60, height: 60)
            }
            
            // XP progress bar
            SwiftUI.ProgressView(value: xpProgress, total: 100.0)
                .progressViewStyle(.linear)
                .tint(.orange)
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("\(Int(100 - xpProgress)) XP to next level")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 5)
        )
    }
    
    private var xpProgress: Double {
        let currentLevelXP = (appState.statistics.currentLevel - 1) * 100
        let progressInCurrentLevel = appState.statistics.totalXP - currentLevelXP
        return Double(progressInCurrentLevel)
    }
}

struct CategoryFilterSection: View {
    @Binding var selectedCategory: QuestCategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Categories")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryChip(
                        title: "All",
                        icon: "list.bullet",
                        color: .gray,
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(QuestCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            title: category.rawValue.capitalized,
                            icon: category.icon,
                            color: category.color,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.2) : Color.gray.opacity(0.1))
                    .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(isSelected ? color : .secondary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActiveQuestsSection: View {
    @EnvironmentObject var appState: AppState
    let selectedCategory: QuestCategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Quests")
                .font(.headline)
                .fontWeight(.semibold)
            
            if filteredActiveQuests.isEmpty {
                EmptyQuestsView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredActiveQuests) { quest in
                        QuestCard(quest: quest)
                    }
                }
            }
        }
    }
    
    private var filteredActiveQuests: [Quest] {
        let activeQuests = appState.activeQuests.filter { !$0.isCompleted }
        
        if let category = selectedCategory {
            return activeQuests.filter { $0.category == category }
        }
        
        return activeQuests
    }
}

struct CompletedQuestsSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Completed Today")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(completedQuests.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            if completedQuests.isEmpty {
                Text("No quests completed yet today")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(completedQuests) { quest in
                        QuestCard(quest: quest)
                    }
                }
            }
        }
    }
    
    private var completedQuests: [Quest] {
        let today = Calendar.current.startOfDay(for: Date())
        return appState.activeQuests.filter { quest in
            quest.isCompleted && Calendar.current.isDate(quest.dateAssigned, inSameDayAs: today)
        }
    }
}

struct QuestCard: View {
    let quest: Quest
    @EnvironmentObject var appState: AppState
    @State private var showCompletionAnimation = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Category icon
            ZStack {
                Circle()
                    .fill(quest.category.color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: quest.category.icon)
                    .foregroundColor(quest.category.color)
                    .font(.title3)
            }
            
            // Quest content
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .strikethrough(quest.isCompleted)
                
                Text(quest.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("+\(quest.xpReward) XP")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text(quest.category.rawValue.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(quest.category.color.opacity(0.1))
                        )
                        .foregroundColor(quest.category.color)
                }
            }
            
            Spacer()
            
            // Complete button or checkmark
            if quest.isCompleted {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                        .scaleEffect(showCompletionAnimation ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCompletionAnimation)
                    
                    Text("Done!")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            } else {
                Button(action: {
                    completeQuest()
                }) {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .stroke(quest.isCompleted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
                .shadow(radius: quest.isCompleted ? 0 : 5)
        )
        .opacity(quest.isCompleted ? 0.8 : 1.0)
        .scaleEffect(quest.isCompleted ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: quest.isCompleted)
    }
    
    private func completeQuest() {
        appState.completeQuest(quest.id)
        showCompletionAnimation = true
        
        // Reset animation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showCompletionAnimation = false
        }
    }
}

struct EmptyQuestsView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "target")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No quests available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Check back tomorrow for new challenges!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct CircularProgressView: View {
    let progress: Double
    let total: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress / total)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)
            
            VStack {
                Text("\(Int(progress))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text("XP")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    QuestView()
        .environmentObject(AppState())
}
