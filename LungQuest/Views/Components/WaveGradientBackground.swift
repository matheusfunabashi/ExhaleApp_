import SwiftUI
import UIKit

/// Shared onboarding background that prefers a custom image asset.
/// Add your image to Assets.xcassets > OnboardingCustomBackground.imageset.
struct OnboardingFlowBackground: View {
    private static let assetName = "OnboardingCustomBackground"

    var body: some View {
        GeometryReader { proxy in
            Group {
                if UIImage(named: Self.assetName) != nil {
                    Image(Self.assetName)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [
                            Color(red: 0.82, green: 0.92, blue: 1.0),
                            Color(red: 0.65, green: 0.80, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }
}

struct WaveGradientBackground: View {
    @State private var animate = false
    
    var body: some View {
        WaveGradientBackgroundView(animate: $animate)
            .onAppear {
                withAnimation(.linear(duration: 14).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
    }
}

private struct WaveGradientBackgroundView: View {
    @Binding var animate: Bool
    
    var colorsPrimary: [Color] = [
        Color(red: 0.42, green: 0.68, blue: 0.98),
        Color(red: 0.68, green: 0.84, blue: 1.00)
    ]
    var colorsSecondary: [Color] = [
        Color(red: 0.33, green: 0.60, blue: 0.95),
        Color(red: 0.54, green: 0.78, blue: 0.98)
    ]
    var baseColor: Color = Color(red: 0.80, green: 0.90, blue: 1.00)
    var amplitudePrimary: CGFloat = 90
    var amplitudeSecondary: CGFloat = 65
    var speedPrimary: Double = 1.0
    var speedSecondary: Double = 0.7
    
    var body: some View {
        ZStack {
            baseColor
                .ignoresSafeArea()
            
            movingGradient(
                colors: colorsPrimary,
                amplitude: amplitudePrimary,
                speed: speedPrimary
            )
            .blendMode(.screen)
            .opacity(0.7)
            
            movingGradient(
                colors: colorsSecondary,
                amplitude: amplitudeSecondary,
                speed: speedSecondary
            )
            .blendMode(.screen)
            .opacity(0.6)
        }
    }
    
    @ViewBuilder
    private func movingGradient(
        colors: [Color],
        amplitude: CGFloat,
        speed: Double
    ) -> some View {
        GeometryReader { geo in
            let size = max(geo.size.width, geo.size.height) * 1.8
            
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(35))
            .offset(
                x: animate ? amplitude : -amplitude,
                y: animate ? amplitude : -amplitude
            )
            .animation(
                .linear(duration: 18 / speed)
                    .repeatForever(autoreverses: true),
                value: animate
            )
        }
        .ignoresSafeArea()
    }
}

