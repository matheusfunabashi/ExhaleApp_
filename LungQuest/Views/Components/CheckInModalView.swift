import SwiftUI

struct CheckInModalView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var wasVapeFree = true
    @State private var cravingsLevel = 1
    @State private var selectedMood = Mood.neutral
    @State private var notes = ""
    @State private var selectedPuffInterval = PuffInterval.none
    @State private var showSuccessAnimation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Daily Check-in")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("How did today go?")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Vape-free status
                    VapeFreeSection(wasVapeFree: $wasVapeFree)
                    
                    // Cravings level
                    CravingsSection(cravingsLevel: $cravingsLevel)
                    
                    // Mood selection
                    MoodSection(selectedMood: $selectedMood)
                    
                    // Puff count tracking
                    PuffCountSection(selectedPuffInterval: $selectedPuffInterval)
                    
                    // Notes
                    NotesSection(notes: $notes)
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveCheckIn()
                }
                .fontWeight(.semibold)
                .disabled(false) // Always enabled for now
            )
        }
        .overlay(
            SuccessAnimationView(isShowing: $showSuccessAnimation)
        )
    }
    
    private func saveCheckIn() {
        appState.checkIn(
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Were you vape-free today?")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 15) {
                OptionButton(
                    title: "Yes! 🎉",
                    subtitle: "I stayed strong",
                    isSelected: wasVapeFree,
                    action: { wasVapeFree = true }
                )
                
                OptionButton(
                    title: "Not quite 😔",
                    subtitle: "I'll do better tomorrow",
                    isSelected: !wasVapeFree,
                    action: { wasVapeFree = false }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
        )
    }
}

struct CravingsSection: View {
    @Binding var cravingsLevel: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("How intense were your cravings?")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 10) {
                HStack {
                    Text("None")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Very Intense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { level in
                        Circle()
                            .fill(level <= cravingsLevel ? cravingsColor(level) : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                cravingsLevel = level
                            }
                            .overlay(
                                Text("\(level)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(level <= cravingsLevel ? .white : .gray)
                            )
                    }
                }
            }
            
            Text(cravingsDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
        )
    }
    
    private func cravingsColor(_ level: Int) -> Color {
        switch level {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4: return .red
        case 5: return .purple
        default: return .gray
        }
    }
    
    private var cravingsDescription: String {
        switch cravingsLevel {
        case 1: return "No cravings at all!"
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("How are you feeling?")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    VStack(spacing: 5) {
                        Text(mood.emoji)
                            .font(.title)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(selectedMood == mood ? mood.color.opacity(0.2) : Color.clear)
                                    .stroke(selectedMood == mood ? mood.color : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedMood = mood
                            }
                        
                        Text(mood.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(selectedMood == mood ? mood.color : .secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
        )
    }
}

struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Any thoughts or reflections?")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $notes)
                .frame(minHeight: 80)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    // Placeholder text
                    HStack {
                        VStack {
                            if notes.isEmpty {
                                Text("What helped you today? Any challenges?")
                                    .foregroundColor(.secondary)
                                    .font(.body)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.leading, 16)
                    .allowsHitTesting(false)
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
        )
    }
}

struct OptionButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.pink.opacity(0.1) : Color.white)
                    .stroke(isSelected ? Color.pink : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .foregroundColor(isSelected ? .pink : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PuffCountSection: View {
    @Binding var selectedPuffInterval: PuffInterval
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("How many puffs did you take today?")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(PuffInterval.allCases, id: \.self) { interval in
                    OptionButton(
                        title: interval.displayName,
                        subtitle: getSubtitle(for: interval),
                        isSelected: selectedPuffInterval == interval,
                        action: { selectedPuffInterval = interval }
                    )
                }
            }
            
            Text(selectedPuffInterval.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
        )
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
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.green.opacity(0.1)
                
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    Text("Check-in Saved!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .opacity(opacity)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}

#Preview {
    CheckInModalView()
        .environmentObject(AppState())
}

