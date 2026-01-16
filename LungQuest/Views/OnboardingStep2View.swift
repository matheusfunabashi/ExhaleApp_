import SwiftUI

fileprivate struct CardPalette: Hashable {
    let colors: [Color]
    
    static let defaultPalettes: [CardPalette] = [
        CardPalette(colors: [
            Color(red: 0.35, green: 0.56, blue: 0.98),
            Color(red: 0.71, green: 0.83, blue: 0.99)
        ]),
        CardPalette(colors: [
            Color(red: 0.29, green: 0.75, blue: 0.82),
            Color(red: 0.12, green: 0.41, blue: 0.82)
        ]),
        CardPalette(colors: [
            Color(red: 0.93, green: 0.59, blue: 0.36),
            Color(red: 0.85, green: 0.27, blue: 0.27)
        ]),
        CardPalette(colors: [
            Color(red: 0.52, green: 0.72, blue: 0.97),
            Color(red: 0.29, green: 0.53, blue: 0.91)
        ]),
        CardPalette(colors: [
            Color(red: 0.83, green: 0.67, blue: 0.98),
            Color(red: 0.52, green: 0.47, blue: 0.93)
        ]),
        CardPalette(colors: [
            Color(red: 0.95, green: 0.73, blue: 0.47),
            Color(red: 0.98, green: 0.88, blue: 0.53)
        ])
    ]
}

struct OnboardingStep2View: View {
    init(onSkip: (() -> Void)? = nil, onNext: (() -> Void)? = nil, onBack: (() -> Void)? = nil) {
        self.onSkip = onSkip
        self.onNext = onNext
        self.onBack = onBack
    }
    
    private let onSkip: (() -> Void)?
    private let onNext: (() -> Void)?
    private let onBack: (() -> Void)?
    
    @EnvironmentObject var profileStore: ProfileStore
    private let palettes = CardPalette.defaultPalettes
    
    var body: some View {
        ZStack {
            Color(red: 0.68, green: 0.84, blue: 1.00)
                .ignoresSafeArea()
            
            content
        }
        .navigationBarBackButtonHidden(true)
        .accessibilitySortPriority(1)
    }
    
    private var content: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            
            VStack(alignment: .leading, spacing: 24) {
                topBar
                
                texts
                
                ProfileCardView(
                    profile: profileStore.profile,
                    palette: palette(for: profileStore.profile)
                )
                .frame(maxWidth: min(width * 0.9, 420))
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Let’s build the app around your needs.")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(Color.black.opacity(0.85))
                        .accessibilityLabel("Let’s build the app around your needs.")
                    
                    Button(action: { onNext?() }) {
                        HStack {
                            Spacer()
                            Text("Next")
                                .font(.headline)
                                .padding(.vertical, 18)
                            Spacer()
                        }
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 15)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Next")
                    .accessibilityHint("Continue to the next onboarding screen.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 28)
            .padding(.top, 48)
            .padding(.bottom, 44)
        }
    }
    
    private var topBar: some View {
        HStack(spacing: 16) {
            if let onBack {
                Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .padding(12)
                    .background(Color.white.opacity(0.35), in: Circle())
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .foregroundStyle(Color.white.opacity(0.95))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Go back")
            }
            
            Spacer()
        }
    }
    
    private var texts: some View {
        VStack(spacing: 16) {
            Text("Let’s go!")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.black)
                .minimumScaleFactor(0.75)
                .accessibilityAddTraits(.isHeader)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Welcome to Exhale, this is your profile card that will track your progress.")
                .font(.title3)
                .foregroundColor(Color.black.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func palette(for profile: UserProfile) -> CardPalette {
        guard !palettes.isEmpty else { return CardPalette.defaultPalettes.first! }
        let scalars = profile.id.uuidString.unicodeScalars
        let hash = scalars.reduce(UInt32(0)) { partial, scalar in
            (partial &* 31) &+ UInt32(scalar.value)
        }
        let index = Int(hash % UInt32(palettes.count))
        return palettes[index]
    }
}

private struct ProfileCardView: View {
    let profile: UserProfile
    let palette: CardPalette
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(LinearGradient(colors: palette.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 20) {
                header
                
                Spacer()
                
                Text("Streak: \(profile.streakDays) days")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .accessibilityLabel("Streak \(profile.streakDays) days")
                
                stripe
            }
            .padding(28)
        }
        .aspectRatio(1.35, contentMode: .fit)
        .accessibilityElement(children: .contain)
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            Image("exhale_logo") // Replace with asset at /mnt/data/Untitled_Artwork (1).png
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 18)
                .accessibilityHidden(true)
            
            Spacer()
            
            Image(systemName: "book.closed.fill")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
                .padding(12)
                .background(Color.white.opacity(0.15), in: Circle())
                .accessibilityHidden(true)
        }
    }
    
    private var stripe: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.white.opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .frame(height: 60)
            .overlay(alignment: .trailing) {
                Text(dateLabel)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
            .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 12)
            .accessibilityLabel("Tracking since \(dateLabel)")
    }
    
    private var dateLabel: String {
        if let start = profile.effectiveStartDate {
            return Self.dateFormatter.string(from: start)
        }
        return Self.dateFormatter.string(from: Date())
    }
}


#Preview {
    NavigationStack {
        OnboardingStep2View()
            .environmentObject(ProfileStore())
    }
}
