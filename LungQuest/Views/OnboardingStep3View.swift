import SwiftUI

struct OnboardingStep3View: View {
    init(centerLogo: Bool = false, onBegin: (() -> Void)? = nil, onSkip: (() -> Void)? = nil) {
        self.centerLogo = centerLogo
        self.onBegin = onBegin
        self.onSkip = onSkip
    }
    
    private let centerLogo: Bool
    private let onBegin: (() -> Void)?
    private let onSkip: (() -> Void)?
    
    @State private var showBeginButton = true
    @State private var beginEnabled = true
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.82, green: 0.92, blue: 1.0),
                    Color(red: 0.65, green: 0.80, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            content
        }
        .onAppear(perform: handleAppear)
    }
    
    private var content: some View {
        VStack(spacing: 32) {
            Spacer()
            
            header
                .frame(maxWidth: .infinity, alignment: centerLogo ? .center : .leading)
                .padding(.horizontal, 28)
            
            Spacer(minLength: 24)
            
            bottomActions()
                .padding(.horizontal, 28)
        }
        .padding(.vertical, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topTrailing) {
            if let onSkip {
                SkipAllButton(action: onSkip)
                    .padding(.top, 20)
                    .padding(.trailing, 20)
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 28) {
            LogoBlock(centered: centerLogo)
            
            TitleBlock()
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityElement(children: .contain)
    }
    
    private func bottomActions() -> some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                
                Button(action: {
                    onBegin?()
                }) {
                    HStack(spacing: 16) {
                        Text("Let’s Begin")
                            .font(.headline)
                            .foregroundColor(.black)
                            .minimumScaleFactor(0.8)
                        
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 18)
                    .background(Color.white.opacity(0.95))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 18, x: 0, y: 15)
                }
                .disabled(!beginEnabled)
                .opacity(showBeginButton ? 1 : 0)
                .animation(.easeInOut(duration: 0.6), value: showBeginButton)
                .accessibilityLabel("Let’s begin the assessment")
                .accessibilityHint(beginEnabled ? "Activates the next onboarding step." : "Becomes active once onboarding continues.")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            Button(action: {
                // TODO: Connect to returning subscriber flow.
            }) {
            Text("Already subscribed on the site?")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.black.opacity(0.75))
                    .padding(.vertical, 14)
                    .frame(maxWidth: 320)
                    .background(Color.white.opacity(0.18), in: Capsule(style: .continuous))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Already subscribed on the site?")
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private func handleAppear() {
        // Button starts enabled, no delayed animation needed.
    }
}

// MARK: - Header Blocks

private struct LogoBlock: View {
    let centered: Bool
    
    var body: some View {
        Group {
            if centered {
                HStack {
                    Spacer()
                    logoImage
                    Spacer()
                }
            } else {
                logoImage
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var logoImage: some View {
        Image("exhaleLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 160, height: 56)
            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 10)
            .accessibilityHidden(true)
    }
}

private struct TitleBlock: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Welcome!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Let’s begin discovering if you are facing problems with vaping.")
                .font(.title3)
                .foregroundColor(Color.black.opacity(0.85))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
                .accessibilityHint("Onboarding introduction message")
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SkipAllButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Skip All")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.black.opacity(0.8))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.3), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Skip onboarding")
    }
}

#Preview {
    NavigationStack {
        OnboardingStep3View()
    }
}

