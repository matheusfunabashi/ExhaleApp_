import SwiftUI

enum ExerciseDailyProgress {
    enum Key: String {
        case bubblePop = "exercise.bubblePop.completedDate"
        case connectDots = "exercise.connectDots.completedDate"
        case mindMemory = "exercise.mindMemory.completedDate"
    }
    
    static func markCompletedToday(_ key: Key) {
        UserDefaults.standard.set(todayToken(), forKey: key.rawValue)
    }
    
    static func isCompletedToday(_ key: Key) -> Bool {
        UserDefaults.standard.string(forKey: key.rawValue) == todayToken()
    }
    
    private static func todayToken() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

struct ExercisesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                exerciseCard(
                    title: "Bubble Pop",
                    subtitle: "Pop soft bubbles and unwind with each tap.",
                    icon: "smallcircle.filled.circle.fill",
                    isCompletedToday: ExerciseDailyProgress.isCompletedToday(.bubblePop)
                ) {
                    BubblePopView()
                }
                
                exerciseCard(
                    title: "Connect the Dots",
                    subtitle: "Relax with a simple visual challenge.",
                    icon: "point.3.filled.connected.trianglepath.dotted",
                    isCompletedToday: ExerciseDailyProgress.isCompletedToday(.connectDots)
                ) {
                    ConnectDotsView()
                }
                
                exerciseCard(
                    title: "Mind Memory",
                    subtitle: "Train your memory in short sessions.",
                    icon: "brain.head.profile",
                    isCompletedToday: ExerciseDailyProgress.isCompletedToday(.mindMemory)
                ) {
                    MindMemoryView()
                }
                
                exerciseCard(
                    title: "Breathing Exercise",
                    subtitle: "Reset your body and mind with guided breathing.",
                    icon: "wind",
                    isCompletedToday: false
                ) {
                    BreathingExerciseView()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 18)
        }
        .breathableBackground()
    }
    
    private func exerciseCard<Destination: View>(
        title: String,
        subtitle: String,
        icon: String,
        isCompletedToday: Bool,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(isCompletedToday ? "Completed today" : subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(isCompletedToday ? .green.opacity(0.85) : .secondary)
                }
                
                Spacer()
                
                if isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.green.opacity(0.85))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationView {
        ExercisesView()
    }
}
