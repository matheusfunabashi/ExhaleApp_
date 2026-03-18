import SwiftUI

struct BreathingExerciseView: View {
    @State private var isRunning: Bool = true
    @State private var accumulatedElapsed: TimeInterval = 0
    @State private var runStartedAt: Date? = nil
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { context in
            let elapsed = elapsedTime(at: context.date)
            let phase = BreathingWavePattern.phase(atElapsed: elapsed)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Breathing Exercise")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Take a minute to settle your mind with a simple guided rhythm. Keep your eyes on the centered bubble and let the wave guide your breath.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 18) {
                        Text(phase.instruction)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        
                        Text("Breathe gently with the moving line.")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        
                        BreathingTrackView(elapsed: elapsed, phase: phase)
                            .frame(height: 260)
                        
                        Button(action: toggleRunning) {
                            HStack(spacing: 10) {
                                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                Text(isRunning ? "Pause" : "Start")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 12)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.45, green: 0.72, blue: 0.99),
                                                Color(red: 0.30, green: 0.60, blue: 0.90)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(Color.white.opacity(0.24), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.14), radius: 10, x: 0, y: 6)
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                    )
                    
                    Text("Tip: keep your shoulders relaxed and let each exhale feel soft and complete.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 2)
                }
                .padding()
            }
            .navigationTitle("Breathing Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .breathableBackground()
            .onAppear {
                if runStartedAt == nil {
                    runStartedAt = Date()
                    isRunning = true
                }
            }
            .onDisappear {
                pause(at: Date())
            }
        }
    }
    
    private func elapsedTime(at now: Date) -> TimeInterval {
        guard isRunning, let started = runStartedAt else { return accumulatedElapsed }
        return accumulatedElapsed + now.timeIntervalSince(started)
    }
    
    private func toggleRunning() {
        if isRunning {
            pause(at: Date())
        } else {
            runStartedAt = Date()
            isRunning = true
        }
    }
    
    private func pause(at now: Date) {
        guard isRunning else { return }
        if let started = runStartedAt {
            accumulatedElapsed += now.timeIntervalSince(started)
        }
        runStartedAt = nil
        isRunning = false
    }
}

private struct BreathingTrackView: View {
    let elapsed: TimeInterval
    let phase: BreathingPhase
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let centerX = size.width / 2
            let centerY = size.height / 2
            let scroll = CGFloat(elapsed) * BreathingWavePattern.scrollSpeed
            let centerWorldX = scroll
            let ballY = BreathingWavePattern.y(
                atWorldX: centerWorldX,
                centerY: centerY
            )
            
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.78))
                
                Path { path in
                    let step: CGFloat = 2
                    let startX: CGFloat = -40
                    let endX: CGFloat = size.width + 40
                    
                    var x = startX
                    let firstY = BreathingWavePattern.y(atWorldX: (x - centerX) + scroll, centerY: centerY)
                    path.move(to: CGPoint(x: x, y: firstY))
                    
                    while x <= endX {
                        let y = BreathingWavePattern.y(atWorldX: (x - centerX) + scroll, centerY: centerY)
                        path.addLine(to: CGPoint(x: x, y: y))
                        x += step
                    }
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.30, green: 0.60, blue: 0.90).opacity(0.70),
                            Color(red: 0.45, green: 0.72, blue: 0.99).opacity(0.95),
                            Color(red: 0.30, green: 0.60, blue: 0.90).opacity(0.70),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                )
                
                Circle()
                    .fill(ballColor)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: ballColor.opacity(0.26), radius: 16, x: 0, y: 8)
                    .position(x: centerX, y: ballY)
                    .animation(.easeInOut(duration: 0.25), value: phase)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.65), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 6)
    }
    
    private var ballColor: Color {
        switch phase {
        case .inhale:
            return Color(red: 0.45, green: 0.72, blue: 0.99)
        case .hold:
            return Color(red: 0.36, green: 0.67, blue: 0.95)
        case .exhale:
            return Color(red: 0.29, green: 0.58, blue: 0.89)
        }
    }
}

private enum BreathingWavePattern {
    // Target timing per segment:
    // inhale = 4s, hold = 4s, exhale = 4s, hold = 4s
    static let inhaleDuration: CGFloat = 4
    static let holdDuration: CGFloat = 4
    static let exhaleDuration: CGFloat = 4
    
    static var upWidth: CGFloat { scrollSpeed * inhaleDuration }
    static var topHoldWidth: CGFloat { scrollSpeed * holdDuration }
    static var downWidth: CGFloat { scrollSpeed * exhaleDuration }
    static var bottomHoldWidth: CGFloat { scrollSpeed * holdDuration }
    static let amplitude: CGFloat = 42
    
    // Points per second moving from right to left.
    static let scrollSpeed: CGFloat = 56
    
    static var cycleWidth: CGFloat {
        upWidth + topHoldWidth + downWidth + bottomHoldWidth
    }
    
    static func y(atWorldX worldX: CGFloat, centerY: CGFloat) -> CGFloat {
        let x = positiveModulo(worldX, cycleWidth)
        let topY = centerY - amplitude
        let bottomY = centerY + amplitude
        
        if x < upWidth {
            let t = x / upWidth
            return bottomY - (2 * amplitude * t)
        }
        
        if x < upWidth + topHoldWidth {
            return topY
        }
        
        if x < upWidth + topHoldWidth + downWidth {
            let local = x - (upWidth + topHoldWidth)
            let t = local / downWidth
            return topY + (2 * amplitude * t)
        }
        
        return bottomY
    }
    
    static func phase(atElapsed elapsed: TimeInterval) -> BreathingPhase {
        let centerWorldX = CGFloat(elapsed) * scrollSpeed
        let x = positiveModulo(centerWorldX, cycleWidth)
        
        if x < upWidth {
            return .inhale
        }
        if x < upWidth + topHoldWidth {
            return .hold
        }
        if x < upWidth + topHoldWidth + downWidth {
            return .exhale
        }
        return .hold
    }
    
    private static func positiveModulo(_ value: CGFloat, _ modulus: CGFloat) -> CGFloat {
        guard modulus > 0 else { return 0 }
        let result = value.truncatingRemainder(dividingBy: modulus)
        return result >= 0 ? result : result + modulus
    }
}

private enum BreathingPhase {
    case inhale
    case hold
    case exhale
    
    var instruction: String {
        switch self {
        case .inhale:
            return "Breath in"
        case .hold:
            return "Hold"
        case .exhale:
            return "Breath out"
        }
    }
}

#Preview {
    NavigationView {
        BreathingExerciseView()
    }
}
