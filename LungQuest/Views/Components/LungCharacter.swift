import SwiftUI

struct LungCharacter: View {
    let healthLevel: Int
    let isAnimating: Bool
    @State private var pulseAnimation = false
    @State private var glowAnimation = false
    @State private var sparkleAnimation = false
    
    var body: some View {
        ZStack {
            // Glow effect background
            if healthLevel > 20 {
                LungShape(healthLevel: healthLevel)
                    .fill(lungGlowColor.opacity(0.3))
                    .blur(radius: 8)
                    .scaleEffect(glowAnimation ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowAnimation)
            }
            
            // Main lung shape
            LungShape(healthLevel: healthLevel)
                .fill(lungColor)
                .overlay(
                    LungShape(healthLevel: healthLevel)
                        .stroke(lungBorderColor, lineWidth: 2)
                )
                .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                .animation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true), value: pulseAnimation)
            
            // Sparkles for healthy lungs
            if healthLevel > 70 {
                ForEach(0..<6, id: \.self) { index in
                    SparkleView()
                        .offset(
                            x: CGFloat.random(in: -40...40),
                            y: CGFloat.random(in: -30...30)
                        )
                        .opacity(sparkleAnimation ? 1 : 0)
                        .animation(.easeInOut(duration: 1.5).delay(Double(index) * 0.2).repeatForever(autoreverses: true), value: sparkleAnimation)
                }
            }
            
            // Face overlay for personality
            LungFaceOverlay(healthLevel: healthLevel)
        }
        .onAppear {
            if isAnimating {
                startAnimations()
            }
        }
        .onChange(of: isAnimating) { _, isAnimatingNow in
            if isAnimatingNow { startAnimations() }
        }
    }
    
    private func startAnimations() {
        withAnimation {
            pulseAnimation = true
            glowAnimation = true
            sparkleAnimation = true
        }
    }
    
    private var lungColor: Color {
        switch healthLevel {
        case 0..<10:
            return .gray.opacity(0.6)
        case 10..<30:
            return Color(red: 0.8, green: 0.6, blue: 0.6).opacity(0.7)
        case 30..<50:
            return Color(red: 0.9, green: 0.7, blue: 0.7).opacity(0.8)
        case 50..<70:
            return Color(red: 1.0, green: 0.8, blue: 0.8).opacity(0.9)
        case 70..<90:
            return Color.pink.opacity(0.9)
        default:
            return Color(red: 1.0, green: 0.7, blue: 0.8)
        }
    }
    
    private var lungGlowColor: Color {
        switch healthLevel {
        case 0..<30:
            return .gray
        case 30..<70:
            return .pink
        default:
            return .white
        }
    }
    
    private var lungBorderColor: Color {
        healthLevel > 50 ? .pink : .gray
    }
    
    private var animationDuration: Double {
        // Slower breathing when unhealthy, faster when healthy
        let baseDuration = 2.0
        let healthMultiplier = 1.0 - (Double(healthLevel) / 200.0) // Ranges from 1.0 to 0.5
        return baseDuration * healthMultiplier
    }
}

struct LungShape: Shape {
    let healthLevel: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        _ = width / 2
        _ = height / 2
        
        // Create two lung lobes
        let leftLungRect = CGRect(x: 0, y: 0, width: width * 0.45, height: height * 0.9)
        let rightLungRect = CGRect(x: width * 0.55, y: 0, width: width * 0.45, height: height * 0.9)
        
        // Add some irregularity based on health level
        let irregularity = healthLevel < 20 ? 0.1 : 0.0
        
        // Left lung
        addLungLobe(to: &path, rect: leftLungRect, isLeft: true, irregularity: irregularity)
        
        // Right lung  
        addLungLobe(to: &path, rect: rightLungRect, isLeft: false, irregularity: irregularity)
        
        return path
    }
    
    private func addLungLobe(to path: inout Path, rect: CGRect, isLeft: Bool, irregularity: Double) {
        let controlPointOffset = irregularity * rect.width * 0.2
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.2))
        
        // Top curve
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.3),
            control: CGPoint(x: rect.midX + controlPointOffset, y: rect.minY)
        )
        
        // Right side
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.1, y: rect.maxY),
            control: CGPoint(x: rect.maxX + controlPointOffset, y: rect.midY)
        )
        
        // Bottom curve
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.maxY),
            control: CGPoint(x: rect.midX - controlPointOffset, y: rect.maxY + rect.height * 0.1)
        )
        
        // Left side
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.2),
            control: CGPoint(x: rect.minX - controlPointOffset, y: rect.midY)
        )
        
        path.closeSubpath()
    }
}

struct LungFaceOverlay: View {
    let healthLevel: Int
    
    var body: some View {
        VStack(spacing: 4) {
            // Eyes
            HStack(spacing: 20) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 4, height: 4)
                    )
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 4, height: 4)
                    )
            }
            
            // Mouth based on health
            mouthShape
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private var mouthShape: some View {
        switch healthLevel {
        case 0..<20:
            // Sad/sick mouth
            Path { path in
                path.move(to: CGPoint(x: 0, y: 5))
                path.addQuadCurve(to: CGPoint(x: 10, y: 5), control: CGPoint(x: 5, y: 8))
            }
            .stroke(Color.black, lineWidth: 2)
            .frame(width: 10, height: 8)
            
        case 20..<50:
            // Neutral mouth
            Rectangle()
                .frame(width: 8, height: 2)
                .foregroundColor(.black)
            
        case 50..<70:
            // Slight smile
            Path { path in
                path.move(to: CGPoint(x: 0, y: 2))
                path.addQuadCurve(to: CGPoint(x: 10, y: 2), control: CGPoint(x: 5, y: 0))
            }
            .stroke(Color.black, lineWidth: 2)
            .frame(width: 10, height: 4)
            
        default:
            // Big smile
            Path { path in
                path.move(to: CGPoint(x: 0, y: 3))
                path.addQuadCurve(to: CGPoint(x: 12, y: 3), control: CGPoint(x: 6, y: -2))
            }
            .stroke(Color.black, lineWidth: 2)
            .frame(width: 12, height: 6)
        }
    }
}

struct SparkleView: View {
    @State private var rotation = 0.0
    
    var body: some View {
        Image(systemName: "sparkles")
            .foregroundColor(.yellow)
            .font(.system(size: 12))
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

#Preview {
    VStack(spacing: 30) {
        LungCharacter(healthLevel: 0, isAnimating: true)
            .frame(width: 120, height: 100)
        
        LungCharacter(healthLevel: 50, isAnimating: true)
            .frame(width: 120, height: 100)
        
        LungCharacter(healthLevel: 100, isAnimating: true)
            .frame(width: 120, height: 100)
    }
    .padding()
    .background(Color.black.opacity(0.1))
}
