import SwiftUI
import Combine
import UIKit
import PencilKit

private enum OnboardingRoute: Hashable {
    case step3
    case step4
    case step5
    case step6
    case step7
    case step8
    case step9
    case step10
    case step10b(weeklyCost: Double, currency: String)
    case step11
    case step12
    case step12b(userName: String)
    case symptoms
    case reviews
    case commitment
    case step13(entryId: UUID)
}

struct OnboardingView: View {
    init(onSkipAll: @escaping (String?, Int?, Double?, String?) -> Void = { _, _, _, _ in }) {
        self.onSkipAll = onSkipAll
    }
    
    @State private var showContinue = false
    @State private var navigationPath: [OnboardingRoute] = []
    @StateObject private var profileStore = ProfileStore()
    @State private var collectedName: String = ""
    @State private var collectedAge: String = ""
    @State private var collectedSymptoms: [String] = []
    @State private var collectedWeeklyCost: Double = 0
    @State private var collectedCurrency: String = "$"
    private let onSkipAll: (String?, Int?, Double?, String?) -> Void
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                OnboardingFlowBackground()
                
                VStack(spacing: 48) {
                    Spacer()
                    
                    OnboardingHeroView(onMessageComplete: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeIn(duration: 0.6)) {
                                showContinue = true
                            }
                        }
                    })
                    
                    Spacer()
                    
                    ContinueButtonView(isEnabled: showContinue, onContinue: {
                        navigationPath.append(.step3)
                    })
                    .opacity(showContinue ? 1 : 0)
                    .animation(.easeInOut(duration: 0.6), value: showContinue)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 40)
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: OnboardingRoute.self) { route in
                switch route {
                case .step3:
                    OnboardingStep3View(onBegin: {
                        navigationPath.append(.step4)
                    }, onSkip: { skipAll() })
                case .step4:
                    OnboardingStep4View(
                        onNext: { navigationPath.append(.step5) },
                        onBack: { popRoute() }
                    )
                case .step5:
                    OnboardingStep5View(
                        onNext: { navigationPath.append(.step6) },
                        onBack: { popRoute() }
                    )
                case .step6:
                    OnboardingStep6View(
                        onNext: { navigationPath.append(.step7) },
                        onBack: { popRoute() }
                    )
                case .step7:
                    OnboardingStep7View(
                        onNext: { navigationPath.append(.step8) },
                        onBack: { popRoute() }
                    )
                case .step8:
                    OnboardingStep8View(
                        onNext: { navigationPath.append(.step9) },
                        onBack: { popRoute() }
                    )
                case .step9:
                    OnboardingStep9View(
                        onNext: { navigationPath.append(.step10) },
                        onBack: { popRoute() }
                    )
                case .step10:
                    OnboardingStep10View(
                        onNext: { weeklyCost, currency in
                            // Pass values directly through the route
                            navigationPath.append(.step10b(weeklyCost: weeklyCost, currency: currency))
                            // Also update state for later use
                            collectedWeeklyCost = weeklyCost
                            collectedCurrency = currency
                        },
                        onBack: { popRoute() }
                    )
                case .step10b(let weeklyCost, let currency):
                    OnboardingStep10bView(
                        weeklyCost: weeklyCost,
                        currency: currency.isEmpty ? "$" : currency,
                        onNext: { navigationPath.append(.step11) },
                        onBack: { popRoute() }
                    )
                    .id("\(collectedWeeklyCost)-\(collectedCurrency)")
                case .step11:
                    OnboardingStep11View(
                        onNext: { },
                        onBack: { popRoute() },
                        onNameCollected: { name, age in
                            // Update state first
                            collectedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            collectedAge = age.trimmingCharacters(in: .whitespacesAndNewlines)
                            // Navigate to step12 directly (removed step11b)
                            navigationPath.append(.step12)
                        }
                    )
                case .step12:
                    OnboardingStep12View(
                        onComplete: { 
                            let name = collectedName.trimmingCharacters(in: .whitespacesAndNewlines)
                            navigationPath.append(.step12b(userName: name.isEmpty ? "" : name))
                        },
                        onBack: { popRoute() }
                    )
                case .step12b(let userName):
                    OnboardingStep12bView(
                        userName: userName,
                        onNext: { navigationPath.append(.symptoms) },
                        onBack: { popRoute() }
                    )
                case .symptoms:
                    OnboardingSymptomsInlineView(
                        onNext: { navigationPath.append(.reviews) },
                        onBack: { popRoute() },
                        onSymptomsCollected: { symptoms in
                            collectedSymptoms = symptoms
                        }
                    )
                case .reviews:
                    OnboardingReviewsView(
                        onNext: { navigationPath.append(.commitment) },
                        onBack: { popRoute() }
                    )
                case .commitment:
                    OnboardingCommitmentView(
                        onNext: { navigationPath.append(.step13(entryId: UUID())) },
                        onBack: { popRoute() }
                    )
                case .step13:
                    OnboardingStep13View(
                        onContinue: { 
                            let ageInt = collectedAge.isEmpty ? nil : Int(collectedAge)
                            skipAll(
                                withName: collectedName.isEmpty ? nil : collectedName,
                                age: ageInt,
                                weeklyCost: collectedWeeklyCost > 0 ? collectedWeeklyCost : nil,
                                currency: collectedCurrency.isEmpty ? nil : collectedCurrency
                            )
                        },
                        onBack: { popRoute() }
                    )
                }
            }
        }
        .environmentObject(profileStore)
        .onboardingInter(size: 17, weight: .regular)
        .foregroundStyle(.white)
    }
}

// MARK: - Hero Content

private struct OnboardingHeroView: View {
    let onMessageComplete: () -> Void
    private let message = "Reflect before relapsing."
    private let letterDelay: TimeInterval = 0.085
    
    @State private var displayedText: String = ""
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        VStack(spacing: 32) {
            LogoView()
            
            Text(displayedText)
                .onboardingInter(size: 26, weight: .semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: Color.white.opacity(0.35), radius: 8, x: 0, y: 0)
                .padding(.horizontal, 16)
        }
        .onAppear(perform: startAnimation)
        .onDisappear {
            cancellable?.cancel()
        }
    }
    
    private func startAnimation() {
        cancellable?.cancel()
        displayedText = ""
        let characters = Array(message)
        var index = 0
        cancellable = Timer.publish(every: letterDelay, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard index < characters.count else {
                    cancellable?.cancel()
                    onMessageComplete()
                    return
                }
                
                displayedText.append(characters[index])
                HapticManager.shared.playSoftTap()
                index += 1
            }
    }
}

private struct LogoView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("logoImagePlaceholder") // TODO: Replace with the actual Exhale logo asset.
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 60)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
            
            Text("Embrace this pause.")
                .onboardingInter(size: 16, weight: .medium)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

private struct ContinueButtonView: View {
    let isEnabled: Bool
    let onContinue: () -> Void
    
    var body: some View {
        GlassButton(title: "Continue", systemImage: "arrow.right", isEnabled: isEnabled, action: onContinue)
        .accessibilityLabel("Continue to the next onboarding step")
    }
}

private extension OnboardingView {
    func skipAll(withName name: String? = nil, age: Int? = nil, weeklyCost: Double? = nil, currency: String? = nil) {
        navigationPath.removeAll()
        onSkipAll(name, age, weeklyCost, currency)
    }
    
    func popRoute() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}


// MARK: - Haptics

private final class HapticManager {
    static let shared = HapticManager()
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    private init() {
        generator.prepare()
    }
    
    func playSoftTap() {
        generator.impactOccurred(intensity: 0.6)
        generator.prepare()
    }
}

// MARK: - Reusable Components

private struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(height: geo.size.height)
                
                Capsule()
                    .fill(Color.white.opacity(0.75))
                    .frame(width: max(0, min(1, progress)) * geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Symptoms View

private struct OnboardingSymptomsInlineView: View {
    let onNext: () -> Void
    let onBack: () -> Void
    let onSymptomsCollected: ([String]) -> Void
    
    @State private var selectedSymptoms: Set<String> = []
    
    private let mentalSymptoms = [
        "Feeling unmotivated",
        "Lack of ambition",
        "Difficulty concentrating",
        "Poor memory or 'brain fog'",
        "General anxiety"
    ]
    
    private let physicalSymptoms = [
        "Shortness of breath",
        "Persistent cough",
        "Chest tightness",
        "Headaches",
        "Dizziness",
        "Insomnia or poor sleep"
    ]
    
    private let behavioralSymptoms = [
        "Reaching for your vape automatically",
        "Vaping when stressed, bored, or anxious",
        "Difficulty going a few hours without vaping",
        "Vaping first thing in the morning",
        "Vaping even when you planned not to",
        "Constantly thinking about your next hit"
    ]
    
    var body: some View {
        ZStack {
            OnboardingFlowBackground()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 52)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Progress and Title
                        VStack(spacing: 20) {
                            ProgressBar(progress: 12.5 / 13.0)
                                .frame(height: 6)
                            
                            VStack(spacing: 8) {
                                Text("Symptoms")
                                    .onboardingInter(size: 32, weight: .bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                        
                        // Warning banner
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                            
                            Text("Excessive vaping can have negative impacts psychologically and physically.")
                                .onboardingInter(size: 15, weight: .medium)
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(red: 1.0, green: 0.4, blue: 0.3))
                        )
                        .padding(.horizontal, 24)
                        
                        // Instructions
                        Text("Select any symptoms below:")
                            .onboardingInter(size: 18, weight: .semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        
                        // Mental Symptoms
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mental")
                                .onboardingInter(size: 16, weight: .bold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            ForEach(mentalSymptoms, id: \.self) { symptom in
                                SymptomRow(
                                    symptom: symptom,
                                    isSelected: selectedSymptoms.contains(symptom)
                                ) {
                                    toggleSymptom(symptom)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Physical Symptoms
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Physical")
                                .onboardingInter(size: 16, weight: .bold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            ForEach(physicalSymptoms, id: \.self) { symptom in
                                SymptomRow(
                                    symptom: symptom,
                                    isSelected: selectedSymptoms.contains(symptom)
                                ) {
                                    toggleSymptom(symptom)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Behavioral Symptoms
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Behavioral")
                                .onboardingInter(size: 16, weight: .bold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            ForEach(behavioralSymptoms, id: \.self) { symptom in
                                SymptomRow(
                                    symptom: symptom,
                                    isSelected: selectedSymptoms.contains(symptom)
                                ) {
                                    toggleSymptom(symptom)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }
                }
                
                // Continue button (fixed at bottom)
                VStack {
                    GlassButton(
                        title: "Reboot my brain",
                        isEnabled: true
                    ) {
                        onSymptomsCollected(Array(selectedSymptoms))
                        onNext()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func toggleSymptom(_ symptom: String) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }
}

private struct SymptomRow: View {
    let symptom: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Radio button
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.45, green: 0.72, blue: 0.99))
                            .frame(width: 16, height: 16)
                    }
                }
                
                Text(symptom)
                    .onboardingInter(size: 17, weight: .medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                isSelected ? Color(red: 0.45, green: 0.72, blue: 0.99) : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Onboarding Reviews View

private struct OnboardingReviewsView: View {
    let onNext: () -> Void
    let onBack: () -> Void
    
    private let reviews: [(quote: String, author: String)] = [
        (
            "I didn't think I could quit. Now I'm a month vape-free, I breathe easier, I sleep through the night and my head feels clearer. This genuinely changed my life",
            "Felipe A."
        ),
        (
            "This app really made the difference for me, the animations and trackers held me accountable and motivated me to stop, all while I learned about all the benefits I was missing out on because of my addiction.",
            "Rymbem"
        ),
        (
            "I didn't believe I could quit until I saw an ad for this app and decided to try it. It has changed my life and put me on the right path",
            "Matheus F."
        ),
        (
            "Best quit vaping app I've tried. The daily check-ins and lung health tips kept me motivated. Two months vape-free thanks to Exhale!",
            "Sarah K."
        )
    ]
    
    private let spacingMedium: CGFloat = 16
    private let spacingLarge: CGFloat = 24
    private let contentMaxWidth: CGFloat = 600
    
    var body: some View {
        ZStack {
            OnboardingFlowBackground()
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    // Header with back button
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.35), in: Circle())
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.top, spacingMedium)
                    .padding(.bottom, spacingLarge)
                    
                    // Progress and Title
                    VStack(spacing: 16) {
                        ProgressBar(progress: 13 / 14)
                            .frame(height: 6)
                        
                        Text("We're a small team, so a rating goes a long way ❤️")
                            .onboardingInter(size: 22, weight: .bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("We've helped countless people quit vaping, and we know you can do it too.")
                            .onboardingInter(size: 16, weight: .medium)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, spacingLarge)
                    
                    // Review cards
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(Array(reviews.enumerated()), id: \.offset) { _, review in
                                ReviewCard(quote: review.quote, author: review.author)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                    
                    Spacer(minLength: 0)
                    
                    // Rate the app button
                    GlassButton(
                        title: "Rate the app",
                        systemImage: "arrow.right",
                        action: {
                            ReviewManager.shared.requestReviewNow()
                            onNext()
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, spacingLarge)
                }
                .frame(maxWidth: contentMaxWidth)
                .padding(.horizontal, spacingMedium)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

private struct ReviewCard: View {
    let quote: String
    let author: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Stars
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                }
            }
            
            Text(quote)
                .onboardingInter(size: 15, weight: .regular)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(author)
                .onboardingInter(size: 14, weight: .semibold)
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

// MARK: - Onboarding Commitment View

private struct OnboardingCommitmentView: View {
    let onNext: () -> Void
    let onBack: () -> Void
    
    @State private var canvasView = PKCanvasView()
    @State private var hasDrawn = false
    
    private let spacingSmall: CGFloat = 8
    private let spacingMedium: CGFloat = 16
    private let spacingLarge: CGFloat = 24
    private let contentMaxWidth: CGFloat = 600
    
    var body: some View {
        ZStack {
            OnboardingFlowBackground()
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    // Header with back button
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.35), in: Circle())
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.top, spacingMedium)
                    .padding(.bottom, spacingLarge)
                    
                    // Title
                    Text("Sign your commitment")
                        .onboardingInter(size: 28, weight: .bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, spacingSmall)
                    
                    // Subtitle
                    Text("Finally, promise yourself that you will never vape again.")
                        .onboardingInter(size: 16, weight: .medium)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, spacingLarge)
                    
                    // Drawing canvas
                    DrawingCanvasView(canvasView: $canvasView, hasDrawn: $hasDrawn)
                        .frame(height: 250)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                        .padding(.bottom, spacingMedium)
                    
                    // Clear button
                    Button(action: {
                        canvasView.drawing = PKDrawing()
                        hasDrawn = false
                    }) {
                        Text("Clear")
                            .onboardingInter(size: 16, weight: .semibold)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, spacingSmall)
                    
                    // Instruction text
                    Text("Draw on the open space above")
                        .onboardingInter(size: 14, weight: .medium)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, spacingLarge)
                    
                    Spacer(minLength: 0)
                    
                    // Finish button
                    GlassButton(
                        title: "Finish",
                        systemImage: nil,
                        action: onNext
                    )
                    .opacity(hasDrawn ? 1.0 : 0.5)
                    .disabled(!hasDrawn)
                    .padding(.bottom, spacingMedium)
                }
                .frame(maxWidth: contentMaxWidth)
                .padding(.horizontal, spacingLarge)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

private struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var hasDrawn: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.delegate = context.coordinator
        
        // Allow finger and mouse input (not just Apple Pencil) - required for simulator and finger drawing on device
        canvasView.drawingPolicy = .anyInput
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(hasDrawn: $hasDrawn)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var hasDrawn: Bool
        
        init(hasDrawn: Binding<Bool>) {
            self._hasDrawn = hasDrawn
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            if !canvasView.drawing.bounds.isEmpty {
                hasDrawn = true
            }
        }
    }
}

#Preview {
    OnboardingView()
}

