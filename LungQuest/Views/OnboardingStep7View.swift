import SwiftUI

struct OnboardingStep7View: View {
    let onNext: () -> Void
    let onBack: () -> Void
    
    private let options: [String] = [
        "Not at all",
        "Slightly",
        "Very reliant",
        "Extremely reliant"
    ]
    
    @State private var selectedOption: Int? = nil
    
    init(onNext: @escaping () -> Void, onBack: @escaping () -> Void) {
        self.onNext = onNext
        self.onBack = onBack
        _selectedOption = State(initialValue: nil)
    }
    
    var body: some View {
        ZStack {
            StaticOnboardingBackground()
            
            VStack(spacing: 24) {
                header
                
                QuestionTitleView(
                    title: "Question #7",
                    subtitle: "Are you dependent on nicotine to perform daily tasks?",
                    progress: 7.0 / 13.0
                )
                .padding(.bottom, 32)
                
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, label in
                        SelectableOptionRowView(
                            index: index + 1,
                            label: label,
                            isSelected: selectedOption == index,
                            toggleSelection: {
                                selectedOption = index
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    onNext()
                                }
                            }
                        )
                    }
                }
                .padding(.top, 32)
                
                Spacer()
                
                SkipButton(title: "Skip", action: onNext)
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 32)
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: onBack) {
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

private struct QuestionTitleView: View {
    let title: String
    let subtitle: String
    let progress: Double
    
    var body: some View {
        VStack(spacing: 18) {
            ProgressBar(progress: progress)
                .frame(height: 6)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text(subtitle)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
    }
}

private struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.12))
                    .frame(height: geo.size.height)
                
                Capsule()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: max(0, min(1, progress)) * geo.size.width, height: geo.size.height)
            }
        }
    }
}

private struct SkipButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

private struct SelectableOptionRowView: View {
    let index: Int
    let label: String
    let isSelected: Bool
    let toggleSelection: () -> Void
    
    private let highlightColor = Color(red: 0.16, green: 0.36, blue: 0.72)
    
    var body: some View {
        Button(action: toggleSelection) {
            HStack(spacing: 14) {
                Circle()
                    .fill(isSelected ? highlightColor : Color.black.opacity(0.12))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text("\(index)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(isSelected ? .white : .black)
                    )
                
                Text(label)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .background(
                Capsule()
                    .fill(isSelected ? highlightColor.opacity(0.92) : Color.white.opacity(0.95))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? highlightColor.opacity(0.6) : Color.black.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingStep7View(
        onNext: {},
        onBack: {}
    )
}

