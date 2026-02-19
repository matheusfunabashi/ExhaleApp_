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
    
    private let buttonColor = Color.white
    private let textColor = Color.black
    
    var body: some View {
        ZStack {
            StaticOnboardingBackground()
            
            VStack(spacing: 24) {
                header
                
                QuestionTitleView(
                    title: "Question #7",
                    subtitle: "How much money do you usually spend per week on vaping?"
                )
                
                AmountInputField(text: $amountText)
                    .padding(.top, 12)
                
                CurrencySelector(currencies: currencies, selectedCurrency: $selectedCurrency)
                    .padding(.top, 16)
                
                
                Spacer()
                
                Button(action: {
                    if canProceed {
                        let trimmedAmount = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if let amount = Double(trimmedAmount) {
                            onNext(amount, selectedCurrency)
                        }
                    }
                }) {
                    Text("Next")
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
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 32)
            .dismissKeyboardOnTap()
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            OnboardingProgressBar(currentStep: 10, totalSteps: 13)
                .padding(.top, 8)
                .padding(.horizontal, 16)
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

private struct QuestionTitleView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(subtitle)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
    }
}

private struct AmountInputField: View {
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text("Enter an approximate amount")
                    .foregroundColor(Color.black.opacity(0.35))
                    .font(.system(size: 18, weight: .medium, design: .rounded))
            }
            
            TextField("", text: $text)
                .keyboardType(.decimalPad)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.15), lineWidth: 1)
        )
    }
}

private struct CurrencySelector: View {
    let currencies: [String]
    @Binding var selectedCurrency: String
    
    private let highlightColor = Color(red: 0.16, green: 0.36, blue: 0.72)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(currencies, id: \.self) { currency in
                    Button(action: {
                        selectedCurrency = currency
                    }) {
                        Text(currency)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedCurrency == currency ? .white : .black.opacity(0.85))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(
                                Capsule()
                                    .fill(selectedCurrency == currency ? highlightColor.opacity(0.92) : Color.white.opacity(0.92))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(selectedCurrency == currency ? highlightColor.opacity(0.6) : Color.black.opacity(0.1), lineWidth: selectedCurrency == currency ? 2 : 1)
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
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

