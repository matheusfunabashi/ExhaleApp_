import SwiftUI
import UIKit

enum InterFont {
    static func font(size: CGFloat, weight: UIFont.Weight = .regular) -> Font {
        let named: String
        switch weight {
        case ..<UIFont.Weight.medium:
            named = "Inter-Regular"
        case ..<UIFont.Weight.semibold:
            named = "Inter-Medium"
        case ..<UIFont.Weight.bold:
            named = "Inter-SemiBold"
        default:
            named = "Inter-Bold"
        }
        
        if UIFont(name: named, size: size) != nil {
            return .custom(named, size: size)
        }
        return .system(size: size, weight: fontWeight(from: weight), design: .default)
    }
    
    private static func fontWeight(from uiWeight: UIFont.Weight) -> Font.Weight {
        switch uiWeight {
        case ..<UIFont.Weight.medium: return .regular
        case ..<UIFont.Weight.semibold: return .medium
        case ..<UIFont.Weight.bold: return .semibold
        default: return .bold
        }
    }
}

struct OnboardingGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.10))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.16),
                                        Color.white.opacity(0.03),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color.white.opacity(configuration.isPressed ? 0.06 : 0.12), radius: configuration.isPressed ? 4 : 8, x: 0, y: -1)
                    .shadow(color: Color.black.opacity(configuration.isPressed ? 0.08 : 0.14), radius: configuration.isPressed ? 5 : 10, x: 0, y: configuration.isPressed ? 2 : 6)
            )
            .opacity(configuration.isPressed ? 0.94 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.18), value: configuration.isPressed)
    }
}

struct OnboardingSelectableGlassButtonStyle: ButtonStyle {
    let fillOpacity: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial.opacity(fillOpacity))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.16),
                                        Color.white.opacity(0.03),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color.white.opacity(configuration.isPressed ? 0.06 : 0.12), radius: configuration.isPressed ? 4 : 8, x: 0, y: -1)
                    .shadow(color: Color.black.opacity(configuration.isPressed ? 0.08 : 0.14), radius: configuration.isPressed ? 5 : 10, x: 0, y: configuration.isPressed ? 2 : 6)
            )
            .opacity(configuration.isPressed ? 0.94 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.18), value: configuration.isPressed)
    }
}

struct GlassButton: View {
    let title: String
    var systemImage: String? = nil
    var assetImage: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                } else if let assetImage {
                    Image(assetImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                
                Text(title)
                    .onboardingInter(size: 17, weight: .semibold)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(OnboardingGlassButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.55)
    }
}

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
    func onboardingInter(size: CGFloat = 17, weight: UIFont.Weight = .regular) -> some View {
        self.font(InterFont.font(size: size, weight: weight))
    }
    
    func softCard(accent: Color = Color(red: 0.45, green: 0.72, blue: 0.99), cornerRadius: CGFloat = 24) -> some View {
        modifier(SoftCardModifier(accent: accent, cornerRadius: cornerRadius))
    }
    
    func breathableBackground() -> some View {
        modifier(BreathableBackgroundModifier())
    }
    
    /// Dismisses the keyboard when the user taps outside text fields (e.g. on empty area).
    func dismissKeyboardOnTap() -> some View {
        self.contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}
