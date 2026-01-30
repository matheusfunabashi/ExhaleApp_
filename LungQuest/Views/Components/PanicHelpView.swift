import SwiftUI
import UIKit
import AVFoundation
import Combine

struct PanicButton: View {
    var action: () -> Void
    @State private var pulse: Bool = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 72, height: 72)
                    .scaleEffect(pulse ? 1.1 : 0.95)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 56, height: 56)
                    .shadow(color: .red.opacity(0.4), radius: 10, x: 0, y: 4)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                    .font(.title3)
            }
            .accessibilityLabel("Panic help")
            .accessibilityHint("Opens immediate help for cravings")
        }
        .onAppear { pulse = true }
    }
}

struct PanicHelpView: View {
    @Binding var isPresented: Bool
    @State private var breathe: Bool = false
    @State private var cameraAuthorized: Bool = false
    @State private var cameraReady: Bool = false
    @State private var showRelapseOptions: Bool = false
    @StateObject private var camera = CameraController()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.98, green: 0.98, blue: 1.0), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Camera reflection area
                    ZStack {
                        if cameraAuthorized && cameraReady {
                            CameraPreview(session: camera.session)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .frame(maxWidth: .infinity)
                                .frame(height: 260)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill").font(.title).foregroundColor(.secondary)
                                Text("Enable camera to see yourself and take a mindful pause.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.9)))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                    }
                    
                    // Main message - stronger typography
                    Text("You made a commitment to yourself")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    // Breathing section
                    VStack(spacing: 16) {
                        BreathingCoach()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                    
                    // Cognitive reminder section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Remember why you're staying strong")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 12) {
                            ReminderCard(
                                icon: "brain.head.profile",
                                title: "Mental Clarity",
                                description: "Your focus and cognitive function improve each day"
                            )
                            ReminderCard(
                                icon: "battery.100",
                                title: "Energy Levels",
                                description: "Natural energy returns without nicotine dependency"
                            )
                            ReminderCard(
                                icon: "heart.fill",
                                title: "Emotional Balance",
                                description: "Mood stabilizes and anxiety decreases over time"
                            )
                            ReminderCard(
                                icon: "person.fill.checkmark",
                                title: "Self-Respect",
                                description: "Every moment you choose yourself builds confidence"
                            )
                        }
                    }
                    .padding(.top, 8)
                    
                    // Primary action button
                    Button(action: { isPresented = false }) {
                        Text("I'm okay now")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Color(red: 0.45, green: 0.72, blue: 0.99)
                            )
                            .cornerRadius(14)
                    }
                    .padding(.top, 8)
                    
                    // Secondary relapse actions (if needed)
                    if showRelapseOptions {
                        VStack(spacing: 10) {
                            Button(action: {
                                // Handle relapse action
                                isPresented = false
                            }) {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                    Text("I relapsed")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                // Handle thinking of relapsing
                                isPresented = false
                            }) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                    Text("I'm thinking of relapsing")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.gray.opacity(0.7))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .padding(.top, 50)
            }
            
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary.opacity(0.7))
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .padding(8)
            }
            .accessibilityLabel("Close")
            .padding(.top, 8)
            .padding(.trailing, 8)
        }
        .onAppear {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            // Check camera authorization immediately (non-blocking)
            checkCameraAuthorization()
            // Start camera asynchronously to not block UI
            DispatchQueue.global(qos: .userInitiated).async {
                self.camera.start { success in
                    DispatchQueue.main.async {
                        if success && self.cameraAuthorized {
                            self.cameraReady = true
                        }
                    }
                }
            }
        }
        .onDisappear { 
            camera.stop()
        }
    }
    
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { 
                    self.cameraAuthorized = granted
                    if granted {
                        // Start camera after authorization
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.camera.start { success in
                                DispatchQueue.main.async {
                                    self.cameraReady = success
                                }
                            }
                        }
                    }
                }
            }
        default:
            cameraAuthorized = false
        }
    }
}

// MARK: - 4-7-8 Breathing (Inhale 4s, Hold 7s, Exhale 8s = 19s cycle)
private enum BreathingPhase: String, Equatable {
    case inhale   // 4s – bubble expands
    case hold     // 7s – bubble stays full
    case exhale   // 8s – bubble contracts
}

private struct BreathingCoach: View {
    @State private var cycleStartTime: Date = Date()
    
    private let totalCycleDuration: TimeInterval = 19
    private let inhaleDuration: TimeInterval = 4
    private let holdDuration: TimeInterval = 7
    private let exhaleDuration: TimeInterval = 8
    private let bubbleOuterSize: CGFloat = 160
    private let bubbleMinScale: CGFloat = 80 / 160  // 0.5
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { context in
            let now = context.date
            let t = now.timeIntervalSince(cycleStartTime)
            let tInCycle = t.truncatingRemainder(dividingBy: totalCycleDuration)
            let (phase, progress) = phaseAndProgress(tInCycle)
            let scale = bubbleScale(phase: phase, progress: progress)
            let opacity = 0.35 + 0.12 * (scale - bubbleMinScale) / (1 - bubbleMinScale)  // slight glow: higher when full
            
            VStack(spacing: 14) {
                Text(phaseLabel(phase))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(secondsRemainingInPhase(phase: phase, tInCycle: tInCycle))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.45, green: 0.72, blue: 0.99))
                    .monospacedDigit()
                
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.45, green: 0.72, blue: 0.99).opacity(0.2), lineWidth: 5)
                        .frame(width: bubbleOuterSize, height: bubbleOuterSize)
                    Circle()
                        .fill(Color(red: 0.45, green: 0.72, blue: 0.99).opacity(opacity))
                        .frame(width: bubbleOuterSize, height: bubbleOuterSize)
                        .scaleEffect(scale)
                }
                .frame(maxWidth: .infinity)
                
                Text("4-7-8 breathing: In 4 • Hold 7 • Out 8")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .background(PhaseChangeHaptic(phase: phase))
        }
        .onAppear { cycleStartTime = Date() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Guided 4-7-8 breathing coach")
    }
    
    private func phaseAndProgress(_ tInCycle: TimeInterval) -> (BreathingPhase, Double) {
        if tInCycle < inhaleDuration {
            return (.inhale, tInCycle / inhaleDuration)
        } else if tInCycle < inhaleDuration + holdDuration {
            return (.hold, (tInCycle - inhaleDuration) / holdDuration)
        } else {
            return (.exhale, (tInCycle - inhaleDuration - holdDuration) / exhaleDuration)
        }
    }
    
    /// Ease-in-out (smoothstep) for smooth fill/empty; no bounce.
    private static func easeInOut(_ p: Double) -> Double {
        guard p >= 0, p <= 1 else { return p }
        return p * p * (3 - 2 * p)
    }
    
    private func bubbleScale(phase: BreathingPhase, progress: Double) -> CGFloat {
        let p = Self.easeInOut(progress)
        switch phase {
        case .inhale:
            return bubbleMinScale + (1 - bubbleMinScale) * CGFloat(p)
        case .hold:
            return 1
        case .exhale:
            return 1 - (1 - bubbleMinScale) * CGFloat(p)
        }
    }
    
    private func phaseLabel(_ phase: BreathingPhase) -> String {
        switch phase {
        case .inhale: return "Breathe in"
        case .hold: return "Hold"
        case .exhale: return "Breathe out"
        }
    }
    
    /// Seconds left in the current phase (4, 3, 2, 1 for inhale; 7…1 for hold; 8…1 for exhale).
    private func secondsRemainingInPhase(phase: BreathingPhase, tInCycle: TimeInterval) -> Int {
        let remaining: TimeInterval
        switch phase {
        case .inhale:
            remaining = inhaleDuration - tInCycle
        case .hold:
            remaining = (inhaleDuration + holdDuration) - tInCycle
        case .exhale:
            remaining = totalCycleDuration - tInCycle
        }
        return max(1, Int(remaining.rounded(.up)))
    }
}

/// Triggers a soft haptic when the breathing phase changes.
private struct PhaseChangeHaptic: View {
    let phase: BreathingPhase
    @State private var lastPhase: BreathingPhase?
    
    var body: some View {
        Color.clear
            .onChange(of: phase) { newPhase in
                if lastPhase != nil, lastPhase != newPhase {
                    let gen = UIImpactFeedbackGenerator(style: .soft)
                    gen.impactOccurred()
                }
                lastPhase = newPhase
            }
            .onAppear { lastPhase = phase }
    }
}

private struct ReminderCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 0.45, green: 0.72, blue: 0.99))
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .kerning(0.5)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Camera helpers
private final class CameraController: ObservableObject {
    let session = AVCaptureSession()
    private var isConfigured = false
    private let configurationQueue = DispatchQueue(label: "camera.configuration", qos: .userInitiated)
    
    func start(completion: @escaping (Bool) -> Void = { _ in }) {
        configurationQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            if !self.isConfigured {
                let success = self.configure()
                if !success {
                    DispatchQueue.main.async { completion(false) }
                    return
                }
            }
            
            // Use lower quality preset for faster startup
            if !self.session.isRunning {
                self.session.startRunning()
            }
            
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    func stop() {
        configurationQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    private func configure() -> Bool {
        session.beginConfiguration()
        // Use medium quality for faster initialization
        session.sessionPreset = .medium
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            session.commitConfiguration()
            return false
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                session.commitConfiguration()
                return false
            }
        } catch {
            session.commitConfiguration()
            return false
        }
        
        session.commitConfiguration()
        isConfigured = true
        return true
    }
}

private struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> PreviewView {
        let v = PreviewView()
        v.videoPreviewLayer.session = session
        v.videoPreviewLayer.videoGravity = .resizeAspectFill
        v.videoPreviewLayer.connection?.automaticallyAdjustsVideoMirroring = false
        v.videoPreviewLayer.connection?.isVideoMirrored = true
        return v
    }
    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

private final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}


