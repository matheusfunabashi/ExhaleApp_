import SwiftUI
import UIKit

struct IntakeView: View {
    @EnvironmentObject var appState: AppState
    
    // Profile inputs
    @State private var name: String = ""
    @State private var gender: String = ""
    @State private var birthYear: String = ""
    @State private var vapingFrequency: String = ""
    @State private var weeklySpending: String = ""
    @State private var dailyPuffs: String = ""
    private let frequencyOptions = ["DAILY", "FREQUENT", "ALWAYS"]
    private let genderOptions = ["Male", "Female", "Other"]
    
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
    
    // Question flow indices: 1: Name, 2: Gender, 3: Birth Year, 4: Frequency, 5: Spending, 6: Puffs, 7... questions, 8: Timeline, (last) Rating
    private var questionTotalSteps: Int { 8 + questions.count }
    private var questionCurrentStepNumber: Int { max(1, stepIndex) } // stepIndex starts at 1 when questions begin
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Top navigation with back arrow
                    HStack {
                        if !inIntro && stepIndex > 1 {
                            Button(action: { withAnimation { stepIndex -= 1 } }) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(Color(.systemGray6))
                                    )
                            }
                            .buttonStyle(.plain)
                        } else if inIntro && introIndex > 0 {
                            Button(action: { withAnimation { introIndex -= 1 } }) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(Color(.systemGray6))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Spacer()
                        
                if !inIntro {
                    IntakeProgressHeader(current: questionCurrentStepNumber, total: questionTotalSteps)
                }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                    // Main content
                Group { inIntro ? AnyView(currentIntroView) : AnyView(currentStepView) }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Bottom Next button
                    VStack {
                        Button(action: {
                    if inIntro {
                                advanceIntro()
                            } else {
                                advance()
                            }
                        }) {
                            Text(inIntro ? (introIndex == introTotalSteps - 1 ? "Start" : "Next") : (stepIndex == questionTotalSteps ? "Done" : "Next"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.blue.opacity(0.7))
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(!inIntro && !isCurrentStepValid)
                        .opacity((!inIntro && !isCurrentStepValid) ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
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
        case 2: return !gender.isEmpty
        case 3: return !birthYear.isEmpty
        case 4: return !vapingFrequency.isEmpty
        case 5: return !weeklySpending.isEmpty
        case 6: return !dailyPuffs.isEmpty
        case 11: return true // Timeline screen - always valid
        case (6 + questions.count): return !(answers.reasonToQuit ?? "").isEmpty
        case (7 + questions.count): return appRating > 0 // require a rating 1-5
        default: 
            // For multiple selection questions, require at least one selection
            if stepIndex >= 7 && stepIndex <= 10 {
                let questionIndex = stepIndex - 7
                if questionIndex < questions.count {
                    let question = questions[questionIndex]
                    switch question.kind {
                    case .multipleSelection(_, let keyPath):
                        return !answers[keyPath: keyPath].isEmpty
                    default:
                        return true
                    }
                }
            } else if stepIndex >= 12 && stepIndex <= (6 + questions.count) {
                let questionIndex = stepIndex - 8
                if questionIndex < questions.count {
                    let question = questions[questionIndex]
                    switch question.kind {
                    case .multipleSelection(_, let keyPath):
                        return !answers[keyPath: keyPath].isEmpty
                    default:
                        return true
                    }
                }
            }
            return true
        }
    }
    
    @ViewBuilder private var currentStepView: some View {
        switch stepIndex {
        case 1:
            IntakeNameStep(name: $name)
        case 2:
            IntakeGenderStep(gender: $gender, genderOptions: genderOptions)
        case 3:
            IntakeBirthYearStep(birthYear: $birthYear)
        case 4:
            IntakeFrequencyStep(frequency: $vapingFrequency, frequencyOptions: frequencyOptions)
        case 5:
            IntakeSpendingStep(spending: $weeklySpending)
        case 6:
            IntakePuffsStep(puffs: $dailyPuffs)
        case 7...10:
            let q = questions[stepIndex - 7]
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                Text(q.title)
                    .font(.title2)
                    .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    if let subtitle = q.subtitle { 
                        Text(subtitle)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal, 20)
                
                switch q.kind {
                case .multiple(let options, let keyPath):
                    IntakeFlowOptions(options: options, selection: Binding(
                        get: { answers[keyPath: keyPath] ?? "" },
                        set: { answers[keyPath: keyPath] = $0 }
                    ))
                case .multipleSelection(let options, let keyPath):
                    IntakeFlowMultipleOptions(options: options, selections: Binding(
                        get: { answers[keyPath: keyPath] },
                        set: { answers[keyPath: keyPath] = $0 }
                    ))
                case .shortAnswer(let placeholder, let keyPath):
                    TextField(placeholder, text: Binding(
                        get: { answers[keyPath: keyPath] ?? "" },
                        set: { answers[keyPath: keyPath] = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case 11:
            IntakeTimelineStep()
        case 12...(6 + questions.count):
            let q = questions[stepIndex - 8] // Adjusted for timeline insertion
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(q.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    if let subtitle = q.subtitle { 
                        Text(subtitle)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal, 20)
                
                switch q.kind {
                case .multiple(let options, let keyPath):
                    IntakeFlowOptions(options: options, selection: Binding(
                        get: { answers[keyPath: keyPath] ?? "" },
                        set: { answers[keyPath: keyPath] = $0 }
                    ))
                case .multipleSelection(let options, let keyPath):
                    IntakeFlowMultipleOptions(options: options, selections: Binding(
                        get: { answers[keyPath: keyPath] },
                        set: { answers[keyPath: keyPath] = $0 }
                    ))
                case .shortAnswer(let placeholder, let keyPath):
                    TextField(placeholder, text: Binding(
                        get: { answers[keyPath: keyPath] ?? "" },
                        set: { answers[keyPath: keyPath] = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case (7 + questions.count):
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
                yearsVaping: 0, // We'll calculate this from frequency
                dailyCost: Double(weeklySpending) ?? 0,
                deviceType: "Pod System" // Default device type
            )
            if appState.currentUser == nil {
                let currentYear = Calendar.current.component(.year, from: Date())
                let age = Int(birthYear) != nil ? currentYear - Int(birthYear)! : nil
                appState.createUser(name: name.isEmpty ? "Guest" : name,
                                    email: nil,
                                    age: age,
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
        enum Kind { 
            case multiple(options: [String], keyPath: WritableKeyPath<OnboardingQuestionnaire, String?>)
            case multipleSelection(options: [String], keyPath: WritableKeyPath<OnboardingQuestionnaire, [String]>)
            case shortAnswer(placeholder: String, keyPath: WritableKeyPath<OnboardingQuestionnaire, String?>) 
        }
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
            Question(title: "When do you crave the most?", subtitle: "Select all that apply",
                     kind: .multipleSelection(options: ["Morning", "After meals", "During stress", "Social situations", "Before bed", "Other"], keyPath: \.cravingTimes)),
            Question(title: "Have you tried quitting before?", subtitle: nil,
                     kind: .multiple(options: ["Yes, once", "Yes, multiple times", "No, first attempt"], keyPath: \.triedBefore)),
            Question(title: "What usually makes quitting hard?", subtitle: "Select all that apply",
                     kind: .multipleSelection(options: ["Cravings", "Stress", "Social pressure", "Boredom", "Withdrawal symptoms", "Other"], keyPath: \.hardestPart)),
            Question(title: "What support do you want from this app?", subtitle: "Select all that apply",
                     kind: .multipleSelection(options: ["Motivation", "Progress tracking", "Craving tips", "Community support", "Rewards"], keyPath: \.supportWanted)),
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
                .tint(.blue.opacity(0.7))
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
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
            Text("How would you rate LungQuest so far?")
                .font(.title2)
                .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            
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
            .padding(.horizontal, 20)
            
            TextField("Optional feedback", text: $feedback)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct IntakeFlowOptions: View {
    let options: [String]
    @Binding var selection: String
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: { selection = option }) {
                    HStack {
                        Text(option)
                            .font(.body)
                            .fontWeight(selection == option ? .semibold : .regular)
                            .foregroundColor(.primary)
                        Spacer()
                        if selection == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue.opacity(0.7))
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selection == option ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selection == option ? Color.blue.opacity(0.7) : Color.clear, lineWidth: 2)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct IntakeFlowMultipleOptions: View {
    let options: [String]
    @Binding var selections: [String]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: { 
                    if selections.contains(option) {
                        selections.removeAll { $0 == option }
                    } else {
                        selections.append(option)
                    }
                }) {
                    HStack {
                        Text(option)
                            .font(.body)
                            .fontWeight(selections.contains(option) ? .semibold : .regular)
                            .foregroundColor(.primary)
                        Spacer()
                        if selections.contains(option) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue.opacity(0.7))
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selections.contains(option) ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selections.contains(option) ? Color.blue.opacity(0.7) : Color.clear, lineWidth: 2)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
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
        VStack(spacing: 32) {
            Spacer()
            
            Group {
                if UIImage(named: "LungBuddy_50") != nil {
                    Image("LungBuddy_50").resizable().scaledToFit()
                } else {
                    LungCharacter(healthLevel: 60, isAnimating: true)
                }
            }
            .frame(width: 150, height: 120)
            
            VStack(spacing: 16) {
            Text("You're taking a powerful step")
                    .font(.title)
                .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Applause for deciding to quit vaping — we're here for you at every step.")
                    .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            // Screenshot carousel: add assets named "Intro_Home" and "Intro_Learn"
            IntroScreenshotCarousel(assetNames: ["Intro_Home", "Intro_Progress", "Intro_Learn", "Intro_Timer"])
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)
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

// MARK: - Intro screenshot helpers
private struct IntroScreenshot: View {
    let assetName: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            Group {
                if UIImage(named: assetName) != nil {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(12)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("Add screenshot asset ‘\(assetName)’")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(24)
                }
            }
        }
        .frame(height: 260)
    }
}

private struct IntroScreenshotCarousel: View {
    let assetNames: [String]
    @State private var index: Int = 0
    var body: some View {
        TabView(selection: $index) {
            ForEach(Array(assetNames.enumerated()), id: \.offset) { idx, name in
                IntroScreenshot(assetName: name)
                    .tag(idx)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 260)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.clear)
        )
    }
}

private struct IntakeNameStep: View {
    @Binding var name: String
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What should we call you?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("We'll use this to personalize your experience")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 8) {
                TextField("Enter your name", text: $name)
                .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20),
                        alignment: .bottom
                    )
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct IntakeGenderStep: View {
    @Binding var gender: String
    let genderOptions: [String]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What's your gender?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("This helps us customize your experience")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(genderOptions, id: \.self) { option in
                    Button(action: { gender = option }) {
                        HStack {
                            Text(option)
                                .font(.body)
                                .fontWeight(gender == option ? .semibold : .regular)
                                .foregroundColor(.primary)
                            Spacer()
                            if gender == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(gender == option ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(gender == option ? Color.blue.opacity(0.7) : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct IntakeBirthYearStep: View {
    @Binding var birthYear: String
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("When were you born?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Your age helps us customize your reduction goals")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 8) {
                TextField("Year", text: $birthYear)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .padding(.vertical, 16)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20),
                        alignment: .bottom
                    )
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct IntakeFrequencyStep: View {
    @Binding var frequency: String
    let frequencyOptions: [String]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("How often do you vape?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("This helps establish your baseline habits")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                ForEach(frequencyOptions, id: \.self) { option in
                    Button(action: { frequency = option }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(option)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(frequency == option ? .white : .primary)
                            
                            Text(getDescription(for: option))
                                .font(.body)
                                .foregroundColor(frequency == option ? .white.opacity(0.9) : .secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(frequency == option ? Color.blue.opacity(0.7) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(frequency == option ? Color.blue.opacity(0.7) : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getDescription(for option: String) -> String {
        switch option {
        case "DAILY":
            return "You vape at predictable times as part of a routine."
        case "FREQUENT":
            return "You vape several times most days, but not on a set schedule."
        case "ALWAYS":
            return "You vape throughout the day with only brief breaks."
        default:
            return ""
        }
    }
}

private struct IntakeSpendingStep: View {
    @Binding var spending: String
    @State private var selectedCurrency: String = "USD"
    private let currencies = ["USD", "EUR", "GBP", "CAD", "AUD"]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("How much do you spend per week?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Tracking expenses shows your potential savings")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    TextField("0", text: $spending)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .padding(.vertical, 16)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20),
                            alignment: .bottom
                        )
                    
                    Menu {
                        ForEach(currencies, id: \.self) { currency in
                            Button("$ \(currency)") {
                                selectedCurrency = currency
                            }
                        }
                    } label: {
                        HStack {
                            Text("$ \(selectedCurrency)")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                                .background(Color.white)
                        )
                    }
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct IntakePuffsStep: View {
    @Binding var puffs: String
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("How many puffs do you take per day?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("You can specify an approximate number - if in the first few days it turns out that the limit is too low, we will adjust it, no worry")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    TextField("0", text: $puffs)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .padding(.vertical, 16)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20),
                            alignment: .bottom
                        )
                    
                    Text(getAddictionLevel(for: Int(puffs) ?? 0))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue.opacity(0.7))
                        )
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getAddictionLevel(for puffs: Int) -> String {
        switch puffs {
        case 0..<50:
            return "Light usage"
        case 50..<150:
            return "Moderate addiction"
        case 150..<300:
            return "Heavy addiction"
        default:
            return "Very heavy addiction"
        }
    }
}

private struct IntakeTimelineStep: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Here's how your body will change using Exhale")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Based on your intake, here's your personalized timeline")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 20) {
                TimelineMilestone(time: "24h", title: "Nicotine leaving your system", description: "Your body starts clearing nicotine from your bloodstream")
                
                TimelineMilestone(time: "72h", title: "Cravings peak then drop", description: "The worst cravings hit, but they'll start decreasing soon")
                
                TimelineMilestone(time: "2 weeks", title: "Lung function begins to rebound", description: "Your lungs start healing and breathing improves")
                
                TimelineMilestone(time: "1 month", title: "Circulation improves", description: "Blood flow and oxygen levels return to normal")
                
                TimelineMilestone(time: "3 months", title: "Lung capacity increases", description: "Significant improvement in breathing and lung function")
                
                TimelineMilestone(time: "1 year", title: "Risk of heart disease cut in half", description: "Your cardiovascular health dramatically improves")
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TimelineMilestone: View {
    let time: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack {
                Circle()
                    .fill(Color.blue.opacity(0.7))
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 2, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(time)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue.opacity(0.7))
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
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




