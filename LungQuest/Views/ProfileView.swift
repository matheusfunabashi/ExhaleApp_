import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showEditProfile = false
    @State private var showExportData = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header with user info
                    ProfileHeaderSection()
                    
                    // Quick stats
                    QuickStatsSection()
                    
                    // Settings sections
                    SettingsSection()
                    
                    // Data management
                    DataManagementSectionWrapper(showExportData: $showExportData)
                    
                    // App info
                    AppInfoSection()
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarItems(
                trailing: Button("Edit") {
                    showEditProfile = true
                }
            )
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showExportData) {
            ExportDataView()
        }
    }
}

struct ProfileHeaderSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            // Avatar and lung character
            HStack(spacing: 30) {
                // User avatar placeholder
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.pink.opacity(0.3), .blue.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                    
                    Text(userInitials)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Lung buddy representation (updated)
                BreathingLungCharacter(healthLevel: appState.lungState.healthLevel)
                    .frame(width: 80, height: 64)
            }
            
            // User details
            VStack(spacing: 8) {
                Text(appState.currentUser?.name ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Level \(appState.statistics.currentLevel) • \(appState.getDaysVapeFree()) days strong")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let startDate = appState.currentUser?.startDate {
                    Text("Journey started \(startDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 5)
        )
    }
    
    private var userInitials: String {
        let name = appState.currentUser?.name ?? "U"
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        } else {
            return String(name.prefix(1)).uppercased()
        }
    }
}

struct QuickStatsSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Journey")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                QuickStatCard(
                    title: "Current Streak",
                    value: "\(appState.getDaysVapeFree()) days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                QuickStatCard(
                    title: "Best Streak",
                    value: "\(appState.currentUser?.quitGoal.longestStreak ?? 0) days",
                    icon: "trophy.fill",
                    color: .yellow
                )
                
                QuickStatCard(
                    title: "Money Saved",
                    value: String(format: "$%.0f", appState.getMoneySaved()),
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                QuickStatCard(
                    title: "Badges Earned",
                    value: "\(appState.statistics.badges.count)",
                    icon: "star.circle.fill",
                    color: .purple
                )
            }
        }
    }
}

struct SettingsSection: View {
    @EnvironmentObject var appState: AppState
    @State private var notificationsEnabled = true
    @State private var selectedReminderFreq = ReminderFrequency.daily
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Settings")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Notifications toggle
                SettingsRow(
                    icon: "bell.fill",
                    title: "Push Notifications",
                    color: .blue
                ) {
                    Toggle("", isOn: $notificationsEnabled)
                }
                
                // Reminder frequency
                SettingsRow(
                    icon: "clock.fill",
                    title: "Reminder Frequency",
                    color: .orange
                ) {
                    Menu {
                        ForEach(ReminderFrequency.allCases, id: \.self) { freq in
                            Button(freq.rawValue.capitalized) {
                                selectedReminderFreq = freq
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedReminderFreq.rawValue.capitalized)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                // Dark mode (if supported)
                SettingsRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    color: .indigo
                ) {
                    Text("System")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.7))
                    .shadow(radius: 5)
            )
        }
        .onAppear {
            notificationsEnabled = appState.currentUser?.profile.preferences.notificationsEnabled ?? true
            selectedReminderFreq = appState.currentUser?.profile.preferences.reminderFrequency ?? .daily
        }
    }
}

struct DataManagementSection: View {
    @Binding var showExportData: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Data Management")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DataActionRow(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Download your progress as PDF",
                    color: .green,
                    action: { showExportData = true }
                )
                
                DataActionRow(
                    icon: "arrow.clockwise",
                    title: "Sync Data",
                    subtitle: "Backup to cloud storage",
                    color: .blue,
                    action: { /* Handle sync */ }
                )
                
                DataActionRow(
                    icon: "trash",
                    title: "Clear Data",
                    subtitle: "Reset all progress (careful!)",
                    color: .red,
                    action: { /* Handle clear with confirmation */ }
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.7))
                    .shadow(radius: 5)
            )
        }
    }
}

struct AppInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("About")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                InfoRow(title: "Version", value: "1.0.0")
                InfoRow(title: "Build", value: "001")
                
                Divider()
                
                NavigationLink(destination: SupportView()) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.blue)
                        Text("Help & Support")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: PrivacyPolicyView()) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.7))
                    .shadow(radius: 5)
            )
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .shadow(radius: 3)
        )
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: Content
    
    init(icon: String, title: String, color: Color, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            content
        }
        .padding(.vertical, 4)
    }
}

struct DataActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Supporting Views
struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var dailyCost = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
                
                Section("Vaping Information") {
                    TextField("Daily Cost ($)", text: $dailyCost)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                }
            )
        }
        .onAppear {
            loadCurrentData()
        }
    }
    
    private func loadCurrentData() {
        name = appState.currentUser?.name ?? ""
        email = appState.currentUser?.email ?? ""
        dailyCost = String(appState.currentUser?.profile.vapingHistory.dailyCost ?? 0)
    }
    
    private func saveChanges() {
        // Update user data
        // In a real app, this would update Firebase
        presentationMode.wrappedValue.dismiss()
    }
}

struct ExportDataView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Your Data")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Generate a PDF report of your progress to share with healthcare providers.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button("Generate PDF Report") {
                    // Handle PDF generation
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Spacer()
            }
            .padding()
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct SupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Help & Support")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Need assistance? We're here to help!")
                    .foregroundColor(.secondary)
                
                // FAQ section
                Text("Frequently Asked Questions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                // Support contact
                Text("Contact Support")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Email: support@lungquest.app")
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your privacy is important to us. This policy explains how we handle your data.")
                    .foregroundColor(.secondary)
                
                Text("Data Collection")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("We only collect data necessary to provide our services and help you track your progress.")
                
                Text("Data Usage")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Your data is used solely for app functionality and is never shared with third parties.")
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper wrapper for DataManagementSection
struct DataManagementSectionWrapper: View {
    @Binding var showExportData: Bool
    
    var body: some View {
        DataManagementSection(showExportData: $showExportData)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
