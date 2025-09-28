import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if let reason = appState.questionnaire.reasonToQuit, !reason.isEmpty {
                VStack(spacing: 8) {
                    Text("Why do you want to quit?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(reason)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.9)))
                }
                .padding(.top, 8)
            }

            Text("Personalized support to quit for good")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 32)
            
            VStack(alignment: .leading, spacing: 12) {
                PaywallFeatureRow(text: "Daily motivation tailored to your reasons: \(appState.questionnaire.reasonToQuit ?? "Your goals")")
                PaywallFeatureRow(text: "Craving tools for \(appState.questionnaire.hardestPart.isEmpty ? "your triggers" : appState.questionnaire.hardestPart.joined(separator: ", "))")
                PaywallFeatureRow(text: "Progress, badges, and money saved tracking")
                PaywallFeatureRow(text: "Cancel anytime • 7‑day free trial")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.9)))
            .shadow(radius: 6)
            
            VStack(spacing: 12) {
                PlanButton(title: "Annual • $59.99") { subscribe() }
                PlanButton(title: "Monthly • $7.99") { subscribe() }
                Button("Restore Purchases") { /* hook up later */ }
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.pink.opacity(0.08), Color.blue.opacity(0.06)]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
        )
        .interactiveDismissDisabled(true)
    }
    
    private func subscribe() {
        // Simulate success (replace with StoreKit later)
        appState.isSubscribed = true
        appState.persist()
        isPresented = false
    }
}

private struct PaywallFeatureRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "checkmark.seal.fill").foregroundColor(.pink)
            Text(text).foregroundColor(.secondary)
        }
    }
}

private struct PlanButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.pink))
                .foregroundColor(.white)
        }
    }
}


