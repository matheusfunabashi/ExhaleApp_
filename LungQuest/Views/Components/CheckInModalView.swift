import SwiftUI

struct CheckInModalView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var wasVapeFree = true
    @State private var cravingsLevel = 1
    @State private var selectedMood = Mood.neutral
    @State private var notes = ""
    @State private var selectedPuffInterval = PuffInterval.none
    @State private var showSuccessAnimation = false
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Daily Check-in")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [accentColor, Color(red: 0.45, green: 0.72, blue: 0.99)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("How did today go?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    
                    // Vape-free status
                    VapeFreeSection(wasVapeFree: $wasVapeFree)
                    
                    // Cravings level
                    CravingsSection(cravingsLevel: $cravingsLevel)
                    
                    // Mood selection
                    MoodSection(selectedMood: $selectedMood)
                    
                    // Puff count tracking
                    PuffCountSection(selectedPuffInterval: $selectedPuffInterval, wasVapeFree: $wasVapeFree)
                    
                    // Notes
                    NotesSection(notes: $notes)
                    
                    // Save button
                    Button(action: saveCheckIn) {
                        Text("Save Check-in")
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [accentColor, Color(red: 0.06, green: 0.21, blue: 0.55)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(26)
                            .shadow(color: accentColor.opacity(0.3), radius: 14, x: 0, y: 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 8)
                    
                    Spacer(minLength: 20)
                }
                .padding()
                .dismissKeyboardOnTap()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.secondary)
            )
            .breathableBackground()
        }
        .overlay(
            SuccessAnimationView(isShowing: $showSuccessAnimation)
        )
    }
    
    private func saveCheckIn() {
        dataStore.checkIn(
            wasVapeFree: wasVapeFree,
            cravingsLevel: cravingsLevel,
            mood: selectedMood,
            notes: notes,
            puffInterval: selectedPuffInterval
        )
        
        showSuccessAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct VapeFreeSection: View {
    @Binding var wasVapeFree: Bool
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Were you vape-free today?")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Be honest—every check-in helps you grow.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                OptionButton(
                    title: "Yes! 🎉",
                    subtitle: "I stayed strong",
                    isSelected: wasVapeFree,
                    accentColor: accentColor,
                    action: { wasVapeFree = true }
                )
                
                OptionButton(
                    title: "Not quite 😔",
                    subtitle: "I'll do better tomorrow",
                    isSelected: !wasVapeFree,
                    accentColor: accentColor,
                    action: { wasVapeFree = false }
                )
            }
        }
        .softCard(accent: accentColor, cornerRadius: 28)
    }
}

struct CravingsSection: View {
    @Binding var cravingsLevel: Int
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("How intense were your cravings?")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Track how you felt to spot patterns over time.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("None")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Very Intense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { level in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                cravingsLevel = level
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        level <= cravingsLevel 
                                            ? cravingsColor(level)
                                            : Color.gray.opacity(0.15)
                                    )
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                level <= cravingsLevel 
                                                    ? cravingsColor(level).opacity(0.4)
                                                    : Color.gray.opacity(0.25),
                                                lineWidth: level <= cravingsLevel ? 2 : 1
                                            )
                                    )
                                    .shadow(
                                        color: level <= cravingsLevel 
                                            ? cravingsColor(level).opacity(0.3)
                                            : Color.clear,
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                                
                                Text("\(level)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(level <= cravingsLevel ? .white : .secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            Text(cravingsDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
        .softCard(accent: accentColor, cornerRadius: 28)
    }
    
    private func cravingsColor(_ level: Int) -> Color {
        switch level {
        case 1: return Color.green
        case 2: return Color(red: 0.85, green: 0.85, blue: 0.15)
        case 3: return Color.orange
        case 4: return Color(red: 0.94, green: 0.33, blue: 0.33)
        case 5: return Color(red: 0.74, green: 0.13, blue: 0.26)
        default: return Color.gray
        }
    }
    
    private var cravingsDescription: String {
        switch cravingsLevel {
        case 1: return "No cravings at all! ✨"
        case 2: return "Mild thoughts, easily ignored"
        case 3: return "Noticeable but manageable"
        case 4: return "Strong urges, required effort"
        case 5: return "Very intense, difficult to resist"
        default: return ""
        }
    }
}

struct MoodSection: View {
    @Binding var selectedMood: Mood
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("How are you feeling?")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Your mood helps us understand your journey better.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedMood = mood
                        }
                    }) {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(
                                        selectedMood == mood
                                            ? mood.color.opacity(0.2)
                                            : Color.gray.opacity(0.1)
                                    )
                                    .frame(width: 56, height: 56)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                selectedMood == mood
                                                    ? mood.color
                                                    : Color.gray.opacity(0.3),
                                                lineWidth: selectedMood == mood ? 2.5 : 1.5
                                            )
                                    )
                                    .shadow(
                                        color: selectedMood == mood
                                            ? mood.color.opacity(0.25)
                                            : Color.clear,
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                                
                                Text(mood.emoji)
                                    .font(.system(size: 28))
                            }
                            
                            Text(mood.rawValue.capitalized)
                                .font(.caption2)
                                .fontWeight(selectedMood == mood ? .semibold : .regular)
                                .foregroundColor(selectedMood == mood ? mood.color : .secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .softCard(accent: accentColor, cornerRadius: 28)
    }
}

struct NotesSection: View {
    @Binding var notes: String
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Any thoughts or reflections?")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Optional—but reflecting helps you notice patterns.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(accentColor.opacity(0.2), lineWidth: 1)
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
        .softCard(accent: accentColor, cornerRadius: 28)
    }
}

struct OptionButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        isSelected
                            ? LinearGradient(
                                gradient: Gradient(colors: [accentColor.opacity(0.15), accentColor.opacity(0.08)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.4)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                isSelected ? accentColor.opacity(0.4) : Color.gray.opacity(0.25),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? accentColor.opacity(0.15) : Color.black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
            .foregroundColor(isSelected ? accentColor : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PuffCountSection: View {
    @Binding var selectedPuffInterval: PuffInterval
    @Binding var wasVapeFree: Bool
    
    private let accentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("How many puffs did you take today?")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Honest tracking helps you see real progress.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 10) {
                ForEach(PuffInterval.allCases, id: \.self) { interval in
                    let isDisabled = !wasVapeFree && interval == .none
                    OptionButton(
                        title: interval.displayName,
                        subtitle: getSubtitle(for: interval),
                        isSelected: selectedPuffInterval == interval,
                        accentColor: accentColor,
                        action: { selectedPuffInterval = interval }
                    )
                    .disabled(isDisabled)
                    .opacity(isDisabled ? 0.4 : 1.0)
                }
            }
            
            Text(selectedPuffInterval.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
        .softCard(accent: accentColor, cornerRadius: 28)
        .onChange(of: wasVapeFree) { _, newValue in
            if !newValue && selectedPuffInterval == .none {
                selectedPuffInterval = .light
            }
        }
    }
    
    private func getSubtitle(for interval: PuffInterval) -> String {
        switch interval {
        case .none: return "Completely vape-free"
        case .light: return "Light usage"
        case .moderate: return "Moderate usage"
        case .heavy: return "Heavy usage"
        case .veryHeavy: return "Very heavy usage"
        }
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
