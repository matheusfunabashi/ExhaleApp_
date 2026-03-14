import SwiftUI

struct OnboardingStep10bView: View {
    let weeklyCost: Double
    let currency: String
    let onNext: () -> Void
    let onBack: () -> Void
    
    private var savings: [(period: String, amount: Double, icon: String)] {
        // Calculate based on weekly cost
        // 1 month ≈ 4.33 weeks, 6 months ≈ 26 weeks, 1 year ≈ 52 weeks, 5 years ≈ 260 weeks
        return [
            (period: "in one month", amount: weeklyCost * 4.33, icon: "dollarsign.circle.fill"),
            (period: "in 6 months", amount: weeklyCost * 26, icon: "banknote.fill"),
            (period: "in a year", amount: weeklyCost * 52, icon: "bag.fill"),
            (period: "in 5 years", amount: weeklyCost * 260, icon: "briefcase.fill")
        ]
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let roundedAmount = Int(amount.rounded())
        
        // Format based on currency symbol position
        // For currencies that go before the number ($, €, £)
        if currency == "$" || currency == "€" || currency == "£" {
            return "\(currency)\(roundedAmount)"
        }
        // For currencies that go after the number (like R$)
        else if currency == "R$" {
            // Brazilian Real uses different formatting with thousands separator
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = "."
            formatter.usesGroupingSeparator = true
            if let formatted = formatter.string(from: NSNumber(value: roundedAmount)) {
                return "\(currency) \(formatted)"
            }
            return "\(currency) \(roundedAmount)"
        }
        // Default: currency before number
        else {
            return "\(currency)\(roundedAmount)"
        }
    }
    
    var body: some View {
        ZStack {
            StaticOnboardingBackground()
            
            ScrollView {
                VStack(spacing: 32) {
                    header
                    
                    // Title and subtitle
                    VStack(spacing: 16) {
                        Text("Spend less. Live more.")
                            .onboardingInter(size: 32, weight: .bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Every vape costs more than you think—start saving today")
                            .onboardingInter(size: 16, weight: .medium)
                            .foregroundColor(Color.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    // Savings section
                    VStack(spacing: 20) {
                        Text("What you will save:")
                            .onboardingInter(size: 18, weight: .semibold)
                            .foregroundColor(.white)
                        
                        // 2x2 Grid of savings cards
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            ForEach(Array(savings.enumerated()), id: \.offset) { index, saving in
                                SavingsCard(
                                    icon: saving.icon,
                                    amount: formatAmount(saving.amount),
                                    period: saving.period
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    Spacer(minLength: 40)
                    
                    // Continue button
                    GlassButton(title: "Continue", systemImage: "arrow.right", action: onNext)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 52)
                .padding(.bottom, 32)
            }
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
}

private struct StaticOnboardingBackground: View {
    var body: some View {
        OnboardingFlowBackground()
    }
}

private struct SavingsCard: View {
    let icon: String
    let amount: String
    let period: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
            
            Text(amount)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(period)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    OnboardingStep10bView(
        weeklyCost: 25.0,
        currency: "$",
        onNext: {},
        onBack: {}
    )
}
