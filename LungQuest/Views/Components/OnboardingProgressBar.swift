import SwiftUI

/// Modern, minimal progress bar for onboarding
/// Thin top loader style with smooth animations
struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    private var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStep) / Double(totalSteps)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track (very light blue)
                Rectangle()
                    .fill(Color(red: 0.70, green: 0.85, blue: 0.99).opacity(0.25))
                    .frame(height: 5)
                
                // Progress fill (primary blue with subtle gradient)
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.45, green: 0.72, blue: 0.99),
                                Color(red: 0.55, green: 0.78, blue: 0.99)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(1, progress)) * geo.size.width, height: 5)
            }
            .cornerRadius(2.5)
        }
        .frame(height: 5)
        .animation(.easeInOut(duration: 0.25), value: progress)
    }
}
