import SwiftUI
import SuperwallKit

struct OnboardingStep13View: View {
    let onContinue: () -> Void
    let onBack: () -> Void
    
    @State private var userScore: Double = Double.random(in: 0.60...0.85)
    @State private var currentPage: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    private let averageScore: Double = 0.30
    private let pagingAnimation = Animation.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0.25)
    
    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            
            VStack(spacing: 0) {
                resultsPage
                    .frame(width: geo.size.width, height: height)
                
                rescuePage
                    .frame(width: geo.size.width, height: height)
            }
            .offset(y: -CGFloat(currentPage) * height + dragOffset)
            .gesture(dragGesture(for: height))
            .animation(pagingAnimation, value: currentPage)
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
    
    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.18), in: Circle())
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
                .foregroundColor(.white.opacity(0.9))
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(Color.white.opacity(0.2), in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
    
    private var resultsPage: some View {
        ZStack(alignment: .bottom) {
            ResultsBackground()
            
            VStack(spacing: 24) {
                header
                
                Spacer(minLength: 24)
                
                VStack(spacing: 16) {
                    Text("Analysis Complete")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 6) {
                        Text("We have some insights for you.")
                        Text("Your responses indicate a noticeable dependency on vaping.")
                    }
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                }
                
                Spacer(minLength: 24)
                
                ScoreComparisonView(userScore: userScore, averageScore: averageScore)
                    .padding(.horizontal, 12)
                
                VStack(spacing: 10) {
                    Text("Your score is higher than average vaping dependency.")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    Text("This result is only an indication and not a medical diagnosis.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 72)
            
            if currentPage == 0 {
                Button(action: { withAnimation(pagingAnimation) { currentPage = 1 } }) {
                    Image(systemName: "chevron.down.double")
                        .font(.system(size: 34, weight: .black))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(18)
                        .background(Color.white.opacity(0.22), in: Circle())
                        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 10)
                        .accessibilityLabel("Reveal next step")
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
        }
    }
    
    private var rescuePage: some View {
        ZStack {
            RescueBackground()
            
            VStack(spacing: 28) {
                Spacer()
                
                Image("LungBuddy_0")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 374, height: 306)
                    .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 12)
                
                Text("Your lungs need your help!")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.45, green: 0.05, blue: 0.05))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                Button(action: {
                    onContinue()  // whatever you currently do when finishing onboarding
                    Superwall.shared.register(placement: "onboarding_end") // <-- must match your rule’s event name
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.45, green: 0.05, blue: 0.05))
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 15)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)

            }
            .padding(.top, 48)
        }
    }
    
    private func dragGesture(for height: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .updating($dragOffset) { value, state, _ in
                let translation = value.translation.height
                if currentPage == 0 {
                    state = max(-height, min(0, translation))
                } else {
                    state = max(-height, min(height, translation))
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let threshold = height * 0.18
                
                if currentPage == 0 {
                    if translation < -threshold {
                        withAnimation(pagingAnimation) { currentPage = 1 }
                    } else {
                        withAnimation(pagingAnimation) { currentPage = 0 }
                    }
                } else {
                    if translation > threshold {
                        withAnimation(pagingAnimation) { currentPage = 0 }
                    } else if translation < -threshold {
                        withAnimation(pagingAnimation) { currentPage = 1 }
                    } else {
                        withAnimation(pagingAnimation) { currentPage = 1 }
                    }
                }
            }
    }
}

private struct ResultsBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.52, green: 0.72, blue: 0.97),
                Color(red: 0.31, green: 0.58, blue: 0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct RescueBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.88, blue: 0.88),
                Color(red: 1.0, green: 0.76, blue: 0.76)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

private struct ScoreComparisonView: View {
    let userScore: Double
    let averageScore: Double
    
    var body: some View {
        GeometryReader { geo in
            let maxHeight = geo.size.height
            let maxScore = max(userScore, averageScore)
            let barAreaHeight = max(maxHeight - 72, 100)
            
            VStack(spacing: 16) {
                HStack(spacing: 28) {
                    Text("\(Int(userScore * 100))%")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 70)
                    
                    Text("\(Int(averageScore * 100))%")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 70)
                }
                
                HStack(alignment: .bottom, spacing: 28) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.red.opacity(0.85))
                        .frame(width: 70, height: max(70, barHeight(for: userScore, maxScore: maxScore, maxHeight: barAreaHeight)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                        )
                        .shadow(color: Color.red.opacity(0.45), radius: 12, x: 0, y: 8)
                    
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(red: 0.16, green: 0.36, blue: 0.72))
                        .frame(width: 70, height: max(70, barHeight(for: averageScore, maxScore: maxScore, maxHeight: barAreaHeight)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                        )
                        .shadow(color: Color(red: 0.16, green: 0.36, blue: 0.72).opacity(0.45), radius: 12, x: 0, y: 8)
                }
                .frame(height: barAreaHeight, alignment: .bottom)
                
                HStack(spacing: 28) {
                    Text("You")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 70)
                    
                    Text("Average")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 70)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 220)
    }
    
    private func barHeight(for value: Double, maxScore: Double, maxHeight: CGFloat) -> CGFloat {
        guard maxScore > 0 else { return 0 }
        return maxHeight * CGFloat(value / maxScore)
    }
}

#Preview {
    OnboardingStep13View(
        onContinue: {},
        onBack: {}
    )
}


