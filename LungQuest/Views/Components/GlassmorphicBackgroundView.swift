import SwiftUI

struct GlassmorphicBackgroundView: View {
    @State private var animateFirst = false
    @State private var animateSecond = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.81, green: 0.91, blue: 0.99),
                    Color(red: 0.55, green: 0.72, blue: 0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            GeometryReader { proxy in
                let size = proxy.size
                
                AnimatedBlurBlobView(
                    animate: animateFirst,
                    frame: CGSize(width: size.width * 0.88, height: size.height * 0.52),
                    baseOffset: CGSize(width: -size.width * 0.25, height: -size.height * 0.25),
                    offsetDelta: CGSize(width: size.width * 0.05, height: size.height * 0.04),
                    baseScale: 1.0,
                    scaleDelta: 0.03,
                    tint: Color(red: 0.60, green: 0.86, blue: 0.96),
                    animationDuration: 14
                )
                
                AnimatedBlurBlobView(
                    animate: animateSecond,
                    frame: CGSize(width: size.width * 0.75, height: size.height * 0.48),
                    baseOffset: CGSize(width: size.width * 0.35, height: size.height * 0.38),
                    offsetDelta: CGSize(width: -size.width * 0.04, height: size.height * 0.05),
                    baseScale: 0.98,
                    scaleDelta: 0.02,
                    tint: Color(red: 0.48, green: 0.79, blue: 0.92),
                    animationDuration: 16
                )
            }
            .allowsHitTesting(false)
        }
        .onAppear(perform: startAnimations)
    }
    
    private func startAnimations() {
        guard !animateFirst else { return }
        
        withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
            animateFirst = true
        }
        
        withAnimation(.easeInOut(duration: 16).repeatForever(autoreverses: true)) {
            animateSecond = true
        }
    }
}

private struct AnimatedBlurBlobView: View {
    let animate: Bool
    let frame: CGSize
    let baseOffset: CGSize
    let offsetDelta: CGSize
    let baseScale: CGFloat
    let scaleDelta: CGFloat
    let tint: Color
    let animationDuration: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: frame.width / 2, style: .continuous)
            .fill(.ultraThinMaterial)
            .frame(width: frame.width, height: frame.height)
            .overlay(tint.opacity(0.18).blendMode(.plusLighter))
            .blur(radius: 24)
            .scaleEffect(animate ? baseScale + scaleDelta : baseScale)
            .offset(
                x: baseOffset.width + (animate ? offsetDelta.width : 0),
                y: baseOffset.height + (animate ? offsetDelta.height : 0)
            )
            .animation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true), value: animate)
    }
}




