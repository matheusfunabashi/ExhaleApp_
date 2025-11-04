import SwiftUI

struct LearningView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    LearningCard(
                        title: "Benefits of quitting",
                        icon: "heart.text.square.fill",
                        color: .green,
                        bullets: [
                            "Heart rate and blood pressure drop within 20 minutes",
                            "Oxygen levels improve in 24 hours",
                            "Lung function starts to recover in weeks",
                            "Energy, taste and smell rebound",
                            "Money saved adds up fast"
                        ]
                    )
                    
                    LearningCard(
                        title: "What vaping does",
                        icon: "lungs.fill",
                        color: .pink,
                        bullets: [
                            "Irritates airways and reduces lung capacity",
                            "Nicotine drives anxiety and cravings",
                            "Triggers inflammation and poor sleep",
                            "Can impact heart health"
                        ]
                    )
                    
                    LearningCard(
                        title: "Tips to quit",
                        icon: "lightbulb.fill",
                        color: .orange,
                        bullets: [
                            "Set a clear quit date and reasons",
                            "Use cravings routines: breathe, sip water, move",
                            "Replace triggers with healthy habits",
                            "Ask for support and track wins"
                        ],
                        footer: AnyView(
                            NavigationLink(destination: TipsDetailView()) {
                                Text("See detailed quitting plan")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.pink)
                            }
                        )
                    )
                }
                .padding()
            }
            .navigationTitle("Learn")
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.cyan.opacity(0.15), Color.blue.opacity(0.25)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct LearningCard: View {
    let title: String
    let icon: String
    let color: Color
    let bullets: [String]
    var footer: AnyView? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(bullets, id: \.self) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(color)
                            .font(.caption)
                        Text(item)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            if let footer = footer {
                Divider()
                footer
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
                .shadow(radius: 6)
        )
        .accessibilityElement(children: .combine)
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











