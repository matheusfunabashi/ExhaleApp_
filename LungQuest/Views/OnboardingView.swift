import SwiftUI
import Combine
import UIKit

private enum OnboardingRoute: Hashable {
    case step2
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
    case step11b
    case step12
    case step12b(userName: String)
    case step13
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
    @State private var collectedReason: String = ""
    @State private var collectedWeeklyCost: Double = 0
    @State private var collectedCurrency: String = "$"
    private let onSkipAll: (String?, Int?, Double?, String?) -> Void
    #if DEBUG
    @EnvironmentObject var flowManager: AppFlowManager
    #endif
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color(red: 0.52, green: 0.72, blue: 0.97)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
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
                        navigationPath.append(.step2)
                    })
                    .opacity(showContinue ? 1 : 0)
                    .animation(.easeInOut(duration: 0.6), value: showContinue)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 40)
            }
            .navigationBarBackButtonHidden(true)
            #if DEBUG
            .toolbar {
                if flowManager.isDevModeOnboarding {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            flowManager.exitDevModeOnboarding()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                    }
                }
            }
            #endif
            .navigationDestination(for: OnboardingRoute.self) { route in
                switch route {
                case .step2:
                    OnboardingStep2View(
                        onSkip: { skipAll() },
                        onNext: {
                        navigationPath.append(.step3)
                        },
                        onBack: { popRoute() }
                    )
                    .environmentObject(profileStore)
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
                            // Navigate after updating the state
                            navigationPath.append(.step11b)
                        }
                    )
                case .step11b:
                    OnboardingStep11bView(
                        userName: collectedName,
                        onNext: { navigationPath.append(.step12) },
                        onBack: { popRoute() },
                        onReasonCollected: { reason in
                            collectedReason = reason
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
                        onNext: { navigationPath.append(.step13) },
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
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.blue.opacity(0.85))
                .shadow(color: Color.white.opacity(0.6), radius: 8, x: 0, y: 0)
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
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color.blue.opacity(0.6))
        }
    }
}

private struct ContinueButtonView: View {
    let isEnabled: Bool
    let onContinue: () -> Void
    
    var body: some View {
        Button(action: {
            onContinue()
        }) {
            HStack(spacing: 10) {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.85),
                        Color.blue.opacity(0.65)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 8)
        }
        .disabled(!isEnabled)
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

#Preview {
    OnboardingView()
}

