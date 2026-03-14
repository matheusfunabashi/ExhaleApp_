import SwiftUI

struct OnboardingStep10View: View {
    let onNext: (Double, String) -> Void
    let onBack: () -> Void
    
    @State private var amountText: String = ""
    @State private var selectedCurrency: String = ""
    
    private let currencies: [String] = ["$", "€", "£", "R$"]
    
    private var canProceed: Bool {
        // Must have a valid number and a currency selected
        let trimmedAmount = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAmount.isEmpty,
              let amount = Double(trimmedAmount),
              amount > 0,
              !selectedCurrency.isEmpty else {
            return false
        }
        return true
    }
    
    var body: some View {
        ZStack {
            StaticOnboardingBackground()
            
            VStack(spacing: 24) {
                header
                
                QuestionTitleView(
                    title: "Question #7",
                    subtitle: "How much money do you usually spend per week on vaping?",
                    progress: 10.0 / 13.0
                )
                
                AmountInputField(text: $amountText)
                    .padding(.top, 12)
                
                CurrencySelector(currencies: currencies, selectedCurrency: $selectedCurrency)
                    .padding(.top, 16)
                
                
                Spacer()
                
                GlassButton(title: "Next", systemImage: "arrow.right", isEnabled: canProceed) {
                    if canProceed {
                        let trimmedAmount = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if let amount = Double(trimmedAmount) {
                            onNext(amount, selectedCurrency)
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

private struct QuestionTitleView: View {
    let title: String
    let subtitle: String
    let progress: Double
    
    var body: some View {
        VStack(spacing: 18) {
            ProgressBar(progress: progress)
                .frame(height: 6)
            
            VStack(spacing: 12) {
                Text(title)
                    .onboardingInter(size: 28, weight: .bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text(subtitle)
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

private struct AmountInputField: View {
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text("Enter an approximate amount")
                    .foregroundColor(Color.white.opacity(0.55))
                    .onboardingInter(size: 18, weight: .medium)
            }
            
            TextField("", text: $text)
                .keyboardType(.decimalPad)
                .onboardingInter(size: 20, weight: .semibold)
                .foregroundColor(.white)
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

private struct CurrencySelector: View {
    let currencies: [String]
    @Binding var selectedCurrency: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(currencies, id: \.self) { currency in
                    Button(action: {
                        selectedCurrency = currency
                    }) {
                        Text(currency)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                    }
                    .buttonStyle(OnboardingSelectableGlassButtonStyle(fillOpacity: selectedCurrency == currency ? 0.22 : 0.10))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 8)
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
    OnboardingStep10View(
        onNext: { _, _ in },
        onBack: {}
    )
}

