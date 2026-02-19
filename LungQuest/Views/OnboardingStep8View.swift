import SwiftUI

struct OnboardingStep8View: View {
    let onNext: () -> Void
    let onBack: () -> Void
    
    private let options: [String] = [
        "Social acceptance",
        "Stress relief",
        "Addictive feeling",
        "Safer than cigarettes"
    ]
    @State private var selectedOptions: Set<Int> = []
    
    var body: some View {
        ZStack {
            StaticOnboardingBackground()
            
            VStack(spacing: 24) {
                header
                
                QuestionTitleView(
                    title: "Question #5",
                    subtitle: "Why do you feel the need to vape?"
                )
                .padding(.bottom, 32)
                
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, label in
                        SelectableOptionRowView(
                            index: index + 1,
                            label: label,
                            isSelected: selectedOptions.contains(index),
                            toggleSelection: {
                                if selectedOptions.contains(index) {
                                    selectedOptions.remove(index)
                                } else {
                                    selectedOptions.insert(index)
                                }
                            }
                        )
                    }
                }
                .padding(.top, 32)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Button(action: onNext) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.95))
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedOptions.isEmpty)
                    .opacity(selectedOptions.isEmpty ? 0.35 : 1)
                    
                    SkipButton(title: "Skip", action: onNext)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 32)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            OnboardingProgressBar(currentStep: 8, totalSteps: 13)
                .padding(.top, 8)
                .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden(true)
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
    
    var body: some View {
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

#Preview {
    OnboardingStep8View(
        onNext: {},
        onBack: {}
    )
}

