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
    @State private var showCreatingPlan: Bool = false
    @State private var appRating: Int = 0
    @State private var appRatingFeedback: String = ""
    
    // Intro flow state
    @State private var inIntro: Bool = true
    @State private var introIndex: Int = 0
    
    // Question flow indices: 1: Personal, 2: Vaping, 3... questions, (last) Rating
    private var questionTotalSteps: Int { 3 + questions.count }
    private var questionCurrentStepNumber: Int { max(1, stepIndex) } // stepIndex starts at 1 when questions begin
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if !inIntro {
                    IntakeProgressHeader(current: questionCurrentStepNumber, total: questionTotalSteps)
                }
                
                Group { inIntro ? AnyView(currentIntroView) : AnyView(currentStepView) }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
                Spacer(minLength: 8)
                
                HStack(spacing: 12) {
                    if inIntro {
                        if introIndex > 0 {
                            Button("Back") { withAnimation { introIndex -= 1 } }
                                .buttonStyle(.bordered)
                        }
                        Button(introIndex == introTotalSteps - 1 ? "Start" : "Next") { advanceIntro() }
                            .buttonStyle(.borderedProminent)
                    } else {
                        if stepIndex > 1 {
                            Button("Back") { withAnimation { stepIndex -= 1 } }
                                .buttonStyle(.bordered)
                        }
                        Button(stepIndex == questionTotalSteps ? "Done" : "Next") { advance() }
                            .buttonStyle(.borderedProminent)
                            .disabled(!isCurrentStepValid)
                    }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
                    .environmentObject(appState)
            }
            .fullScreenCover(isPresented: $showCreatingPlan) {
                CreatingPlanView {
                    showCreatingPlan = false
                    showPaywall = true
                }
            }
        }
        .onAppear {
            answers = appState.questionnaire
        }
    }
    
    // Intro pages count
    private var introTotalSteps: Int { 4 }
    
    private var isCurrentStepValid: Bool {
        switch stepIndex {
        case 1: return !name.isEmpty
        case 2: return !yearsVaping.isEmpty && !dailyCost.isEmpty
        case (2 + questions.count): return !(answers.reasonToQuit ?? "").isEmpty
        case (3 + questions.count): return appRating > 0 // require a rating 1-5
        default: return true
        }
    }
    
    @ViewBuilder private var currentStepView: some View {
        switch stepIndex {
        case 1:
            IntakePersonalStep(name: $name, email: $email, age: $age)
        case 2:
            IntakeVapingStep(yearsVaping: $yearsVaping, dailyCost: $dailyCost, deviceType: $deviceType, deviceTypes: deviceTypes)
        case 3...(2 + questions.count):
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
        case (3 + questions.count):
            RatingStep(rating: $appRating, feedback: $appRatingFeedback)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder private var currentIntroView: some View {
        switch introIndex {
        case 0:
            IntroApplauseStep()
        case 1:
            IntroHowHelpsStep()
        case 2:
            IntroFeaturesStep()
        default:
            IntakeWelcomeStep(questionCount: questions.count)
        }
    }
    
    private func advance() {
        if stepIndex < questionTotalSteps {
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
            showCreatingPlan = true
        }
    }
    
    private func advanceIntro() {
        if introIndex < introTotalSteps - 1 {
            withAnimation(.easeInOut) { introIndex += 1 }
        } else {
            withAnimation(.easeInOut) {
                inIntro = false
                stepIndex = 1 // begin questions at Personal step
            }
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
            // Move this to the end as an open answer (mandatory via validation)
            Question(title: "Why do you want to quit?", subtitle: nil,
                     kind: .shortAnswer(placeholder: "Tell us in your own words", keyPath: \.reasonToQuit))
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

private struct CreatingPlanView: View {
    let onDone: () -> Void
    @State private var isAnimating = false
    var body: some View {
        VStack(spacing: 20) {
            Text("Creating a personalized plan")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                .scaleEffect(1.4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear {
            // Simulate brief processing time before moving to paywall
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                onDone()
            }
        }
    }
}

private struct RatingStep: View {
    @Binding var rating: Int
    @Binding var feedback: String
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How would you rate LungQuest so far?")
                .font(.title2)
                .fontWeight(.bold)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: { rating = star }) {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
            }
            TextField("Optional feedback", text: $feedback)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
    let questionCount: Int
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 6) {
                Text("We’ll ask you \(questionCount) quick questions to help create your quitting plan.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Text("Tap Start to begin.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct IntroApplauseStep: View {
    var body: some View {
        VStack(spacing: 24) {
            Group {
                if UIImage(named: "LungBuddy_50") != nil {
                    Image("LungBuddy_50").resizable().scaledToFit()
                } else {
                    LungCharacter(healthLevel: 60, isAnimating: true)
                }
            }
            .frame(width: 150, height: 120)
            Text("You're taking a powerful step")
                .font(.title2)
                .fontWeight(.bold)
            Text("Applause for deciding to quit vaping — we’re here for you at every step.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct IntroHowHelpsStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How LungQuest helps")
                .font(.title2)
                .fontWeight(.bold)
            Text("We combine a tailored plan, positive motivation, and science‑backed milestones so you can build lasting habits and feel better, faster.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct IntroFeaturesStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What you’ll get")
                .font(.title2)
                .fontWeight(.bold)
            FeatureRow(icon: "lungs.fill", text: "LungBuddy that heals with you")
            FeatureRow(icon: "timer", text: "Vape‑free timer + health progress")
            FeatureRow(icon: "checkmark.circle.fill", text: "Daily check‑ins and craving tools")
            FeatureRow(icon: "target", text: "Quests and rewards to stay on track")
            FeatureRow(icon: "book.fill", text: "Practical lessons for tough moments")
            FeatureRow(icon: "wrench.and.screwdriver.fill", text: "Gadgets (coming soon)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
private struct FeatureRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.pink)
            Text(text)
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




