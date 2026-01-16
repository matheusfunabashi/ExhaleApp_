import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 0.45, green: 0.72, blue: 0.99), Color(red: 0.30, green: 0.60, blue: 0.90)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(gradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            .blendMode(.overlay)
                    )
                    .shadow(color: Color(red: 0.06, green: 0.21, blue: 0.55).opacity(configuration.isPressed ? 0.15 : 0.3), radius: configuration.isPressed ? 6 : 14, x: 0, y: configuration.isPressed ? 3 : 10)
                    .opacity(configuration.isPressed ? 0.92 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
            .foregroundColor(Color(red: 0.45, green: 0.72, blue: 0.99))
            .padding(.horizontal, 28)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color(red: 0.45, green: 0.72, blue: 0.99).opacity(configuration.isPressed ? 0.4 : 0.55), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.white.opacity(0.2))
                    )
            )
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.05 : 0.1), radius: configuration.isPressed ? 4 : 9, x: 0, y: configuration.isPressed ? 2 : 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

struct SoftCardModifier: ViewModifier {
    let accent: Color
    let cornerRadius: CGFloat
    
    init(accent: Color = Color(red: 0.45, green: 0.72, blue: 0.99), cornerRadius: CGFloat = 24) {
        self.accent = accent
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.75)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(accent.opacity(0.18), lineWidth: 1)
                            .blendMode(.overlay)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
                    .shadow(color: accent.opacity(0.12), radius: 22, x: 0, y: 14)
            )
    }
}

struct BreathableBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.90, green: 0.96, blue: 1.0), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }
}

extension View {
    func softCard(accent: Color = Color(red: 0.45, green: 0.72, blue: 0.99), cornerRadius: CGFloat = 24) -> some View {
        modifier(SoftCardModifier(accent: accent, cornerRadius: cornerRadius))
    }
    
    func breathableBackground() -> some View {
        modifier(BreathableBackgroundModifier())
    }
}
