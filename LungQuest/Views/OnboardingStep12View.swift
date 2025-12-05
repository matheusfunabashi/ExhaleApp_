import SwiftUI

struct OnboardingStep12View: View {
    let onComplete: () -> Void
    let onBack: () -> Void
    
    @State private var progress: Double = 0.0
    @State private var messageIndex: Int = 0
    @State private var animationTask: Task<Void, Never>?
    @State private var hasStarted = false
    
    private let progressSteps: [Double] = [0, 19, 34, 57, 81, 97, 100]
    private let messages: [String] = [
        "Analyzing your answers...",
        "Understanding your profile...",
        "Tailoring Exhale to your needs..."
    ]
    
    var body: some View {
        ZStack {
            StaticOnboardingBackground()
            
            VStack(spacing: 24) {
                header
                
                Spacer(minLength: 48)
                
                VStack(spacing: 24) {
                    ProgressRingView(progress: progress)
                    
                    Text(messages[messageIndex % messages.count])
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 280)
                }
                
                Spacer(minLength: 60)
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 32)
            .onAppear(perform: startSequence)
            .onDisappear {
                animationTask?.cancel()
                animationTask = nil
                hasStarted = false
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func startSequence() {
        guard !hasStarted else { return }
        hasStarted = true
        
        animationTask = Task {
            for (index, step) in progressSteps.enumerated() {
                if Task.isCancelled { return }
                
                let target = step / 100.0
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        progress = target
                        messageIndex = index
                    }
                }
                
                if step < 100 {
                    try? await Task.sleep(nanoseconds: 800_000_000)
                }
            }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                onComplete()
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: {
                animationTask?.cancel()
                onBack()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.18), in: Circle())
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
                .foregroundColor(.white.opacity(0.9))
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(Color.white.opacity(0.2), in: Capsule())
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

private struct ProgressRingView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 14)
                .frame(width: 180, height: 180)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.65)
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 180, height: 180)
                .shadow(color: Color.white.opacity(0.25), radius: 12, x: 0, y: 6)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    OnboardingStep12View(
        onComplete: {},
        onBack: {}
    )
}

