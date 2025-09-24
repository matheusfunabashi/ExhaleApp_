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
    private let camera = CameraController()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.1), Color.pink.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Camera reflection area
                    ZStack {
                        if cameraAuthorized {
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
                    
                    Text("Take a breath — you got this")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.pink)
                        .padding(.top, 10)
                    
                    BreathingCoach()
                        .frame(maxWidth: .infinity)
                    
                    MotivationList()
                    
                    Button(action: { isPresented = false }) {
                        Text("I’m okay now")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.pink))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .accessibilityLabel("Close")
        }
        .onAppear {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            requestCameraIfNeeded()
            camera.start()
        }
        .onDisappear { camera.stop() }
    }
    
    private func requestCameraIfNeeded() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { self.cameraAuthorized = granted }
            }
        default:
            cameraAuthorized = false
        }
    }
}

private struct BreathingCoach: View {
    @State private var phase: Bool = false
    private var timer: Timer.TimerPublisher { Timer.publish(every: 4, on: .main, in: .common) }
    var body: some View {
        VStack(spacing: 12) {
            Text(phase ? "Breathe out" : "Breathe in")
                .font(.headline)
                .foregroundColor(.primary)
            
            ZStack {
                Circle()
                    .stroke(Color.pink.opacity(0.2), lineWidth: 6)
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(Color.pink.opacity(0.6))
                    .frame(width: phase ? 160 : 80, height: phase ? 160 : 80)
                    .animation(.easeInOut(duration: 4.0), value: phase)
            }
            .frame(maxWidth: .infinity)
            Text("4-7-8 breathing: In 4 • Hold 7 • Out 8")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onAppear { phase = true }
        .onReceive(timer.autoconnect()) { _ in
            withAnimation(.easeInOut(duration: 4.0)) {
                phase.toggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Guided breathing coach")
    }
}

private struct MotivationList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MotivationRow(text: "Cravings pass in a few minutes — ride the wave")
            MotivationRow(text: "Drink water or chew gum while you breathe")
            MotivationRow(text: "Move for 60 seconds: stretch, walk, or 10 push-ups")
            MotivationRow(text: "Text a friend or look at your reasons to quit")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.9)))
        .shadow(radius: 6)
    }
}

private struct MotivationRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "sparkle")
                .foregroundColor(.pink)
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Camera helpers
private final class CameraController {
    let session = AVCaptureSession()
    private var isConfigured = false
    
    func start() {
        if !isConfigured { configure() }
        DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
    }
    func stop() { session.stopRunning() }
    
    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration(); return
        }
        session.addInput(input)
        session.commitConfiguration()
        isConfigured = true
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


