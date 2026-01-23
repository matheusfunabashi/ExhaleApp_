import SwiftUI
import SuperwallKit

struct OnboardingStep13View: View {
    let onContinue: () -> Void
    let onBack: () -> Void
    
    @EnvironmentObject private var flowManager: AppFlowManager
    @State private var userScore: Double = Double.random(in: 0.60...0.85)
    @State private var currentPage: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State private var animateBars: Bool = false
    @State private var animateLines: Bool = false
    
    private let averageScore: Double = 0.30
    private let pagingAnimation = Animation.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0.25)
    
    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            
            VStack(spacing: 0) {
                resultsPage
                    .frame(width: geo.size.width, height: height)
                
                planComparisonPage
                    .frame(width: geo.size.width, height: height)
                
                rescuePage
                    .frame(width: geo.size.width, height: height)
            }
            .offset(y: -CGFloat(currentPage) * height + dragOffset)
            .gesture(dragGesture(for: height))
            .animation(pagingAnimation, value: currentPage)
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
    
    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.35), in: Circle())
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
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
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(Color.white.opacity(0.35), in: Capsule())
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var resultsPage: some View {
        ZStack(alignment: .bottom) {
            ResultsBackground()
            
            VStack(spacing: 24) {
                header
                
                Spacer(minLength: 24)
                
                VStack(spacing: 16) {
                    Text("Analysis Complete")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 6) {
                        Text("We have some insights for you.")
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Your responses indicate a noticeable dependency on vaping.")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                }
                
                Spacer(minLength: 24)
                
                ScoreComparisonView(userScore: userScore, averageScore: averageScore, animateBars: $animateBars)
                    .padding(.horizontal, 12)
                    .onAppear { animateBars = true }
                
                VStack(spacing: 10) {
                    Text("Your score is higher than average vaping dependency.")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                    
                    Text("This result is only an indication and not a medical diagnosis.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 72)
            
            if currentPage == 0 {
                Button(action: { withAnimation(pagingAnimation) { currentPage = 1 } }) {
                    Image(systemName: "chevron.down.double")
                        .font(.system(size: 34, weight: .black))
                        .foregroundColor(.white)
                        .padding(18)
                        .background(Color.white.opacity(0.22), in: Circle())
                        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 10)
                        .accessibilityLabel("Reveal next step")
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
        }
    }
    
    private var planComparisonPage: some View {
        ZStack(alignment: .bottom) {
            ResultsBackground()
            
            VStack(spacing: 20) {
                header
                
                Spacer(minLength: 16)
                
                VStack(spacing: 12) {
                    Text("Exhale plan vs usual plans")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("With Exhale, your cravings and dependency drop steadily. Usual plans often plateau or rebound.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 12)
                
                LineComparisonCard(
                    animateLines: $animateLines,
                    exhaleData: [74, 62, 50, 38, 28, 18],
                    usualData: [74, 65, 62, 75, 58, 66],
                    xLabels: ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6"]
                )
                .padding(.horizontal, 12)
                .onAppear { animateLines = true }
                
                Spacer(minLength: 12)
                
                Button(action: { withAnimation(pagingAnimation) { currentPage = 2 } }) {
                    Image(systemName: "chevron.down.double")
                        .font(.system(size: 34, weight: .black))
                        .foregroundColor(.white)
                        .padding(18)
                        .background(Color.white.opacity(0.22), in: Circle())
                        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 10)
                        .accessibilityLabel("Reveal next step")
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 72)
        }
    }
    
    private var rescuePage: some View {
        ZStack {
            RescueBackground()
            
            VStack(spacing: 28) {
                Spacer()
                
                Image("LungBuddy_0")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 374, height: 306)
                    .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 12)
                
                Text("Your lungs need your help!")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.45, green: 0.05, blue: 0.05))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                Button(action: handleContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.45, green: 0.05, blue: 0.05))
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 15)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.bottom, 20)

            }
            .padding(.top, 48)
            .padding(.bottom, 28)
        }
    }
    
    private func dragGesture(for height: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .updating($dragOffset) { value, state, _ in
                let translation = value.translation.height
                state = max(-height, min(height, translation))
            }
            .onEnded { value in
                let translation = value.translation.height
                let threshold = height * 0.18
                
                if translation < -threshold, currentPage < 2 {
                    withAnimation(pagingAnimation) { currentPage += 1 }
                } else if translation > threshold, currentPage > 0 {
                    withAnimation(pagingAnimation) { currentPage -= 1 }
                }
            }
    }
    
    private func handleContinue() {
        onContinue()
        if !flowManager.isSubscribed {
            Superwall.shared.register(placement: "onboarding_end")
        }
    }
}

private struct ResultsBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.52, green: 0.72, blue: 0.97),
                Color(red: 0.31, green: 0.58, blue: 0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct RescueBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.88, blue: 0.88),
                Color(red: 1.0, green: 0.76, blue: 0.76)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

private struct ScoreComparisonView: View {
    let userScore: Double
    let averageScore: Double
    @Binding var animateBars: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text("Exhale")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.45, green: 0.72, blue: 0.99), Color(red: 0.60, green: 0.80, blue: 1.0)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 4)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Vaping dependency")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("You vs Average")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            GeometryReader { geo in
                let maxScore = max(userScore, averageScore)
                let barAreaHeight = max(geo.size.height - 40, 120)
                
                VStack(spacing: 16) {
                    HStack(alignment: .bottom, spacing: 36) {
                        VStack(spacing: 6) {
                            Text("\(Int(userScore * 100))%")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.black)
                            AnimatedBar(
                                value: userScore,
                                maxValue: maxScore,
                                height: barAreaHeight,
                                gradient: Gradient(colors: [Color(red: 0.98, green: 0.43, blue: 0.52), Color(red: 0.9, green: 0.22, blue: 0.35)]),
                                animate: animateBars
                            )
                            Text("You")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.black.opacity(0.8))
                        }
                        
                        VStack(spacing: 6) {
                            Text("\(Int(averageScore * 100))%")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.black)
                            AnimatedBar(
                                value: averageScore,
                                maxValue: maxScore,
                                height: barAreaHeight,
                                gradient: Gradient(colors: [Color(red: 0.36, green: 0.69, blue: 1.0), Color(red: 0.2, green: 0.42, blue: 0.9)]),
                                animate: animateBars
                            )
                            Text("Average")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.black.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(height: 220)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 10)
        )
    }
}

private struct AnimatedBar: View {
    let value: Double
    let maxValue: Double
    let height: CGFloat
    let gradient: Gradient
    let animate: Bool
    
    var body: some View {
        let normalized = maxValue > 0 ? value / maxValue : 0
        let targetHeight = max(44, CGFloat(normalized) * height)
        
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
            .frame(width: 74, height: animate ? targetHeight : 0)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 6)
            .animation(.easeOut(duration: 0.8), value: animate)
    }
}

private struct LineComparisonCard: View {
    @Binding var animateLines: Bool
    let exhaleData: [Double]
    let usualData: [Double]
    let xLabels: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text("Exhale")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.45, green: 0.72, blue: 0.99), Color(red: 0.60, green: 0.80, blue: 1.0)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 4)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Vaping Habits Over Time")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            LineChart(
                exhale: exhaleData,
                usual: usualData,
                xLabels: xLabels,
                animate: animateLines
            )
            .frame(height: 220)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 10)
        )
    }
}

private struct LegendChip: View {
    let color: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(title)
                .font(.caption)
                .foregroundColor(.black.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
        )
    }
}

private struct LineChart: View {
    let exhale: [Double]
    let usual: [Double]
    let xLabels: [String]
    let animate: Bool
    private let visibleTickIndices: [Int] = [0, 2, 4]

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                // horizontal inset so first/last points aren't at extreme edges
                let horizontalInset: CGFloat = 28
                // make room inside geo for labels under baseline and legend above it
                let plotHeight = geo.size.height * 0.85
                let plotWidth = max(0, geo.size.width - horizontalInset * 2)

                // compute points using inset so x positions are centered nicely
                let pointsExhale = normalizedPoints(for: exhale, in: CGSize(width: plotWidth, height: plotHeight), xOffset: horizontalInset)
                let pointsUsual = normalizedPoints(for: usual, in: CGSize(width: plotWidth, height: plotHeight), xOffset: horizontalInset)

                // baseline Y (in this coordinate space)
                let baselineY = plotHeight

                ZStack {
                    // thin baseline
                    Path { p in
                        p.move(to: CGPoint(x: horizontalInset, y: baselineY))
                        p.addLine(to: CGPoint(x: horizontalInset + plotWidth, y: baselineY))
                    }
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)

                    // Usual (blue) curved line
                    curvedLinePath(points: pointsUsual)
                        .trim(from: 0, to: animate ? 1 : 0)
                        .stroke(Color(red: 0.98, green: 0.43, blue: 0.52), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .shadow(color: Color.blue.opacity(0.14), radius: 6, x: 0, y: 3)
                        .animation(.easeOut(duration: 0.9).delay(0.1), value: animate)

                    // Exhale (red) curved line
                    curvedLinePath(points: pointsExhale)
                        .trim(from: 0, to: animate ? 1 : 0)
                        .stroke(Color(red: 0.36, green: 0.69, blue: 1.0), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .shadow(color: Color.red.opacity(0.12), radius: 6, x: 0, y: 3)
                        .animation(.easeOut(duration: 0.9), value: animate)

                    // relapse.. label on usual index 3 (above the curve)
                    if pointsUsual.indices.contains(3) {
                        Text("relapse..")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(Color(red: 0.98, green: 0.43, blue: 0.52))
                            .position(
                                x: pointsUsual[3].x,
                                y: max(pointsUsual[3].y - 18, 12)
                            )
                            .opacity(animate ? 1 : 0)
                            .animation(.easeOut(duration: 0.6).delay(0.5), value: animate)
                    }

                    // sobriety glow on final exhale point (soft halo)
                    if let last = pointsExhale.indices.last {
                        Circle()
                            .fill(Color(red: 0.36, green: 0.69, blue: 1.0).opacity(0.22))
                            .frame(width: 36, height: 36)
                            .position(pointsExhale[last])
                            .blur(radius: 8)
                            .opacity(animate ? 1 : 0)
                            .animation(.easeOut(duration: 0.6).delay(0.35), value: animate)

                        Text("sobriety")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(Color(red: 0.36, green: 0.69, blue: 1.0))
                            .position(x: pointsExhale[last].x - 3, y: pointsExhale[last].y + 18)
                            .opacity(animate ? 1 : 0)
                            .animation(.easeOut(duration: 0.6).delay(0.6), value: animate)
                    }

                    // LEGEND placed ABOVE baseline (so legend dots sit above the horizontal line)
                    HStack(spacing: 16) {
                        LegendChip(color: Color(red: 0.36, green: 0.69, blue: 1.0), title: "Exhale")
                        LegendChip(color: Color(red: 0.98, green: 0.43, blue: 0.52), title: "Usual Plans")
                    }
                    .position(x: geo.size.width / 2, y: max(baselineY - 15, 18))
                    .opacity(1)
                }
                // ensure this overall block has enough vertical room
                .frame(width: geo.size.width, height: geo.size.height * 0.92, alignment: .top)
                .clipped()
                
                // X-axis tick labels — render below baseline (centered under each tick)
                // Use a separate overlay so the labels are not clipped by the plot block
                ForEach(visibleTickIndices, id: \.self) { idx in
                    if pointsExhale.indices.contains(idx) {
                        Text(xLabels.indices.contains(idx) ? xLabels[idx] : "")
                            .font(.caption2)
                            .foregroundColor(.black.opacity(0.65))
                            .position(x: pointsExhale[idx].x + 15, y: baselineY + 27)
                    }
                }
            }
            .frame(height: 220)

            // removed earlier legend and x-axis HStacks — they are now placed inside GeoReader
            Spacer(minLength: 0)
        }
    }

    // normalizedPoints now accepts xOffset so the points are nicely inset from edges
    private func normalizedPoints(for values: [Double], in size: CGSize, xOffset: CGFloat) -> [CGPoint] {
        // width step based on visible width
        let widthStep = size.width / CGFloat(max(values.count - 1, 1))
        return values.enumerated().map { idx, val in
            let x = xOffset + widthStep * CGFloat(idx)
            let clamped = max(0, min(100, val))
            let normalized = clamped / 100.0
            let y = size.height - (CGFloat(normalized) * size.height)
            return CGPoint(x: x, y: y)
        }
    }

    // keep your existing curvedLinePath implementation here (Catmull-Rom -> cubic Bezier)
    // paste your current curvedLinePath(points:) function or the Catmull-Rom variant you used earlier.
    private func curvedLinePath(points: [CGPoint]) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }

        func controlPoints(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint, tension: CGFloat = 0.45) -> (CGPoint, CGPoint) {
            let d1 = CGPoint(x: (p2.x - p0.x) * tension, y: (p2.y - p0.y) * tension)
            let d2 = CGPoint(x: (p3.x - p1.x) * tension, y: (p3.y - p1.y) * tension)
            let cp1 = CGPoint(x: p1.x + d1.x / 3.0, y: p1.y + d1.y / 3.0)
            let cp2 = CGPoint(x: p2.x - d2.x / 3.0, y: p2.y - d2.y / 3.0)
            return (cp1, cp2)
        }

        var pts = points
        if pts.count == 2 {
            path.move(to: pts[0])
            path.addLine(to: pts[1])
            return path
        }
        pts.insert(pts.first!, at: 0)
        pts.append(pts.last!)

        path.move(to: pts[1])
        for i in 1..<(pts.count - 2) {
            let p0 = pts[i - 1]
            let p1 = pts[i]
            let p2 = pts[i + 1]
            let p3 = pts[i + 2]
            let (cp1, cp2) = controlPoints(p0: p0, p1: p1, p2: p2, p3: p3, tension: 0.45)
            path.addCurve(to: p2, control1: cp1, control2: cp2)
        }
        return path
    }
}
#Preview {
    let store = AppDataStore()
    let flow = AppFlowManager(dataStore: store)
    OnboardingStep13View(
        onContinue: {},
        onBack: {}
    )
    .environmentObject(flow)
    .environmentObject(store)
}


