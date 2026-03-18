import SwiftUI
import AVFoundation

struct BubblePopView: View {
    @StateObject private var soundManager = BubbleSoundManager()
    
    @State private var bubbles: [BubbleItem] = []
    @State private var clearedCount: Int = 0
    @State private var isMuted: Bool = false
    @State private var playAreaSize: CGSize = .zero
    
    private let screenBackground = Color(red: 0.92, green: 0.96, blue: 0.99)
    private let maxVisibleBubbles: Int = 7
    private let spawnTimer = Timer.publish(every: 1.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            screenBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    
                    bubblePlayArea
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white.opacity(0.88))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                        )
                    
                    HStack(spacing: 10) {
                        Button(action: resetSession) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.82))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.white.opacity(0.9))
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button(action: { isMuted.toggle() }) {
                            HStack(spacing: 6) {
                                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                Text(isMuted ? "Muted" : "Sound On")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.82))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.white.opacity(0.9))
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Bubble Pop")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(screenBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            if bubbles.isEmpty {
                seedInitialBubbles()
            }
        }
        .onChange(of: clearedCount) { _, count in
            if count > 0 {
                ExerciseDailyProgress.markCompletedToday(.bubblePop)
            }
        }
        .onReceive(spawnTimer) { _ in
            spawnBubbleIfNeeded()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bubble Pop")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Tap each bubble to release it. Slow, gentle pops to help you reset.")
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Label("Bubbles cleared: \(clearedCount)", systemImage: "checkmark.seal.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black.opacity(0.85))
            }
            .padding(.top, 2)
        }
    }
    
    private var bubblePlayArea: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.75),
                                Color.white.opacity(0.93)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                ForEach(bubbles) { bubble in
                    BubbleView(bubble: bubble)
                        .frame(width: bubble.diameter, height: bubble.diameter)
                        .position(bubble.center)
                        .scaleEffect(bubble.isPopping ? 1.18 : 1.0)
                        .opacity(bubble.isPopping ? 0.0 : 1.0)
                        .animation(.easeOut(duration: 0.22), value: bubble.isPopping)
                        .onTapGesture {
                            popBubble(id: bubble.id)
                        }
                }
            }
            .onAppear {
                playAreaSize = proxy.size
                if bubbles.isEmpty {
                    seedInitialBubbles()
                }
            }
            .onChange(of: proxy.size) { _, newSize in
                playAreaSize = newSize
            }
        }
        .padding(10)
    }
    
    private func seedInitialBubbles() {
        guard playAreaSize.width > 0, playAreaSize.height > 0 else { return }
        bubbles.removeAll()
        for _ in 0..<4 {
            if let bubble = buildBubble(existing: bubbles, in: playAreaSize) {
                bubbles.append(bubble)
            }
        }
    }
    
    private func spawnBubbleIfNeeded() {
        guard playAreaSize.width > 0, playAreaSize.height > 0 else { return }
        guard bubbles.count < maxVisibleBubbles else { return }
        
        if let next = buildBubble(existing: bubbles, in: playAreaSize) {
            withAnimation(.easeInOut(duration: 0.35)) {
                bubbles.append(next)
            }
        }
    }
    
    private func popBubble(id: UUID) {
        guard let index = bubbles.firstIndex(where: { $0.id == id }) else { return }
        guard !bubbles[index].isPopping else { return }
        
        bubbles[index].isPopping = true
        soundManager.playPop(isMuted: isMuted)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            bubbles.removeAll(where: { $0.id == id })
            clearedCount += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                spawnBubbleIfNeeded()
            }
        }
    }
    
    private func resetSession() {
        withAnimation(.easeInOut(duration: 0.25)) {
            clearedCount = 0
            bubbles.removeAll()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            seedInitialBubbles()
        }
    }
    
    private func buildBubble(existing: [BubbleItem], in size: CGSize) -> BubbleItem? {
        let palette: [Color] = [
            Color(red: 0.45, green: 0.72, blue: 0.99),
            Color(red: 0.31, green: 0.61, blue: 0.90),
            Color(red: 0.67, green: 0.49, blue: 0.94),
            Color(red: 0.22, green: 0.78, blue: 0.72),
            Color(red: 0.96, green: 0.84, blue: 0.25),
        ]
        
        let minDiameter: CGFloat = 54
        let maxDiameter: CGFloat = 88
        let edgePadding: CGFloat = 14
        
        for _ in 0..<50 {
            let diameter = CGFloat.random(in: minDiameter...maxDiameter)
            let radius = diameter / 2
            let minX = radius + edgePadding
            let maxX = size.width - radius - edgePadding
            let minY = radius + edgePadding
            let maxY = size.height - radius - edgePadding
            
            guard minX < maxX, minY < maxY else { continue }
            
            let center = CGPoint(
                x: CGFloat.random(in: minX...maxX),
                y: CGFloat.random(in: minY...maxY)
            )
            
            let candidate = BubbleItem(
                center: center,
                diameter: diameter,
                tint: palette.randomElement() ?? Color.blue
            )
            
            let overlaps = existing.contains { bubble in
                let distance = hypot(bubble.center.x - candidate.center.x, bubble.center.y - candidate.center.y)
                let minDistance = (bubble.diameter + candidate.diameter) * 0.42
                return distance < minDistance
            }
            
            if !overlaps {
                return candidate
            }
        }
        
        return nil
    }
}

private struct BubbleItem: Identifiable {
    let id = UUID()
    let center: CGPoint
    let diameter: CGFloat
    let tint: Color
    var isPopping: Bool = false
}

private struct BubbleView: View {
    let bubble: BubbleItem
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.92),
                        bubble.tint.opacity(0.42),
                        bubble.tint.opacity(0.58),
                    ]),
                    center: .topLeading,
                    startRadius: 1,
                    endRadius: bubble.diameter * 0.65
                )
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.78), lineWidth: 1.4)
            )
            .overlay(
                Circle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: bubble.diameter * 0.24, height: bubble.diameter * 0.24)
                    .offset(x: -bubble.diameter * 0.16, y: -bubble.diameter * 0.18)
            )
            .shadow(color: bubble.tint.opacity(0.20), radius: 6, x: 0, y: 3)
    }
}

final class BubbleSoundManager: ObservableObject {
    private var player: AVAudioPlayer?
    
    init() {
        // Add `bubble_pop.mp3` to the project (target membership: Exhale) so it is bundled in the app.
        guard let url = Bundle.main.url(forResource: "bubble_pop", withExtension: "mp3") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
    }
    
    func playPop(isMuted: Bool) {
        guard !isMuted else { return }
        guard let player else { return }
        player.currentTime = 0
        player.play()
    }
}

#Preview {
    NavigationView {
        BubblePopView()
    }
}
