import SwiftUI

struct OnboardingStep11bView: View {
    let userName: String
    let onNext: () -> Void
    let onBack: () -> Void
    let onReasonCollected: (String) -> Void
    
    @State private var reason: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            StaticOnboardingBackground()
            
            VStack(spacing: 24) {
                header
                
                FinalHeadingView(progress: 11.5 / 13.0)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(userName.isEmpty ? "Why do you want to quit vaping?" : "\(userName), why do you want to quit vaping?")
                        .onboardingInter(size: 18, weight: .semibold)
                        .foregroundColor(Color.white.opacity(0.92))
                        .onTapGesture {
                            isTextFieldFocused = false
                        }
                    
                    ZStack(alignment: .topLeading) {
                        if reason.isEmpty {
                            Text("Share your motivation...")
                                .foregroundColor(Color.white.opacity(0.55))
                                .onboardingInter(size: 18, weight: .medium)
                                .padding(.top, 18)
                                .padding(.leading, 20)
                        }
                        
                        TextEditor(text: $reason)
                            .onboardingInter(size: 18, weight: .medium)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 200)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .focused($isTextFieldFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.sentences)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    )
                }
                .padding(.top, 12)
                
                Spacer()
                
                VStack(spacing: 20) {
                    GlassButton(title: "Continue", isEnabled: canProceed) {
                        if canProceed {
                            onReasonCollected(reason)
                            onNext()
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 32)
            .dismissKeyboardOnTap()
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
                    .background(.ultraThinMaterial, in: Circle())
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
                .background(.ultraThinMaterial, in: Capsule())
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
        OnboardingFlowBackground()
    }
}

private struct FinalHeadingView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressBar(progress: progress)
                .frame(height: 6)
            
            VStack(spacing: 10) {
                Text("Finally!")
                    .onboardingInter(size: 32, weight: .bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Let's gather some last information to tailor this app for you")
                    .onboardingInter(size: 18, weight: .medium)
                    .foregroundColor(Color.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
    }
}

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

#Preview {
    OnboardingStep11bView(
        userName: "John",
        onNext: {},
        onBack: {},
        onReasonCollected: { _ in }
    )
}

