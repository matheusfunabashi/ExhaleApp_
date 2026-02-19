import SwiftUI

struct OnboardingStep11bView: View {
    let userName: String
    let onNext: () -> Void
    let onBack: () -> Void
    let onReasonCollected: (String) -> Void
    
    @State private var reason: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    private let buttonColor = Color.white
    private let textColor = Color.black
    
    var body: some View {
        ZStack {
            StaticOnboardingBackground()
            
            VStack(spacing: 24) {
                header
                
                FinalHeadingView()
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(userName.isEmpty ? "Why do you want to quit vaping?" : "\(userName), why do you want to quit vaping?")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.75))
                        .onTapGesture {
                            isTextFieldFocused = false
                        }
                    
                    ZStack(alignment: .topLeading) {
                        if reason.isEmpty {
                            Text("Share your motivation...")
                                .foregroundColor(Color.black.opacity(0.35))
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .padding(.top, 18)
                                .padding(.leading, 20)
                        }
                        
                        TextEditor(text: $reason)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.black)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 200)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .focused($isTextFieldFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.sentences)
                    }
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                    )
                }
                .padding(.top, 12)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Button(action: {
                        if canProceed {
                            onReasonCollected(reason)
                            onNext()
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(textColor)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .background(buttonColor.opacity(canProceed ? 0.95 : 0.5))
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(canProceed ? 0.1 : 0.05), radius: 18, x: 0, y: 15)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canProceed)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 32)
            .dismissKeyboardOnTap()
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            OnboardingProgressBar(currentStep: 12, totalSteps: 13)
                .padding(.top, 8)
                .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Focus the text field when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
    
    private var header: some View {
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
            
            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.system(size: 14, weight: .medium))
                    Text("EN")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(Color.white.opacity(0.35), in: Capsule())
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var canProceed: Bool {
        // Must have reason text filled
        return !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct StaticOnboardingBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.82, green: 0.92, blue: 1.0),
                Color(red: 0.65, green: 0.80, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct FinalHeadingView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Finally!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Let's gather some last information to tailor this app for you")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
    }
}

#Preview {
    OnboardingStep11bView(
        userName: "John",
        onNext: {},
        onBack: {},
        onReasonCollected: { _ in }
    )
}

