import SwiftUI
import UIKit

struct IntakeView: View {
    @EnvironmentObject var appState: AppState
    
    // Profile inputs
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var age: String = ""
    @State private var yearsVaping: String = ""
    @State private var dailyCost: String = ""
    @State private var deviceType: String = "Pod System"
    private let deviceTypes = ["Pod System", "Disposable", "Box Mod", "Pen Vape", "Other"]
    
    // Questionnaire inputs
    @State private var answers: OnboardingQuestionnaire = OnboardingQuestionnaire()
    @State private var stepIndex: Int = 0
    @State private var showPaywall: Bool = false
    
    // 0: Welcome, 1: Personal, 2: Vaping, 3... questions
    private var totalSteps: Int { 3 + questions.count }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                IntakeProgressHeader(current: stepIndex + 1, total: totalSteps)
                
                Group { currentStepView }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
                Spacer(minLength: 8)
                
                HStack(spacing: 12) {
                    if stepIndex > 0 {
                        Button("Back") { withAnimation { stepIndex -= 1 } }
                            .buttonStyle(.bordered)
                    }
                    Button(stepIndex == totalSteps - 1 ? "Continue" : "Next") { advance() }
                        .buttonStyle(.borderedProminent)
                        .disabled(!isCurrentStepValid)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
                    .environmentObject(appState)
            }
        }
        .onAppear {
            answers = appState.questionnaire
        }
    }
    
    private var isCurrentStepValid: Bool {
        switch stepIndex {
        case 0: return true
        case 1: return !name.isEmpty
        case 2: return !yearsVaping.isEmpty && !dailyCost.isEmpty
        default: return true
        }
    }
    
    @ViewBuilder private var currentStepView: some View {
        switch stepIndex {
        case 0:
            IntakeWelcomeStep()
        case 1:
            IntakePersonalStep(name: $name, email: $email, age: $age)
        case 2:
            IntakeVapingStep(yearsVaping: $yearsVaping, dailyCost: $dailyCost, deviceType: $deviceType, deviceTypes: deviceTypes)
        default:
            let q = questions[stepIndex - 3]
            VStack(alignment: .leading, spacing: 16) {
                Text(q.title)
                    .font(.title2)
                    .fontWeight(.bold)
                if let subtitle = q.subtitle { Text(subtitle).foregroundColor(.secondary) }
                switch q.kind {
                case .multiple(let options, let keyPath):
                    IntakeFlowOptions(options: options, selection: Binding(
                        get: { answers[keyPath: keyPath] ?? "" },
                        set: { answers[keyPath: keyPath] = $0 }
                    ))
                case .shortAnswer(let placeholder, let keyPath):
                    TextField(placeholder, text: Binding(
                        get: { answers[keyPath: keyPath] ?? "" },
                        set: { answers[keyPath: keyPath] = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func advance() {
        if stepIndex < totalSteps - 1 {
            withAnimation(.easeInOut) { stepIndex += 1 }
        } else {
            // Create user profile then save questionnaire and show paywall
            let history = VapingHistory(
                yearsVaping: Double(yearsVaping) ?? 0,
                dailyCost: Double(dailyCost) ?? 0,
                deviceType: deviceType
            )
            if appState.currentUser == nil {
                appState.createUser(name: name.isEmpty ? "Guest" : name,
                                    email: email.isEmpty ? nil : email,
                                    age: Int(age),
                                    vapingHistory: history)
            }
            var q = answers
            q.isCompleted = true
            appState.questionnaire = q
            appState.persist()
            showPaywall = true
        }
    }
    
    // MARK: - Questions
    struct Question {
        enum Kind { case multiple(options: [String], keyPath: WritableKeyPath<OnboardingQuestionnaire, String?>)
            case shortAnswer(placeholder: String, keyPath: WritableKeyPath<OnboardingQuestionnaire, String?>) }
        let title: String
        let subtitle: String?
        let kind: Kind
    }
    
    private var questions: [Question] {
        [
            Question(title: "Why do you want to quit vaping?", subtitle: nil,
                     kind: .multiple(options: ["Health", "Save money", "Family/friends", "Improve fitness", "Other"], keyPath: \.reasonToQuit)),
            Question(title: "How long have you been vaping?", subtitle: nil,
                     kind: .multiple(options: ["< 6 months", "6–12 months", "1–2 years", "2+ years"], keyPath: \.yearsVaping)),
            Question(title: "How often do you vape?", subtitle: nil,
                     kind: .multiple(options: ["Occasionally", "A few times per day", "Regularly throughout the day", "Almost constantly"], keyPath: \.frequency)),
            Question(title: "When do you crave the most?", subtitle: nil,
                     kind: .multiple(options: ["Morning", "After meals", "During stress", "Social situations", "Before bed", "Other"], keyPath: \.cravingTimes)),
            Question(title: "Have you tried quitting before?", subtitle: nil,
                     kind: .multiple(options: ["Yes, once", "Yes, multiple times", "No, first attempt"], keyPath: \.triedBefore)),
            Question(title: "What usually makes quitting hard?", subtitle: "Pick one that fits best",
                     kind: .multiple(options: ["Cravings", "Stress", "Social pressure", "Boredom", "Withdrawal symptoms", "Other"], keyPath: \.hardestPart)),
            Question(title: "What support do you want from this app?", subtitle: nil,
                     kind: .multiple(options: ["Motivation", "Progress tracking", "Craving tips", "Community support", "Rewards"], keyPath: \.supportWanted)),
            Question(title: "What is your age group?", subtitle: nil,
                     kind: .multiple(options: ["Under 18", "18–24", "25–34", "35–44", "45+"], keyPath: \.ageGroup)),
            Question(title: "Do you want to set a quit date or start immediately?", subtitle: nil,
                     kind: .multiple(options: ["Set quit date", "Start immediately"], keyPath: \.startPlan)),
            Question(title: "Anything else you'd like us to know?", subtitle: "Optional",
                     kind: .shortAnswer(placeholder: "Your thoughts...", keyPath: \.freeText))
        ]
    }
}

// MARK: - Subviews
private struct IntakeProgressHeader: View {
    let current: Int
    let total: Int
    var body: some View {
        HStack {
            Text("Step \(current) of \(total)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            SwiftUI.ProgressView(value: Double(current) / Double(total))
                .tint(.pink)
        }
    }
}

private struct IntakeFlowOptions: View {
    let options: [String]
    @Binding var selection: String
    var body: some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                Button(action: { selection = option }) {
                    HStack {
                        Text(option)
                            .fontWeight(selection == option ? .semibold : .regular)
                        Spacer()
                        if selection == option {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(selection == option ? Color.pink.opacity(0.15) : Color.white.opacity(0.9)))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct IntakeWelcomeStep: View {
    var body: some View {
        VStack(spacing: 24) {
            Group {
                if UIImage(named: "LungBuddy_50") != nil {
                    Image("LungBuddy_50")
                        .resizable()
                        .scaledToFit()
                } else {
                    LungCharacter(healthLevel: 50, isAnimating: true)
                }
            }
            .frame(width: 150, height: 120)
            Text("Welcome to LungQuest")
                .font(.title)
                .fontWeight(.bold)
            Text("We'll personalize your plan with a few quick questions.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct IntakePersonalStep: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var age: String
    var body: some View {
        VStack(spacing: 20) {
            Text("About you")
                .font(.title2)
                .fontWeight(.semibold)
            VStack(spacing: 16) {
                IntakeTextField(title: "Name", text: $name, placeholder: "Enter your name")
                IntakeTextField(title: "Email (optional)", text: $email, placeholder: "you@email.com")
                IntakeTextField(title: "Age (optional)", text: $age, placeholder: "e.g., 28")
                    .keyboardType(.numberPad)
            }
        }
    }
}

private struct IntakeVapingStep: View {
    @Binding var yearsVaping: String
    @Binding var dailyCost: String
    @Binding var deviceType: String
    let deviceTypes: [String]
    var body: some View {
        VStack(spacing: 20) {
            Text("Your vaping background")
                .font(.title2)
                .fontWeight(.semibold)
            VStack(spacing: 16) {
                IntakeTextField(title: "How long have you been vaping? (years)", text: $yearsVaping, placeholder: "e.g., 2.5")
                    .keyboardType(.decimalPad)
                IntakeTextField(title: "Daily cost (USD)", text: $dailyCost, placeholder: "e.g., 15.00")
                    .keyboardType(.decimalPad)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Device Type").font(.subheadline).fontWeight(.medium)
                    Menu {
                        ForEach(deviceTypes, id: \.self) { type in
                            Button(type) { deviceType = type }
                        }
                    } label: {
                        HStack {
                            Text(deviceType)
                            Spacer()
                            Image(systemName: "chevron.down").foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
}

private struct IntakeTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).fontWeight(.medium)
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}




