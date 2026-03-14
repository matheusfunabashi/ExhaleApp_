import SwiftUI

struct OnboardingStep12bView: View {
    let userName: String
    let onNext: () -> Void
    let onBack: () -> Void
    
    // Spacing constants
    private let spacingSmall: CGFloat = 8
    private let spacingMedium: CGFloat = 16
    private let spacingLarge: CGFloat = 24
    private let contentMaxWidth: CGFloat = 600
    private let cardSpacing: CGFloat = 12
    
    private var quitDate: Date {
        // Calculate quit date: 30 days from now (or use targetDays from user if available)
        Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    }
    
    private var formattedQuitDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: quitDate)
    }
    
    private var titleText: String {
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return "Your personal plan is ready!"
        }
        return "\(trimmedName), your personal plan is ready!"
    }
    
    private let benefits: [(icon: String, title: String, description: String)] = [
        (icon: "heart.fill", title: "Improved Heart Health", description: "Your heart rate and blood pressure will normalize within days"),
        (icon: "lungs.fill", title: "Better Lung Function", description: "Lung capacity increases up to 30% within the first month"),
        (icon: "brain.head.profile", title: "Mental Clarity", description: "Experience sharper focus and improved cognitive function"),
        (icon: "battery.100", title: "Increased Energy", description: "Natural energy levels return without nicotine dependency"),
        (icon: "dollarsign.circle.fill", title: "Save Money", description: "Keep more money in your pocket every single day"),
        (icon: "face.smiling", title: "Better Mood", description: "Emotional balance and reduced anxiety over time")
    ]
    
    var body: some View {
        ZStack {
            OnboardingFlowBackground()
            
            VStack(spacing: 0) {
                // Content container with max width and horizontal centering
                VStack(spacing: 0) {
                    // Header with close button
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.top, spacingMedium)
                    .padding(.bottom, spacingSmall)
                    
                    // Headline and subtitle grouped together
                    VStack(spacing: spacingSmall) {
                        Text(titleText)
                            .onboardingInter(size: 22, weight: .bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Here's what's in it for you")
                            .onboardingInter(size: 16, weight: .bold)
                            .foregroundColor(.white.opacity(0.95))
                    }
                    .padding(.bottom, spacingLarge)
                    
                    // Benefits section - 2x3 Grid
                    VStack(alignment: .leading, spacing: spacingMedium) {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: cardSpacing),
                                GridItem(.flexible(), spacing: cardSpacing)
                            ],
                            spacing: cardSpacing
                        ) {
                            ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                                BenefitRow(
                                    icon: benefit.icon,
                                    title: benefit.title,
                                    description: benefit.description
                                )
                            }
                        }
                    }
                    .padding(.bottom, spacingLarge)
                    
                    // Quit date projection
                    VStack(spacing: spacingSmall) {
                        Text("You will quit vaping by:")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.45, green: 0.72, blue: 0.99))
                        
                        Text(formattedQuitDate)
                            .onboardingInter(size: 20, weight: .bold)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, spacingMedium)
                    .padding(.horizontal, spacingMedium)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
                            )
                    )
                    .padding(.bottom, spacingLarge)
                    
                    Spacer(minLength: 0)
                    
                    // Continue button
                    GlassButton(title: "Continue", systemImage: "arrow.right", action: onNext)
                    .padding(.bottom, spacingMedium)
                }
                .frame(maxWidth: contentMaxWidth)
                .padding(.horizontal, spacingLarge)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

private struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    // Spacing constants
    private let cardPadding: CGFloat = 14
    private let iconSize: CGFloat = 36
    private let spacingSmall: CGFloat = 8
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacingSmall) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: iconSize, height: iconSize)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.14))
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .onboardingInter(size: 15, weight: .semibold)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(description)
                    .onboardingInter(size: 13, weight: .regular)
                    .foregroundColor(Color.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(cardPadding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    OnboardingStep12bView(
        userName: "Felipe",
        onNext: {},
        onBack: {}
    )
}
