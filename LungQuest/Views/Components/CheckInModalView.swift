import SwiftUI

struct CheckInModalView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var moodLevel = 0
    @State private var cravingsLevel = 0
    @State private var selfControlLevel = 0
    @State private var energyLevel = 0
    @State private var confidenceLevel = 0
    @State private var puffCount = 0
    @State private var notes = ""
    @State private var showSuccessAnimation = false
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Section title (date is now in sticky header)
                        Text("Rate how you felt today in these key areas")
                            .padding(.top, 24)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // 5 rating cards
                    RatingCard(
                        icon: "face.smiling",
                        title: "Mood",
                        subtitle: "How was your overall emotional state today?",
                        value: $moodLevel
                    )
                    
                    RatingCard(
                        icon: "flame.fill",
                        title: "Cravings",
                        subtitle: "How intense were your cravings today?",
                        value: $cravingsLevel
                    )
                    
                    RatingCard(
                        icon: "shield.fill",
                        title: "Self Control",
                        subtitle: "How well did you manage urges and impulses?",
                        value: $selfControlLevel
                    )
                    
                    RatingCard(
                        icon: "bolt.fill",
                        title: "Energy",
                        subtitle: "How was your energy level throughout the day?",
                        value: $energyLevel
                    )
                    
                    RatingCard(
                        icon: "hand.thumbsup.fill",
                        title: "Confidence",
                        subtitle: "How confident do you feel about staying vape-free?",
                        value: $confidenceLevel
                    )
                    
                    // Puff count slider
                    PuffCountSliderCard(puffCount: $puffCount)
                    
                    // Thoughts / reflections text box
                    ReflectionsCard(notes: $notes)
                    
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .dismissKeyboardOnTap()
            }
            
            // Sticky Save button - always visible at bottom
            VStack(spacing: 0) {
                Button(action: saveCheckIn) {
                    Text("Save check-in")
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [accentColor, Color(red: 0.30, green: 0.60, blue: 0.90)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!allRatingsSelected)
                .opacity(allRatingsSelected ? 1 : 0.5)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.90, green: 0.96, blue: 1.0), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(formattedDate)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.black)
                }
            }
            .breathableBackground()
        }
        .navigationViewStyle(.stack)
        .overlay(
            SuccessAnimationView(isShowing: $showSuccessAnimation)
        )
    }
    
    private var allRatingsSelected: Bool {
        moodLevel > 0 && cravingsLevel > 0 && selfControlLevel > 0 && energyLevel > 0 && confidenceLevel > 0
    }
    
    private func saveCheckIn() {
        guard allRatingsSelected else { return }
        dataStore.checkIn(
            cravingsLevel: cravingsLevel,
            moodLevel: moodLevel,
            selfControlLevel: selfControlLevel,
            energyLevel: energyLevel,
            confidenceLevel: confidenceLevel,
            puffCount: puffCount,
            notes: notes
        )
        
        showSuccessAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Rating Card (1-10 scale)
private struct RatingCard: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var value: Int
    var inverted: Bool = false
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(accentColor)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            // 1-10 scale - evenly spaced
            HStack(spacing: 0) {
                ForEach(1...10, id: \.self) { level in
                    let isSelected = inverted ? (level <= (11 - value)) : (level <= value)
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            value = inverted ? (11 - level) : level
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(isSelected ? accentColor.opacity(0.2) : Color.gray.opacity(0.08))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(isSelected ? accentColor : Color.gray.opacity(0.2), lineWidth: isSelected ? 1.5 : 1)
                                )
                            
                            Text("\(level)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(isSelected ? accentColor : .secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.75)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(accentColor.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
}

// MARK: - Puff Count Slider
private struct PuffCountSliderCard: View {
    @Binding var puffCount: Int
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "wind")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(accentColor)
                
                Text("Puff Count")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Text("How many puffs did you take today? Honest tracking helps you see real progress.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                HStack {
                    Text("0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(puffCount)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(accentColor)
                    Spacer()
                    Text("100+")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { Double(puffCount) },
                    set: { puffCount = Int($0.rounded()) }
                ), in: 0...100, step: 1)
                .tint(accentColor)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.75)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(accentColor.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
}

// MARK: - Reflections Text Box
private struct ReflectionsCard: View {
    @Binding var notes: String
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "text.quote")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(accentColor)
                
                Text("Thoughts or Reflections")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Text("Optional, but reflecting helps you notice patterns.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.gray.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(accentColor.opacity(0.15), lineWidth: 1)
                    )
                    .frame(minHeight: 100)
                
                if notes.isEmpty {
                    Text("What helped you today? Any challenges?")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .padding(.top, 12)
                        .padding(.leading, 12)
                }
                
                TextEditor(text: $notes)
                    .font(.body)
                    .padding(8)
                    .scrollContentBackground(.hidden)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.75)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(accentColor.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
}

struct SuccessAnimationView: View {
    @Binding var isShowing: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Circle()
                                    .stroke(Color.green.opacity(0.4), lineWidth: 2)
                            )
                            .scaleEffect(scale)
                            .opacity(opacity)
                        
                        Text("✓")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.green)
                            .scaleEffect(scale)
                            .opacity(opacity)
                            .rotationEffect(.degrees(rotation))
                    }
                    
                    VStack(spacing: 8) {
                        Text("Check-in Saved!")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .opacity(opacity)
                        
                        Text("Great job tracking your progress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .opacity(opacity)
                    }
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.98), Color.white.opacity(0.95)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(accentColor.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 15)
                )
                .scaleEffect(scale)
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
                withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                    rotation = 360
                }
            }
        }
    }
}

#Preview {
    CheckInModalView()
        .environmentObject(AppDataStore())
}
