import SwiftUI

struct LearningView: View {
    @EnvironmentObject var appState: AppState
    
    private var topics: [LearningTopic] {
        [
            LearningTopic(
                kind: .physical,
                title: "Physical health",
                blurb: "Understand how your body heals from the inside out.",
                accent: .green,
                lessons: [
                    Lesson(title: "Oxygen rebound", summary: "How blood oxygen and heart rate improve within 24 hours.", durationMinutes: 2, icon: "lungs.fill"),
                    Lesson(title: "Lung repair timeline", summary: "Daily milestones as cilia and lung capacity return.", durationMinutes: 3, icon: "waveform.path.ecg"),
                    Lesson(title: "Movement that supports healing", summary: "Gentle routines that open your chest and calm cravings.", durationMinutes: 2, icon: "figure.walk")
                ]
            ),
            LearningTopic(
                kind: .mental,
                title: "Mental resilience",
                blurb: "Build calm habits and mindset shifts for the long term.",
                accent: Color(red: 0.67, green: 0.52, blue: 0.93),
                lessons: [
                    Lesson(title: "Urge surfing", summary: "Ride cravings with mindful breathing in under two minutes.", durationMinutes: 2, icon: "wind"),
                    Lesson(title: "Rewrite the story", summary: "Reframe slips with compassionate language and intention.", durationMinutes: 3, icon: "quote.bubble"),
                    Lesson(title: "Micro-celebrations", summary: "Celebrate tiny wins to anchor motivation each day.", durationMinutes: 2, icon: "sparkles")
                ]
            ),
            LearningTopic(
                kind: .lifestyle,
                title: "Lifestyle & triggers",
                blurb: "Swap routines and prepare for the moments that matter.",
                accent: Color(red: 0.85, green: 0.32, blue: 0.57),
                lessons: [
                    Lesson(title: "Morning rituals", summary: "Start the day grounded to reduce cravings later on.", durationMinutes: 2, icon: "sunrise.fill"),
                    Lesson(title: "Social support toolkit", summary: "Ask for what you need from friends without pressure.", durationMinutes: 2, icon: "person.2.fill"),
                    Lesson(title: "Evening unwinding", summary: "Wind down without the vape—sleep-friendly swaps.", durationMinutes: 3, icon: "moon.stars.fill")
                ]
            )
        ]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 22) {
                    ForEach(topics) { topic in
                        LearningTopicCard(
                            topic: topic,
                            progress: progressValue(for: topic),
                            encouragement: encouragement(for: topic)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Learn")
            .breathableBackground()
        }
    }
    
    private func progressValue(for topic: LearningTopic) -> Double {
        switch topic.kind {
        case .physical:
            return Double(appState.lungState.healthLevel) / 100.0
        case .mental:
            let cappedXP = min(Double(appState.statistics.totalXP), 400)
            return max(0, cappedXP / 400.0)
        case .lifestyle:
            let completed = Double(appState.statistics.completedQuests)
            return min(1.0, completed / 10.0)
        }
    }
    
    private func encouragement(for topic: LearningTopic) -> String {
        let progress = progressValue(for: topic)
        let percent = Int(progress * 100)
        switch topic.kind {
        case .physical:
            return percent >= 100 ? "Your body is flourishing—keep revisiting lessons when you need a refresher." : "You’re restoring each system—these lessons show what’s improving right now."
        case .mental:
            return percent >= 100 ? "Your mindset toolkit is shining. Re-read a favorite strategy when cravings whisper." : "Each read is another calm thought ready for the next craving."
        case .lifestyle:
            return percent >= 100 ? "Your routines are resilient—share a tip with someone you care about." : "Swap in one new ritual today and watch the momentum build."
        }
    }
}

private struct LearningTopicCard: View {
    let topic: LearningTopic
    let progress: Double
    let encouragement: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(topic.accent.opacity(0.18))
                        .frame(width: 54, height: 54)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(topic.accent.opacity(0.28), lineWidth: 1)
                        )
                    Image(systemName: topic.icon)
                        .foregroundColor(topic.accent)
                        .font(.title2)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(topic.title)
                        .font(.title3.weight(.semibold))
                    Text(topic.blurb)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 6) {
                        SwiftUI.ProgressView(value: progress)
                            .tint(topic.accent)
                            .frame(height: 4)
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(topic.lessons) { lesson in
                    LessonTile(lesson: lesson, accent: topic.accent)
                }
            }
            
            Text(encouragement)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(accent: topic.accent, cornerRadius: 30)
        .accessibilityElement(children: .combine)
    }
}

private struct LessonTile: View {
    let lesson: Lesson
    let accent: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.15))
                        .frame(width: 42, height: 42)
                        .overlay(
                            Circle()
                                .stroke(accent.opacity(0.25), lineWidth: 1)
                        )
                    Image(systemName: lesson.icon)
                        .foregroundColor(accent)
                        .font(.headline)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    Text(lesson.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        Label("\(lesson.durationMinutes) min read", systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(accent)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule()
                                    .fill(accent.opacity(0.12))
                            )
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.6))
        )
    }
}

private struct Lesson: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let durationMinutes: Int
    let icon: String
}

private struct LearningTopic: Identifiable {
    enum Kind { case physical, mental, lifestyle }
    let id = UUID()
    let kind: Kind
    let title: String
    let blurb: String
    let accent: Color
    let lessons: [Lesson]
    
    var icon: String {
        switch kind {
        case .physical: return "lungs.fill"
        case .mental: return "person.crop.circle.badge.checkmark"
        case .lifestyle: return "leaf.fill"
        }
    }
}

struct TipsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("A practical quitting plan")
                    .font(.title2)
                    .fontWeight(.bold)
                Group {
                    Text("1. Prepare")
                        .font(.headline)
                    Text("Pick a quit date, list your reasons, clear devices.")
                        .foregroundColor(.secondary)
                }
                Group {
                    Text("2. Replace")
                        .font(.headline)
                    Text("Carry water, sugar-free gum, and a fidget. Swap routines.")
                        .foregroundColor(.secondary)
                }
                Group {
                    Text("3. Respond to cravings")
                        .font(.headline)
                    Text("Try 4-7-8 breathing, 10 push-ups or a short walk, and a quick journal note.")
                        .foregroundColor(.secondary)
                }
                Group {
                    Text("4. Recover")
                        .font(.headline)
                    Text("Slip? Log it, learn your trigger, and continue. Progress over perfection.")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Tips to quit")
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    LearningView()
}












