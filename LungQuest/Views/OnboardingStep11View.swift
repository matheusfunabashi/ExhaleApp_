import SwiftUI

struct OnboardingStep11View: View {
    let onNext: () -> Void
    let onBack: () -> Void
    let onNameCollected: (String, String) -> Void
    
    @State private var name: String = ""
    @State private var age: String = ""
    
    var body: some View {
        ZStack {
            StaticOnboardingBackground()
            
            VStack(spacing: 24) {
                header
                
                FinalHeadingView(progress: 11.0 / 13.0)
                    .padding(.top, 4)
                
                VStack(spacing: 24) {
                    LabeledTextField(
                        label: "How should we call you?",
                        placeholder: "Your preferred name",
                        text: $name,
                        keyboard: .default
                    )
                    
                    LabeledTextField(
                        label: "How old are you?",
                        placeholder: "Your age",
                        text: $age,
                        keyboard: .numberPad
                    )
                }
                .padding(.top, 12)
                .dismissKeyboardOnTap()
                
                Spacer()
                
                VStack(spacing: 20) {
                    GlassButton(title: "Continue", isEnabled: canProceed) {
                        if canProceed {
                            onNameCollected(name, age)
                            // onNext is handled by onNameCollected in OnboardingView
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(true)
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
        // Must have both name and age filled
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               Int(age) != nil
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
                
                Text("Let’s gather some last information to tailor this app for you")
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

private struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .onboardingInter(size: 16, weight: .semibold)
                .foregroundColor(Color.white.opacity(0.9))
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color.white.opacity(0.55))
                        .onboardingInter(size: 18, weight: .medium)
                }
                
                TextField("", text: $text)
                    .keyboardType(keyboard)
                    .onboardingInter(size: 20, weight: .semibold)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
                .padding(.vertical, 18)
                .padding(.horizontal, 20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 1)
                )
        }
    }
}

private struct SkipButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingStep11View(
        onNext: {},
        onBack: {},
        onNameCollected: { _, _ in }
    )
}

