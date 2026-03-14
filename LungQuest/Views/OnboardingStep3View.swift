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
            Step3CustomBackground()
            
            content
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: handleAppear)
    }
    
    private var content: some View {
        VStack(spacing: 32) {
            header
                .frame(maxWidth: .infinity, alignment: centerLogo ? .center : .leading)
                .padding(.horizontal, 28)
            
            Spacer(minLength: 24)
            
            bottomActions()
                .padding(.horizontal, 28)
        }
        .padding(.vertical, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Let’s Begin")
                            .onboardingInter(size: 17, weight: .semibold)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 16)
                }
                .buttonStyle(OnboardingGlassButtonStyle())
                .disabled(!beginEnabled)
                .opacity(showBeginButton ? 1 : 0)
                .animation(.easeInOut(duration: 0.6), value: showBeginButton)
                .accessibilityLabel("Let’s begin the assessment")
                .accessibilityHint(beginEnabled ? "Activates the next onboarding step." : "Becomes active once onboarding continues.")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private func handleAppear() {
        // Button starts enabled, no delayed animation needed.
    }
}

private struct Step3CustomBackground: View {
    var body: some View {
        GeometryReader { proxy in
            Group {
                if UIImage(named: "OnboardingStep3Background") != nil {
                    Image("OnboardingStep3Background")
                        .resizable()
                        .scaledToFill()
                } else {
                    OnboardingFlowBackground()
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .ignoresSafeArea()
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
                .onboardingInter(size: 34, weight: .bold)
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Let’s begin discovering if you are facing problems with vaping.")
                .onboardingInter(size: 20, weight: .medium)
                .foregroundColor(Color.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
                .accessibilityHint("Onboarding introduction message")
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    NavigationStack {
        OnboardingStep3View()
    }
}

