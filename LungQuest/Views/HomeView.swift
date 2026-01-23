import SwiftUI
import UIKit
import SuperwallKit

struct HomeView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showCheckIn = false
    @State private var showCelebration = false
    @State private var showCalendar = false
    @State private var showMoney = false
    @State private var showHealth = false
    @State private var showSlipConfirmation = false
    @State private var showSlipSecondConfirmation = false
    @State private var showHeroGlow = false
    @State private var selectedLesson: HomeLearningLesson? = nil
    @State private var selectedReadingOfTheDay: Lesson? = nil
    @State private var selectedCheckInFromButton: DailyProgress? = nil
    #if DEBUG
    @State private var showDevMenu = false
    @State private var showDevOptions = false
    @State private var devDestination: DevDestination?
    #endif
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    // App Title with Fire Streak
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Exhale")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(red: 0.45, green: 0.72, blue: 0.99), Color(red: 0.60, green: 0.80, blue: 1.0)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            if !greetingName.isEmpty {
                                Text("Keep breathing easy, \(greetingName).")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        FireStreakIcon()
                    }
                    .padding(.horizontal)

                    // New Hero Layout - No white box
                    VStack(spacing: 22) {
                        WeekdayStreakRow()
                        
                        LungBuddyCenter()
                            .padding(.top, 8)
                        
                        VStack(spacing: 10) {
                            Text("You've been vape-free for")
                                .font(.system(.footnote, design: .rounded).weight(.medium))
                                .foregroundColor(.secondary)
                            
                            DaysCounterView()
                                .environmentObject(dataStore)
                            
                            NewHeroTimerView(
                                onMilestone: {
                                    showCelebration = true
                                    triggerHeroGlow()
                                }
                            )
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.92), Color.white.opacity(0.75)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                            .blendMode(.overlay)
                                    )
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                            )
                        }
                        
                        // Four action buttons
                        HStack(spacing: 0) {
                            ActionButton(
                                icon: hasCheckedInToday ? "checkmark" : "pencil",
                                label: "Check-ins",
                                isCompleted: hasCheckedInToday,
                                action: {
                                    if !hasCheckedInToday {
                                        showCheckIn = true
                                    } else if let todayCheckIn = todayCheckIn {
                                        selectedCheckInFromButton = todayCheckIn
                                    }
                                }
                            )
                            .frame(maxWidth: .infinity)
                            
                            ActionButton(
                                icon: "arrow.counterclockwise",
                                label: "I relapsed",
                                isCompleted: false,
                                action: {
                                    showSlipSecondConfirmation = true
                                }
                            )
                            .frame(maxWidth: .infinity)
                            
                            ActionButton(
                                icon: "chart.line.uptrend.xyaxis",
                                label: "Progress",
                                isCompleted: false,
                                action: {
                                    TabNavigationManager.shared.switchToProgressTab()
                                }
                            )
                            .frame(maxWidth: .infinity)
                            
                            ActionButton(
                                icon: "book.fill",
                                label: "Learn",
                                isCompleted: false,
                                action: {
                                    TabNavigationManager.shared.switchToLearnTab()
                                }
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .softCard(accent: heroAccentColor, cornerRadius: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(heroAccentColor.opacity(showHeroGlow ? 0.45 : 0.0), lineWidth: 6)
                            .blur(radius: showHeroGlow ? 1 : 10)
                            .animation(.easeInOut(duration: 1.1), value: showHeroGlow)
                    )
                    .padding(.horizontal)
                    #if DEBUG
                    .contentShape(Rectangle())
                    .onTapGesture(count: 5) {
                        showDevOptions = true
                    }
                    #endif
                    
                    HomeSection(
                        title: "Your journey",
                        subtitle: "Keep tabs on streaks, savings, and how your lungs are healing."
                    ) {
                        StatsSection(
                            onDaysTapped: { showCalendar = true },
                            onMoneyTapped: { showMoney = true },
                            onHealthTapped: { showHealth = true }
                        )
                    }
                    .padding(.horizontal)
                    
                    CheckInStatusButton(showCheckIn: $showCheckIn)
                    .padding(.horizontal)
                    
                    ReadingOfTheDayButton(selectedLesson: $selectedReadingOfTheDay)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .breathableBackground()
        }
        .sheet(isPresented: $showCheckIn) {
            CheckInModalView()
        }
        .sheet(isPresented: $showCalendar) {
            NavigationView {
                ScrollView {
                    ProgressCalendarView()
                        .padding()
                }
                .navigationTitle("Calendar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { showCalendar = false }
                    }
                }
            }
            .environmentObject(dataStore)
        }
        .sheet(isPresented: $showMoney) {
            NavigationView {
                MoneySavedView()
                    .navigationTitle("Money Saved")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showMoney = false }
                        }
                    }
            }
            .environmentObject(dataStore)
        }
        .sheet(isPresented: $showHealth) {
            NavigationView {
                HealthImprovementsView()
                    .navigationTitle("Health Improvements")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showHealth = false }
                        }
                    }
            }
            .environmentObject(dataStore)
        }
        #if DEBUG
        .sheet(isPresented: $showDevMenu) {
            DevMenuView()
                .environmentObject(dataStore)
        }
        #endif
        .overlay(
            CelebrationView(isShowing: $showCelebration)
        )
        .alert("Are you sure?", isPresented: $showSlipSecondConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, I relapsed", role: .destructive) {
                showSlipConfirmation = true
            }
        } message: {
            Text("This will reset your streak counter. Do you want to continue?")
        }
        .alert("Reset Your Progress?", isPresented: $showSlipConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetTimerForSlip()
            }
        } message: {
            Text("This will reset your streak counter to zero. This action cannot be undone.")
        }
        .sheet(item: $selectedLesson) { lesson in
            if let fullLesson = getFullLesson(from: lesson) {
                LessonDetailModal(lesson: fullLesson, accent: Color(red: 0.95, green: 0.65, blue: 0.75))
                    .environmentObject(dataStore)
            }
        }
        .sheet(item: $selectedReadingOfTheDay) { lesson in
            LessonDetailModal(lesson: lesson, accent: Color(red: 0.95, green: 0.65, blue: 0.75))
                .environmentObject(dataStore)
        }
        .sheet(item: $selectedCheckInFromButton) { checkIn in
            CheckInDetailView(checkIn: checkIn)
                .environmentObject(dataStore)
        }
        #if DEBUG
        .confirmationDialog(
            "Debug options",
            isPresented: $showDevOptions,
            titleVisibility: .visible
        ) {
            Button("Open Onboarding preview") { devDestination = .onboarding }
            Button("Developer menu") { showDevMenu = true }
            Button("Test Superwall") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    Superwall.shared.register(placement: "onboarding_end")
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(item: $devDestination) { destination in
            switch destination {
            case .onboarding:
                OnboardingView()
                    .environmentObject(dataStore)
            }
        }
        #endif
    }
    
    private func checkForNewStreak() { }

    private func triggerHeroGlow() {
        showHeroGlow = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeOut(duration: 0.8)) {
                showHeroGlow = false
            }
        }
    }


    private var greetingName: String {
        let fullName = dataStore.currentUser?.name ?? ""
        return fullName.split(separator: " ").first.map(String.init) ?? ""
    }

    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return dataStore.dailyProgress.contains { progress in
            Calendar.current.isDate(progress.date, inSameDayAs: today)
        }
    }
    
    private var todayCheckIn: DailyProgress? {
        let today = Calendar.current.startOfDay(for: Date())
        return dataStore.dailyProgress.first { progress in
            Calendar.current.isDate(progress.date, inSameDayAs: today)
        }
    }
    
    private var healthInsight: String {
        let days = dataStore.getDaysVapeFree()
        switch days {
        case ..<1:
            return "Every single pass on a vape gives your lungs more room to recover."
        case 1...2:
            return "Within 24 hours your oxygen levels begin to rebound—keep noticing those deeper breaths."
        case 3...6:
            return "Nicotine is clearing out and your oxygen flow is improving today."
        case 7...29:
            return "One calm week in: your lungs are expanding easier and circulation is smoothing out."
        case 30...89:
            return "Each smoke-free day is restoring stamina and brighter energy for your routines."
        default:
            return "Your body keeps regenerating—oxygen delivery and lung capacity rise with every streak."
        }
    }

    private var lungMoodCopy: String {
        let health = dataStore.lungState.healthLevel
        switch health {
        case 0..<25:
            return "Your lungs are ready for tiny breaths of reset—every calm moment helps."
        case 25..<50:
            return "Fresh air is settling in; your lungs are starting to feel lighter."
        case 50..<75:
            return "Your lung buddy is smiling wider with every check-in today."
        default:
            return "Your lungs feel bright and grateful—keep soaking in that clarity."
        }
    }


    private var heroAccentColor: Color {
        let health = dataStore.lungState.healthLevel
        switch health {
        case 0..<25:
            return Color(red: 0.84, green: 0.41, blue: 0.46)
        case 25..<50:
            return Color(red: 0.67, green: 0.52, blue: 0.93)
        case 50..<75:
            return Color(red: 0.38, green: 0.63, blue: 0.97)
        default:
            return Color(red: 0.26, green: 0.67, blue: 0.61)
        }
    }

    private func resetTimerForSlip() {
        // Record slip for today and reset timer to now
        dataStore.checkIn(wasVapeFree: false)
        if var user = dataStore.currentUser {
            user.startDate = Date()
            dataStore.currentUser = user
        }
        UserDefaults.standard.set(0, forKey: "lastMilestoneNotifiedDays")
        dataStore.updateLungHealth()
        dataStore.persist()
    }
}

// MARK: - Helper Functions for Reading Content
private func getExpandedBenefitsContent() -> String {
    return "Your body begins healing the moment you stop vaping. Understanding these benefits can strengthen your motivation during challenging moments. This comprehensive guide will walk you through every stage of recovery, from the first hour to years of improved health.\n\nIMMEDIATE BENEFITS (Within Hours):\n\n• 20 minutes: Your heart rate and blood pressure start to normalize. The constricting effects of nicotine on your blood vessels begin to reverse, allowing your cardiovascular system to function more efficiently. Your pulse rate drops, and your blood pressure begins to stabilize.\n\n• 2 hours: Nicotine levels in your bloodstream drop by half. Your body starts processing and eliminating the nicotine, reducing its immediate effects on your nervous system. You may notice your hands and feet feeling warmer as circulation improves.\n\n• 8-12 hours: Carbon monoxide levels in your blood drop significantly, allowing more oxygen to reach your cells. This is crucial because carbon monoxide binds to red blood cells more readily than oxygen, reducing your body's oxygen-carrying capacity. As it clears, you'll feel more alert and energetic.\n\n• 24 hours: Your risk of heart attack begins to decrease. The strain on your heart lessens as your cardiovascular system starts to recover. Your heart doesn't have to work as hard to pump blood, reducing the risk of cardiac events.\n\nSHORT-TERM BENEFITS (Days to Weeks):\n\n• 2-3 days: Your sense of taste and smell begin to improve dramatically. The nerve endings in your nose and taste buds start regenerating. Food will taste richer and more flavorful. You may notice scents you haven't smelled in years. This improvement continues for several weeks.\n\n• 3-5 days: Nicotine is completely eliminated from your body. Withdrawal symptoms typically peak during this time, but knowing that the physical dependency is ending can be empowering. Your body is now free from nicotine's influence.\n\n• 1 week: Circulation improves significantly, making physical activity easier. Your blood vessels are less constricted, allowing better blood flow to your muscles and organs. You may notice improved stamina during exercise and daily activities. Your skin may also look healthier due to improved circulation.\n\n• 2-4 weeks: Lung function increases measurably. You'll notice easier breathing, especially during physical activity. Your lung capacity improves as inflammation decreases. Coughing and shortness of breath should diminish. Many people report feeling like they can take deeper, fuller breaths.\n\n• 1 month: Your immune system begins to strengthen. White blood cell function improves, making you less susceptible to infections. You may notice fewer colds and faster recovery when you do get sick.\n\nMEDIUM-TERM BENEFITS (Months):\n\n• 1-3 months: Cilia in your lungs fully recover. These tiny hair-like structures line your airways and help clear mucus and debris. As they regenerate, your lungs become more effective at self-cleaning, reducing your risk of infections like bronchitis and pneumonia. Your lung capacity can increase by up to 30%.\n\n• 3-6 months: Your risk of respiratory infections decreases significantly. Your lungs are better equipped to defend against bacteria and viruses. If you were prone to frequent colds or respiratory issues, you'll likely notice a dramatic improvement.\n\n• 6 months: Your energy levels should be noticeably higher. Without the constant cycle of nicotine highs and crashes, your energy becomes more stable throughout the day. Many people report feeling more alert and less fatigued.\n\nLONG-TERM BENEFITS (Years):\n\n• 1 year: Your risk of heart disease drops by 50%. This is one of the most significant health improvements. Your cardiovascular system has had time to repair damage and reduce inflammation. Your heart attack risk is now half of what it was when you were vaping.\n\n• 2-5 years: Your stroke risk decreases significantly. The improved cardiovascular health and reduced inflammation lower your chances of experiencing a stroke. Your blood vessels are healthier and more flexible.\n\n• 5 years: Your risk of cancers of the mouth, throat, and esophagus decreases by 50%. The cells in these areas have had time to regenerate and repair damage. Your body's natural defense mechanisms are functioning better.\n\n• 10 years: Your lung cancer risk drops by 50% compared to continued vaping. Your lungs have had significant time to heal and regenerate. The risk continues to decrease the longer you remain vape-free.\n\n• 15 years: Your risk of heart disease is now similar to someone who never vaped. Your cardiovascular system has had extensive time to recover. This is a remarkable milestone that shows the body's incredible capacity for healing.\n\nADDITIONAL BENEFITS:\n\nBeyond the physical improvements, quitting vaping brings numerous other benefits:\n\n• Financial savings: Calculate how much you spent weekly on vaping supplies. Over a year, this can amount to hundreds or even thousands of dollars saved.\n\n• Improved appearance: Your skin will look healthier as circulation improves. You may notice fewer wrinkles and a more youthful complexion. Your teeth and gums will be healthier.\n\n• Better sleep: Nicotine disrupts sleep patterns. Without it, you'll sleep more deeply and wake more refreshed. Many people report needing less sleep but feeling more rested.\n\n• Reduced anxiety: While withdrawal can temporarily increase anxiety, long-term vaping cessation typically reduces overall anxiety levels. The constant cycle of nicotine highs and crashes creates anxiety that disappears once you quit.\n\n• Improved fertility: For both men and women, quitting vaping improves fertility and reproductive health. Sperm quality improves in men, and women have better chances of conception.\n\n• Better oral health: Your gums and teeth will be healthier. Reduced risk of gum disease, tooth loss, and oral cancers.\n\n• Enhanced sense of freedom: Many people report feeling liberated from the constant need to vape. You're no longer planning your day around vaping opportunities or worrying about running out of supplies.\n\nUNDERSTANDING THE HEALING PROCESS:\n\nYour body has remarkable regenerative abilities. Every cell in your body is constantly being replaced, and when you remove harmful substances like nicotine and the chemicals in vape products, your body can focus on healing and regeneration.\n\nThe timeline above shows average recovery rates, but individual experiences vary. Some people notice improvements faster, while others may take longer. Factors like age, overall health, how long you vaped, and genetics all play a role.\n\nWhat's important is that every moment without vaping is a step toward better health. Your body is designed to heal—you just need to give it the chance. Even if you've vaped for years, your body can still recover significantly.\n\nRemember: Progress isn't always linear. Some days you'll feel great, others you might feel tired or notice lingering symptoms. This is normal. The overall trend is toward improvement, and your body is working hard to repair itself.\n\nEvery benefit listed here is a reason to stay committed to your quit journey. When cravings hit, remind yourself of these improvements. Your future self will thank you for every moment you choose not to vape."
    }
    
private func getExpandedVapingContent() -> String {
    return "Understanding what happens in your body when you vape can help clarify why quitting matters. This comprehensive guide explores the immediate and long-term effects of vaping on your body, mind, and overall health. Knowledge is power—understanding these effects isn't meant to create fear, but to empower you with information so you can make informed decisions about your health.\n\nIMMEDIATE SHORT-TERM EFFECTS (Within Minutes to Hours):\n\n• Nicotine constricts blood vessels: Within seconds of inhaling, nicotine enters your bloodstream and causes your blood vessels to narrow. This increases your heart rate by 10-20 beats per minute and raises your blood pressure. Your heart has to work harder to pump blood through constricted vessels, putting strain on your cardiovascular system. This effect can last for 30 minutes to several hours after vaping.\n\n• Reduces oxygen delivery: The chemicals in vape aerosols, including carbon monoxide and other toxins, bind to red blood cells more readily than oxygen. This means less oxygen reaches your brain, muscles, and organs. You may not notice this immediately, but it affects your energy levels, cognitive function, and physical performance. Over time, this oxygen deprivation can cause cellular damage.\n\n• Affects brain chemistry immediately: Nicotine reaches your brain within 10 seconds of inhalation. It binds to nicotinic acetylcholine receptors, triggering a massive release of dopamine—the \"feel-good\" neurotransmitter. This creates a temporary sense of pleasure and alertness. However, your brain quickly adapts, requiring more nicotine to achieve the same effect. This is how dependency develops so rapidly.\n\n• Alters reward pathways: Each time you vape, you're reinforcing the neural pathways that associate vaping with reward. Your brain learns that vaping = pleasure, making it increasingly difficult to resist cravings. This rewiring happens quickly and can persist long after you quit, which is why cravings can feel so powerful.\n\n• Impairs lung function immediately: Even a single vaping session can cause inflammation in your airways. Your lungs respond to the foreign substances by producing mucus and constricting airways. This reduces your lung capacity temporarily. You may not notice this if you're a regular vaper, but your lungs are working harder than they should.\n\n• Increases stress hormones: While nicotine initially feels calming, it actually increases cortisol and adrenaline—stress hormones. This creates a cycle where you vape to feel better, but the vaping itself increases stress, leading to more vaping. This is why many people feel more anxious overall when vaping regularly.\n\n• Affects blood sugar: Nicotine can cause blood sugar spikes and crashes, leading to energy fluctuations throughout the day. This can contribute to mood swings and make it harder to maintain stable energy levels.\n\nMEDIUM-TERM EFFECTS (Days to Months):\n\n• Chronic inflammation: Regular vaping keeps your body in a state of low-grade inflammation. Your immune system is constantly fighting the foreign substances, which can lead to fatigue, joint pain, and increased susceptibility to illness. This inflammation affects your entire body, not just your lungs.\n\n• Reduced immune function: The constant exposure to chemicals weakens your immune system's ability to fight infections. You may notice you get sick more often, take longer to recover, or develop more severe symptoms when you do get ill.\n\n• Skin and appearance changes: Reduced circulation and oxygen delivery can make your skin look dull and aged. You may notice premature wrinkles, especially around your mouth from the repetitive motion. Your skin may also heal more slowly from cuts and bruises.\n\n• Dental and oral health issues: Vaping can cause dry mouth, which increases the risk of cavities and gum disease. The chemicals can irritate your gums and lead to inflammation. Some studies suggest vaping may increase the risk of oral infections and periodontal disease.\n\n• Sleep disruption: Nicotine is a stimulant that can disrupt your sleep patterns. Even if you don't vape right before bed, the effects on your nervous system can make it harder to fall asleep and stay asleep. Poor sleep quality affects every aspect of your health.\n\n• Digestive issues: Nicotine affects your digestive system, potentially causing nausea, stomach pain, or changes in appetite. Some people experience constipation or other digestive problems.\n\nLONG-TERM RISKS (Months to Years):\n\n• Cardiovascular disease: Chronic exposure to nicotine and other chemicals significantly increases your risk of heart attack, stroke, and peripheral artery disease. The constant constriction of blood vessels, increased heart rate, and inflammation create conditions that can lead to serious cardiovascular problems. Research shows that vaping increases heart attack risk by up to 34% compared to non-users.\n\n• Respiratory problems: Long-term vaping can lead to chronic bronchitis, emphysema, and significantly reduced lung function. The delicate tissues in your lungs can become scarred and damaged. You may develop a chronic cough, wheezing, or shortness of breath that persists even when you're not actively vaping.\n\n• EVALI (E-cigarette or Vaping product use-Associated Lung Injury): This serious condition can develop from vaping, causing severe lung damage, difficulty breathing, and in some cases, death. While more common with certain products, it highlights the unpredictable risks of vaping.\n\n• Cancer risk: While research is ongoing, vaping exposes you to known carcinogens including formaldehyde, acetaldehyde, and acrolein. These substances can damage DNA and increase cancer risk. Studies suggest increased risk of lung, oral, and esophageal cancers. The full extent of cancer risk may not be known for decades, as many cancers develop slowly over time.\n\n• Brain development issues: For younger users, vaping can interfere with brain development, affecting attention, learning, and impulse control. The brain continues developing until around age 25, and nicotine exposure during this time can have lasting effects.\n\n• Reproductive health: Vaping can affect fertility in both men and women. In men, it can reduce sperm quality and count. In women, it can affect egg quality and increase the risk of pregnancy complications. During pregnancy, vaping can harm fetal development.\n\n• Bone health: Some research suggests that nicotine can interfere with bone healing and may contribute to decreased bone density over time, increasing fracture risk, especially as you age.\n\n• Mental health impacts: While many people vape to manage stress or anxiety, nicotine dependency actually increases anxiety and depression over time. The constant cycle of nicotine highs and crashes creates mood instability. Withdrawal symptoms can include increased anxiety, irritability, and depression.\n\n• Addiction and dependency: Nicotine is one of the most addictive substances known. The ease of vaping (no need to light anything, can do it indoors, less social stigma) can lead to more frequent use and stronger dependency than traditional smoking. Breaking this dependency becomes increasingly difficult the longer you vape.\n\nUNDERSTANDING THE CHEMICALS:\n\nVape aerosols contain numerous chemicals beyond nicotine:\n\n• Propylene glycol and vegetable glycerin: While generally recognized as safe for consumption, the effects of heating and inhaling these substances are less understood. They can break down into harmful compounds when heated.\n\n• Flavoring chemicals: Many flavorings used in vape products haven't been tested for safety when inhaled. Some, like diacetyl, have been linked to serious lung disease.\n\n• Heavy metals: Vaping devices can release small amounts of metals like lead, nickel, and chromium into the aerosol, which you then inhale.\n\n• Ultrafine particles: These tiny particles can penetrate deep into your lungs and enter your bloodstream, potentially causing inflammation and other health issues throughout your body.\n\nTHE CUMULATIVE EFFECT:\n\nIt's important to understand that these effects are cumulative. Each vaping session adds to the damage. Your body has remarkable healing abilities, but constant exposure prevents it from fully recovering. The longer you vape, the more damage accumulates, and the longer it takes to heal once you quit.\n\nHowever, this isn't meant to be discouraging. Every moment you choose not to vape is a moment your body can begin healing. The damage isn't necessarily permanent—your body can recover significantly once you remove the source of harm.\n\nKNOWLEDGE AS EMPOWERMENT:\n\nUnderstanding what vaping does to your body gives you power. When cravings hit, you can remind yourself of these effects. When you're tempted to vape, you can remember that you're choosing to avoid these risks. Knowledge helps you make informed decisions and strengthens your resolve to quit.\n\nYour body has remarkable healing abilities once you stop vaping. Many of these effects begin to reverse within hours or days of quitting. The sooner you quit, the sooner your body can begin the healing process. Every day without vaping is a step toward better health."
}
    
private func getExpandedTipsContent() -> String {
    return "Quitting vaping is a journey, and having practical strategies makes all the difference. This comprehensive guide provides evidence-based tips that have helped millions of people successfully quit. Remember: there's no one-size-fits-all approach. Try different strategies and find what works best for you. The key is to keep trying and not give up, even if you experience setbacks.\n\nPHASE 1: PREPARATION (Before You Quit)\n\n1. Set a quit date and stick to it:\n\nChoose a date within the next two weeks—not too far away that you lose motivation, but not so soon that you're not prepared. Pick a day when you'll have minimal stress and can focus on your quit. Some people choose a meaningful date like a birthday or anniversary. Mark it on your calendar and treat it as seriously as any important appointment.\n\n2. Remove all vaping devices and supplies:\n\nThis is crucial. Remove temptation by getting rid of all vape devices, pods, e-liquids, chargers, and any related accessories. Don't keep \"just one\" as a backup—that backup will become your downfall. Give them away, throw them away, or return them if possible. Clean your car, home, and workspace of any vaping-related items.\n\n3. Tell friends and family:\n\nAccountability is powerful. Tell people you trust about your decision to quit. Ask for their support and be specific about what you need. For example: \"I'm quitting vaping on [date]. Can you check in with me daily for the first week?\" or \"If you see me struggling, can you remind me why I'm quitting?\" Having people who know and support your goal makes it harder to give up.\n\n4. Identify your triggers:\n\nSpend a few days before your quit date noticing when and why you vape. Common triggers include: stress, boredom, after meals, while driving, social situations, certain times of day, specific locations, or emotional states. Write these down. Awareness is the first step to managing triggers.\n\n5. Prepare your environment:\n\nStock up on healthy alternatives: water, sugar-free gum, healthy snacks, herbal tea, toothpicks, or fidget toys. Prepare activities that can distract you: books, puzzles, exercise equipment, or hobby supplies. Make your environment supportive of your quit attempt.\n\n6. Plan for withdrawal:\n\nUnderstand that withdrawal symptoms are temporary and manageable. Common symptoms include: irritability, anxiety, difficulty concentrating, restlessness, increased appetite, and cravings. These typically peak within the first 3-5 days and gradually decrease. Knowing what to expect helps you prepare mentally.\n\nPHASE 2: REPLACEMENT STRATEGIES (During Cravings)\n\n1. Physical replacements:\n\n• Water: Keep a water bottle with you at all times. When a craving hits, take slow sips. The act of drinking and the hydration can help reduce cravings.\n• Sugar-free gum or mints: The oral fixation of vaping can be satisfied with gum. The minty flavor can also feel refreshing.\n• Healthy snacks: Crunchy vegetables like carrots or celery, or fruits like apples can satisfy the hand-to-mouth habit.\n• Toothpicks or cinnamon sticks: These can help with the oral fixation without adding calories.\n• Fidget toys: Stress balls, worry stones, or fidget spinners can keep your hands busy.\n\n2. Activity replacements:\n\n• Walking: Even a 5-minute walk can reduce cravings and improve mood. The movement and change of scenery help break the craving cycle.\n• Deep breathing: The 4-7-8 technique (inhale for 4, hold for 7, exhale for 8) activates your relaxation response and can reduce cravings.\n• Exercise: More intense exercise releases endorphins and can significantly reduce cravings for up to an hour afterward.\n• Reading: Engaging your mind with a book or article can distract you from cravings.\n• Calling a friend: Social connection releases dopamine naturally and can replace the social aspect of vaping.\n• Hobbies: Engage in activities you enjoy—drawing, music, gardening, cooking, or anything that keeps your hands and mind busy.\n\n3. Mental replacements:\n\n• Remind yourself why you're quitting: Keep a list of your reasons visible. Read it when cravings hit.\n• Visualize success: Picture yourself as a non-vaper. Imagine how you'll feel, look, and what you'll be able to do.\n• Count the benefits: Mentally list the benefits you've already experienced or will experience.\n• Use affirmations: \"I am stronger than this craving,\" \"This will pass,\" \"I choose my health.\"\n\nPHASE 3: HANDLING CRAVINGS (The 3-5 Minute Window)\n\nCravings typically peak within 3-5 minutes and then subside. Here's how to ride them out:\n\n1. The 4-7-8 breathing technique:\n\nThis powerful technique can reduce cravings and anxiety:\n• Inhale through your nose for 4 counts\n• Hold your breath for 7 counts\n• Exhale through your mouth for 8 counts\n• Repeat 4-8 times\n\nThis activates your parasympathetic nervous system, reducing stress and cravings.\n\n2. The 5-minute rule:\n\nWhen a craving hits, tell yourself: \"I'll wait 5 minutes before deciding.\" Set a timer. During those 5 minutes, do one of your replacement activities. Often, by the time the timer goes off, the craving has passed or significantly decreased.\n\n3. Physical activity:\n\n• 10 push-ups or sit-ups\n• Jumping jacks\n• A quick walk up and down stairs\n• Stretching\n• Dancing to one song\n\nPhysical movement releases endorphins and can interrupt the craving cycle.\n\n4. Distraction techniques:\n\n• Count backwards from 100 by 7s\n• Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste\n• Recite something from memory (a poem, song lyrics, etc.)\n• Do a quick mental puzzle\n• Focus intensely on a single object and describe it in detail\n\n5. Cold water technique:\n\nSplash cold water on your face or hold an ice cube. The shock can interrupt the craving and activate your dive reflex, which can calm your nervous system.\n\nPHASE 4: MANAGING WITHDRAWAL\n\n1. Stay hydrated:\n\nDehydration can mimic or worsen withdrawal symptoms. Aim for 8-10 glasses of water daily. Herbal teas can also be soothing and help with hydration.\n\n2. Get plenty of sleep:\n\nWithdrawal can disrupt sleep, but adequate rest is crucial for managing symptoms. Create a bedtime routine, avoid screens before bed, and aim for 7-9 hours of sleep.\n\n3. Eat regular, balanced meals:\n\nBlood sugar fluctuations can worsen cravings and mood swings. Eat regular meals with protein, complex carbs, and healthy fats. Avoid skipping meals.\n\n4. Consider nicotine replacement therapy (NRT):\n\nUnder medical guidance, NRT can help manage withdrawal symptoms. Options include patches, gum, lozenges, or nasal spray. NRT provides nicotine without the harmful chemicals in vape products, allowing you to gradually reduce nicotine intake.\n\n5. Manage stress:\n\nWithdrawal can increase stress, which can trigger cravings. Practice stress management techniques:\n• Meditation or mindfulness\n• Yoga or gentle stretching\n• Journaling\n• Talking to a supportive person\n• Taking breaks when needed\n\n6. Be patient with yourself:\n\nWithdrawal symptoms are temporary. They're a sign that your body is healing and adjusting to life without nicotine. Remind yourself that these symptoms will pass.\n\nPHASE 5: RECOVERING FROM SLIPS\n\nIf you slip, don't give up. Slips are common and don't mean you've failed. Here's how to recover:\n\n1. Don't catastrophize:\n\nOne slip doesn't erase your progress. Don't fall into the \"I've already messed up, so I might as well keep going\" trap. A slip is a single event, not a failure.\n\n2. Log what happened:\n\nAs soon as possible, write down:\n• What triggered the slip?\n• Where were you?\n• What were you feeling?\n• What time was it?\n• What were you thinking?\n\nThis information helps you identify patterns and prepare for similar situations.\n\n3. Identify the trigger:\n\nUnderstanding what led to the slip helps you prepare for next time. Was it stress? Social pressure? A specific location? A certain time of day?\n\n4. Adjust your strategy:\n\nBased on what you learned, what will you do differently? Do you need to avoid certain situations? Do you need different coping strategies? Do you need more support?\n\n5. Recommit immediately:\n\nDon't wait until tomorrow or next week. Recommit to quitting right now. The longer you wait, the harder it becomes.\n\n6. Learn from it:\n\nEvery slip teaches you something. What did you learn? How can you use this knowledge to strengthen your quit attempt?\n\n7. Progress over perfection:\n\nRemember: every moment vape-free counts. If you were vape-free for 3 days and then slipped, you still had 3 days of healing. That progress isn't lost.\n\nADDITIONAL SUCCESS STRATEGIES:\n\n1. Track your progress:\n\nUse an app, calendar, or journal to track your quit journey. Mark each vape-free day. Celebrate milestones. Seeing your progress visually can be very motivating.\n\n2. Reward yourself:\n\nSet up a reward system. Calculate how much money you're saving and use some of it to reward yourself at milestones (1 day, 1 week, 1 month, etc.).\n\n3. Find your \"why\":\n\nConnect with your deeper reasons for quitting. Is it for your health? Your family? Your future? Your finances? Write these down and revisit them regularly.\n\n4. Build a support network:\n\nConnect with others who are quitting or have quit. Join online communities, support groups, or find a quit buddy. Sharing the journey makes it easier.\n\n5. Avoid high-risk situations:\n\nEspecially in early days, avoid situations where you know you'll be tempted. This isn't forever—just until you're stronger in your quit.\n\n6. Practice self-compassion:\n\nBe kind to yourself. Quitting is hard. You're doing something difficult. Treat yourself with the same compassion you'd show a friend going through this.\n\n7. Celebrate small wins:\n\nEvery hour, every day vape-free is an achievement. Acknowledge and celebrate these moments. They build momentum.\n\nREMEMBER:\n\nMillions of people have successfully quit vaping. You have the tools and the strength to do it too. It may not be easy, but it's absolutely possible. Every attempt teaches you something. Every moment vape-free is progress. Keep trying, keep learning, and keep moving forward. You can do this."
}
    
    private func getFullLesson(from homeLesson: HomeLearningLesson) -> Lesson? {
        // Get the full lesson data from LearningView's structure
        let learnAndReflectLessons = [
            Lesson.withContent(
                title: "Benefits of quitting",
                summary: "Your body heals from day one.",
                durationMinutes: 9,
                icon: "❤️",
                content: getExpandedBenefitsContent(),
                sources: ["American Heart Association - Benefits of Quitting Smoking", "Centers for Disease Control and Prevention - Health Benefits Timeline", "Mayo Clinic - Quitting Smoking: Health Benefits", "National Cancer Institute - Health Benefits of Quitting", "American Lung Association - Benefits of Quitting", "World Health Organization - Tobacco Cessation Benefits"]
            ),
            Lesson.withContent(
                title: "What vaping does",
                summary: "Understand short and long-term risks.",
                durationMinutes: 12,
                icon: "🫁",
                content: getExpandedVapingContent(),
                sources: ["National Institute on Drug Abuse - Vaping Health Effects", "American Lung Association - Health Risks of Vaping", "World Health Organization - Electronic Nicotine Delivery Systems", "Centers for Disease Control and Prevention - Health Effects of E-Cigarettes", "Journal of the American Heart Association - Cardiovascular Effects of E-Cigarettes", "Nature Reviews Drug Discovery - Nicotine Addiction and Health Effects"]
            ),
            Lesson.withContent(
                title: "Tips to quit",
                summary: "Craving hacks and routines that work.",
                durationMinutes: 9,
                icon: "💡",
                content: getExpandedTipsContent(),
                sources: ["Centers for Disease Control and Prevention - Tips for Quitting", "American Cancer Society - Quitting Guide", "Smokefree.gov - Quit Plan", "National Institute on Drug Abuse - Principles of Drug Addiction Treatment", "Mayo Clinic - Quitting Smoking: 10 Ways to Resist Tobacco Cravings", "American Psychological Association - Strategies for Behavior Change"]
            )
        ]
        
        return learnAndReflectLessons.first { $0.title == homeLesson.title }
    }


// MARK: - Home Learning Lesson Model
struct HomeLearningLesson: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

struct StatsSection: View {
    @EnvironmentObject var dataStore: AppDataStore
    var onDaysTapped: (() -> Void)? = nil
    var onMoneyTapped: (() -> Void)? = nil
    var onHealthTapped: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            StatsCard(
                title: "Days Free",
                value: "\(daysFromStartDate)",
                emoji: "📅",
                color: .orange,
                onTap: { onDaysTapped?() }
            )
            
            StatsCard(
                title: "Money Saved",
                value: formattedMoneySaved,
                emoji: "💰",
                color: .blue,
                onTap: { onMoneyTapped?() },
                valueFont: moneyValueFont
            )
            
            StatsCard(
                title: "Lung Boost",
                value: "\(dataStore.lungState.healthLevel)%",
                emoji: "🫁",
                color: .green,
                onTap: { onHealthTapped?() }
            )
        }
    }
    
    private var daysFromStartDate: Int {
        guard let startDate = dataStore.currentUser?.startDate else { return 0 }
        let elapsed = Date().timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    private var formattedMoneySaved: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: moneySavedFromStartDate)) ?? "$0"
    }
    
    private var moneySavedFromStartDate: Double {
        guard let user = dataStore.currentUser else { return 0 }
        
        // Get daily cost from onboarding, or use $20/week as fallback
        let weeklyCost = user.profile.vapingHistory.dailyCost > 0 
            ? user.profile.vapingHistory.dailyCost 
            : 20.0
        let dailyCost = weeklyCost / 7.0
        
        // Calculate days from startDate (same as main counter)
        let days = daysFromStartDate
        
        return Double(days) * dailyCost
    }
    
    private var moneyValueFont: Font {
        // Use a slightly smaller font when the numeric portion hits 3+ digits.
        let digits = formattedMoneySaved.filter { $0.isNumber }
        if digits.count >= 3 {
            return .system(size: 24, weight: .bold, design: .rounded)
        } else {
            return .system(size: 28, weight: .bold, design: .rounded)
        }
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let emoji: String
    let color: Color
    var onTap: (() -> Void)? = nil
    var valueFont: Font = .system(size: 28, weight: .bold, design: .rounded)
    
    var body: some View {
        VStack(spacing: 12) {
            // Emoji at top
            Text(emoji)
                .font(.system(size: 40))
            
            // Value
            Text(value)
                .font(valueFont)
                .foregroundColor(.primary)
                .monospacedDigit()
            
            // Title
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }
}

struct CheckInSection: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Binding var showCheckIn: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Daily Check-in")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if hasCheckedInToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            if hasCheckedInToday {
                HStack {
                    Image(systemName: "party.popper.fill")
                        .foregroundColor(.pink)
                    Text("Great job today! You've checked in.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            } else {
                Button(action: {
                    showCheckIn = true
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                        Text("Check In Now")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.pink)
                    )
                    .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(radius: 5)
        )
    }
    
    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return dataStore.dailyProgress.contains { progress in
            Calendar.current.isDate(progress.date, inSameDayAs: today)
        }
    }
}


struct LearningPreviewSection: View {
    let onLessonTap: (HomeLearningLesson) -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            LearningRow(
                icon: "❤️",
                title: "Benefits of quitting",
                subtitle: "Your body heals from day one",
                onTap: {
                    onLessonTap(HomeLearningLesson(title: "Benefits of quitting", icon: "❤️"))
                }
            )
            LearningRow(
                icon: "🫁",
                title: "What vaping does",
                subtitle: "Understand short and long-term risks",
                onTap: {
                    onLessonTap(HomeLearningLesson(title: "What vaping does", icon: "🫁"))
                }
            )
            LearningRow(
                icon: "💡",
                title: "Tips to quit",
                subtitle: "Craving hacks and routines that work",
                onTap: {
                    onLessonTap(HomeLearningLesson(title: "Tips to quit", icon: "💡"))
                }
            )
            Button(action: { TabNavigationManager.shared.switchToLearnTab() }) {
                HStack(spacing: 6) {
                    Text("Explore the full library")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(Color(red: 0.85, green: 0.32, blue: 0.57).opacity(0.14))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(Color(red: 0.85, green: 0.32, blue: 0.57))
        }
    }
}

struct LearningRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(red: 0.85, green: 0.32, blue: 0.57).opacity(0.15))
                        .frame(width: 48, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0.85, green: 0.32, blue: 0.57).opacity(0.25), lineWidth: 1)
                        )
                    Image(systemName: icon)
                        .foregroundColor(Color(red: 0.85, green: 0.32, blue: 0.57))
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Circle()
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.secondary)
                    )
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Calendar Modal
struct MonthlyCalendarView: View {
    @EnvironmentObject var dataStore: AppDataStore
    private let calendar = Calendar.current
    private var monthDays: [Date] {
        let today = Date()
        let comps = calendar.dateComponents([.year, .month], from: today)
        let startOfMonth = calendar.date(from: comps) ?? today
        // calendar.range returns Range<Int>; provide a matching fallback 1..<31
        let range: Range<Int> = calendar.range(of: .day, in: .month, for: startOfMonth) ?? (1..<31)
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    private func isVapeFree(_ date: Date) -> Bool {
        dataStore.dailyProgress.contains { p in
            Calendar.current.isDate(p.date, inSameDayAs: date) && p.wasVapeFree
        }
    }
    private func dayNumber(_ date: Date) -> String {
        String(calendar.component(.day, from: date))
    }
    var body: some View {
        VStack(spacing: 12) {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(["S","M","T","W","T","F","S"], id: \.self) { w in
                    Text(w).font(.caption2).foregroundColor(.secondary)
                }
                ForEach(monthDays, id: \.self) { date in
                    let success = isVapeFree(date)
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(success ? Color.green.opacity(0.2) : Color.clear)
                        Text(dayNumber(date))
                            .foregroundColor(success ? .green : .primary)
                            .fontWeight(success ? .semibold : .regular)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 36)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.9)))
            .shadow(radius: 4)
            Spacer(minLength: 0)
        }
        .padding()
        .breathableBackground()
    }
}

// MARK: - Money Saved View
struct MoneySavedView: View {
    @EnvironmentObject var dataStore: AppDataStore
    private var perDay: Double {
        // Get weekly cost from onboarding, or use $20/week as fallback
        let weeklyCost = (dataStore.currentUser?.profile.vapingHistory.dailyCost ?? 0) > 0
            ? (dataStore.currentUser?.profile.vapingHistory.dailyCost ?? 0)
            : 20.0
        return weeklyCost / 7.0
    }
    private var projections: [(title: String, days: Int)] {
        [("1 Month", 30), ("6 Months", 182), ("1 Year", 365)]
    }
    var body: some View {
        VStack(spacing: 16) {
            // Simple bar chart
            let maxVal = max(1.0, projections.map { Double($0.days) * perDay }.max() ?? 1)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(projections, id: \.title) { item in
                    let val = Double(item.days) * perDay
                    HStack {
                        Text(item.title).frame(width: 90, alignment: .leading)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.gray.opacity(0.15))
                                Capsule().fill(Color.blue.opacity(0.6))
                                    .frame(width: max(8, geo.size.width * CGFloat(val / maxVal)))
                            }
                        }
                        .frame(height: 16)
                        Text("$\(Int(val))").frame(width: 70, alignment: .trailing)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.9)))
            .shadow(radius: 4)

            VStack(alignment: .leading, spacing: 6) {
                let weeklyCost = (dataStore.currentUser?.profile.vapingHistory.dailyCost ?? 0) > 0
                    ? (dataStore.currentUser?.profile.vapingHistory.dailyCost ?? 0)
                    : 20.0
                Text("Your weekly cost: $\(Int(weeklyCost))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text("Estimated savings assume consistent avoidance of vaping.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .breathableBackground()
    }
}

// MARK: - Health Improvements Detail
struct HealthImprovementsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    private var days: Int {
        dataStore.daysSinceQuitStartDate()
    }
    private var timeline: [(when: String, description: String, minDays: Int)] {
        [
            ("20 minutes", "Heart rate and blood pressure drop", 0),
            ("24 hours", "Carbon monoxide levels normalize", 1),
            ("72 hours", "Nicotine is out of your system", 3),
            ("1 week", "Taste and smell improve", 7),
            ("1 month", "Lung function increases up to 30%", 30),
            ("3 months", "Circulation and breathing improve", 90),
            ("1 year", "Risk of heart disease is cut in half", 365)
        ]
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("You’ve been vape‑free for \(days) day\(days == 1 ? "" : "s").")
                    .font(.headline)
                Text("Here’s what your body is likely experiencing based on time since quitting:")
                    .foregroundColor(.secondary)
                VStack(spacing: 12) {
                    ForEach(timeline, id: \.minDays) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: days >= item.minDays ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(days >= item.minDays ? .green : .gray)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.when).font(.subheadline).fontWeight(.semibold)
                                Text(item.description).font(.footnote).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.9)))
                    }
                }
            }
            .padding()
        }
        .breathableBackground()
    }
}

struct CelebrationView: View {
    @Binding var isShowing: Bool
    @State private var animationPhase = 0
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.4)
                    .onTapGesture {
                        isShowing = false
                    }
                
                ConfettiView()
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                
                VStack(spacing: 20) {
                    Text("🌟")
                        .font(.system(size: 64))
                        .scaleEffect(animationPhase == 0 ? 0.6 : 1.15)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: animationPhase)
                    
                    VStack(spacing: 8) {
                        Text("Milestone unlocked")
                            .font(.title2.weight(.bold))
                            .foregroundColor(Color(red: 0.85, green: 0.32, blue: 0.57))
                        Text("Each milestone unlocks brighter breathing—take a moment to feel that win.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Continue") {
                        isShowing = false
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 20)
                )
                .scaleEffect(animationPhase == 0 ? 0.8 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationPhase)
            }
            .onAppear {
                animationPhase = 1
            }
        }
    }
}

// Helper struct to fix the CheckInSection binding issue
struct CheckInSectionWrapper: View {
    @Binding var showCheckIn: Bool
    
    var body: some View {
        CheckInSection(showCheckIn: $showCheckIn)
    }
}

#if DEBUG
private enum DevDestination: Identifiable {
    case onboarding
    
    var id: Int { hashValue }
}
#endif

// MARK: - New Hero Views

private struct HomeSection<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    
    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.capitalized)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            content
        }
        .softCard(accent: Color(red: 0.45, green: 0.72, blue: 0.99), cornerRadius: 28)
    }
}

private struct CheckInStatusButton: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Binding var showCheckIn: Bool
    @State private var selectedCheckIn: DailyProgress? = nil
    
    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return dataStore.dailyProgress.contains { progress in
            Calendar.current.isDate(progress.date, inSameDayAs: today)
        }
    }
    
    private var todayCheckIn: DailyProgress? {
        let today = Calendar.current.startOfDay(for: Date())
        return dataStore.dailyProgress.first { progress in
            Calendar.current.isDate(progress.date, inSameDayAs: today)
        }
    }
    
    var body: some View {
        Button(action: {
            if !hasCheckedInToday {
                showCheckIn = true
            } else if let checkIn = todayCheckIn {
                selectedCheckIn = checkIn
            }
        }) {
            HStack(spacing: 16) {
                // Icon
            if hasCheckedInToday {
                    // Green checkmark circle when completed
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 40, height: 40)
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                } else {
                    // Hourglass icon when not done
                    Image(systemName: "hourglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(hasCheckedInToday ? "You've completed today's check-in" : "You haven't done your check-in")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(hasCheckedInToday ? "Great job maintaining your commitment" : "Take a moment to reflect and stay strong")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                    Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                }
                .padding()
                .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(hasCheckedInToday ? Color.green : Color.clear, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(item: $selectedCheckIn) { checkIn in
            CheckInDetailView(checkIn: checkIn)
                .environmentObject(dataStore)
        }
    }
}

private struct ReadingOfTheDayButton: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Binding var selectedLesson: Lesson?
    
    private var readingOfTheDay: Lesson {
        getReadingOfTheDay()
    }
    
    private var isCompleted: Bool {
        dataStore.isReadingOfTheDayCompleted()
    }
    
    var body: some View {
        Button(action: {
            selectedLesson = readingOfTheDay
        }) {
            HStack(spacing: 16) {
                // Icon - checkmark when completed, hourglass when not
                if isCompleted {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 40, height: 40)
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
            } else {
                    Image(systemName: "hourglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(isCompleted ? "You've completed today's reading" : "Complete today's reading")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(isCompleted ? "Great job maintaining your commitment" : readingOfTheDay.title)
                        .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                        Spacer()
                
                // Chevron
                        Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    }
                    .padding()
                    .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                            .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCompleted ? Color.green : Color.clear, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getReadingOfTheDay() -> Lesson {
        let allReadings = [
            Lesson.withContent(
                title: "Benefits of quitting",
                summary: "Your body heals from day one.",
                durationMinutes: 9,
                icon: "❤️",
                content: getExpandedBenefitsContent(),
                sources: ["American Heart Association - Benefits of Quitting Smoking", "Centers for Disease Control and Prevention - Health Benefits Timeline", "Mayo Clinic - Quitting Smoking: Health Benefits", "National Cancer Institute - Health Benefits of Quitting", "American Lung Association - Benefits of Quitting", "World Health Organization - Tobacco Cessation Benefits"]
            ),
            Lesson.withContent(
                title: "What vaping does",
                summary: "Understand short and long-term risks.",
                durationMinutes: 12,
                icon: "🫁",
                content: getExpandedVapingContent(),
                sources: ["National Institute on Drug Abuse - Vaping Health Effects", "American Lung Association - Health Risks of Vaping", "World Health Organization - Electronic Nicotine Delivery Systems", "Centers for Disease Control and Prevention - Health Effects of E-Cigarettes", "Journal of the American Heart Association - Cardiovascular Effects of E-Cigarettes", "Nature Reviews Drug Discovery - Nicotine Addiction and Health Effects"]
            ),
            Lesson.withContent(
                title: "Tips to quit",
                summary: "Craving hacks and routines that work.",
                durationMinutes: 9,
                icon: "💡",
                content: getExpandedTipsContent(),
                sources: ["Centers for Disease Control and Prevention - Tips for Quitting", "American Cancer Society - Quitting Guide", "Smokefree.gov - Quit Plan", "National Institute on Drug Abuse - Principles of Drug Addiction Treatment", "Mayo Clinic - Quitting Smoking: 10 Ways to Resist Tobacco Cravings", "American Psychological Association - Strategies for Behavior Change"]
            )
        ]
        
        // Get today's date as a seed for consistent daily selection
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 0
        
        // Use day of year as seed to get consistent random selection per day
        var generator = SeededRandomNumberGenerator(seed: UInt64(dayOfYear))
        let randomIndex = Int.random(in: 0..<allReadings.count, using: &generator)
        
        return allReadings[randomIndex]
    }
}

// Helper for seeded random number generation
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}

private struct ConfettiView: View {
    private let particles: [ConfettiParticle] = {
        let palette: [Color] = [
            Color(red: 0.85, green: 0.32, blue: 0.57),
            Color(red: 0.38, green: 0.63, blue: 0.97),
            Color(red: 0.26, green: 0.67, blue: 0.61),
            Color.orange,
            Color.white
        ]
        let symbols = ["●", "✦", "▴", "✱"]
        return (0..<24).map { index in
            ConfettiParticle(
                relativeX: Double.random(in: 0...1),
                color: palette[index % palette.count].opacity(0.9),
                rotation: Double.random(in: -160...160),
                size: CGFloat.random(in: 10...17),
                symbol: symbols.randomElement() ?? "●",
                delay: Double.random(in: 0...0.6)
            )
        }
    }()
    
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                Text(particle.symbol)
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
                    .position(
                        x: CGFloat(particle.relativeX) * geo.size.width,
                        y: animate ? geo.size.height + 60 : -60
                    )
                    .rotationEffect(.degrees(animate ? particle.rotation : 0))
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        Animation.easeOut(duration: 2.6)
                            .delay(particle.delay),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let relativeX: Double
    let color: Color
    let rotation: Double
    let size: CGFloat
    let symbol: String
    let delay: Double
}

private struct SlipButton: View {
    let resetAction: () -> Void
    var body: some View {
        Button(action: resetAction) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .foregroundColor(.white)
                Text("Had a slip")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.94, green: 0.33, blue: 0.33), Color(red: 0.74, green: 0.13, blue: 0.26)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(red: 0.74, green: 0.13, blue: 0.26).opacity(0.25), radius: 16, x: 0, y: 10)
            )
            .foregroundColor(.white)
        }
        .accessibilityLabel("Record a slip and restart kindly")
    }
}


struct BreathingLungCharacter: View {
    let daysSinceStart: Int
    @State private var breathe: Bool = false
    @State private var bob: Bool = false
    
    private var stage: Int {
        switch daysSinceStart {
        case ..<5:
            return 0
        case 5..<15:
            return 25
        case 15..<30:
            return 50
        case 30..<50:
            return 75
        default:
            return 100
        }
    }
    
    private var assetName: String { "LungBuddy_\(stage)" }
    private var hasAsset: Bool { UIImage(named: assetName) != nil }
    private var progress: Double { Double(stage) / 100.0 }
    
    var body: some View {
        Group {
            if hasAsset {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
            } else {
                LungCharacter(healthLevel: stage, isAnimating: true)
            }
        }
            .frame(width: 220 * 1.4, height: 176 * 1.4)
            .scaleEffect(breathe ? 1.02 : 0.98)
            .offset(y: bob ? -4 : 4)
            .animation(breathingAnimation, value: breathe)
            .animation(bobbingAnimation, value: bob)
            .accessibilityHidden(true)
            .onAppear { breathe = true; bob = true }
    }
    
    private var animationDuration: Double {
        let base = 2.2
        let factor = 1.2 - progress
        return max(0.9, base * factor)
    }
    
    private var breathingAnimation: Animation {
        .easeInOut(duration: animationDuration).repeatForever(autoreverses: true)
    }
    
    private var bobbingAnimation: Animation {
        let duration = max(0.9, 2.0 * (1.2 - progress))
        return .easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}

struct HealthIndicator: View {
    let healthLevel: Int
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Lung Health")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(healthLevel)%")
                    .font(.subheadline).bold()
                    .monospacedDigit()
                    .accessibilityLabel("Lung health \(healthLevel) percent")
            }
            SwiftUI.ProgressView(value: Double(healthLevel) / 100.0)
                .tint(.pink)
                .accessibilityHidden(true)
        }
    }
}

struct SupportMessage: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .accessibilityLabel("Support message: \(text)")
    }
}

#if DEBUG
// MARK: - Developer Menu (DEBUG only)
struct DevMenuView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.presentationMode) var presentationMode
    @State private var showDevCheckIn: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Timer")) {
                    Button("Reset timer to now") { setStartDate(to: Date()) }
                    Button("Advance +1 hour") { shiftStartDate(hours: 1) }
                    Button("Advance +1 day") { shiftStartDate(days: 1) }
                    Button("Advance +7 days") { shiftStartDate(days: 7) }
                }
                
                Section(header: Text("Check-in")) {
                    Button("Re-do today's check-in") { showDevCheckIn = true }
                }
                
                Section(header: Text("Superwall")) {
                    Button("Test 'onboarding_end' placement") {Superwall.shared.register(placement: "onboarding_end")}
                }
            }
            .navigationTitle("Developer Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .sheet(isPresented: $showDevCheckIn) {
            CheckInModalView()
                .environmentObject(dataStore)
        }
    }
    
    private func setStartDate(to date: Date) {
        guard var user = dataStore.currentUser else { return }
        user.startDate = date
        dataStore.currentUser = user
        dataStore.persist()
        dataStore.updateLungHealth()
        NotificationCenter.default.post(name: NSNotification.Name("UserStartDateChanged"), object: nil)
    }
    
    private func shiftStartDate(days: Int = 0, hours: Int = 0, minutes: Int = 0) {
        let seconds = (days * 86_400) + (hours * 3_600) + (minutes * 60)
        guard let current = dataStore.currentUser?.startDate else { return }
        let newDate = current.addingTimeInterval(TimeInterval(-seconds))
        setStartDate(to: newDate)
    }
}
#endif

// MARK: - New Check-in Button (Circular with pen icon)
struct CheckInButton: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Binding var showCheckIn: Bool
    
    @State private var isPulsing: Bool = false
    
    private var hasCheckedInToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return dataStore.dailyProgress.contains { progress in
            Calendar.current.isDate(progress.date, inSameDayAs: today)
        }
    }
    
    private var accentGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(red: 0.45, green: 0.72, blue: 0.99), Color(red: 0.60, green: 0.80, blue: 1.0)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var completedGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.green.opacity(0.85), Color.green.opacity(0.65)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: {
            if !hasCheckedInToday {
                showCheckIn = true
            }
        }) {
            ZStack {
                Circle()
                    .fill(hasCheckedInToday ? completedGradient : accentGradient)
                    .frame(width: 64, height: 64)
                    .shadow(color: (hasCheckedInToday ? Color.green : Color(red: 0.45, green: 0.72, blue: 0.99)).opacity(0.34), radius: 18, x: 0, y: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(hasCheckedInToday ? 0.28 : 0.45), lineWidth: 3)
                    )
                    .scaleEffect(hasCheckedInToday ? 1.0 : (isPulsing ? 1.05 : 0.97))
                    .animation(
                        hasCheckedInToday ? .default : .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                        value: isPulsing
                    )
                
                Circle()
                    .stroke((hasCheckedInToday ? Color.green : Color(red: 0.45, green: 0.72, blue: 0.99)).opacity(0.18), lineWidth: 1.5)
                    .frame(width: 74, height: 74)
                    .opacity(hasCheckedInToday ? 0.4 : 0.7)
                
                Image(systemName: hasCheckedInToday ? "checkmark" : "pencil")
                    .foregroundColor(.white)
                    .font(.title3.weight(.bold))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear { isPulsing = true }
        .accessibilityLabel(hasCheckedInToday ? "You’re checked in for today" : "Open daily check-in")
    }
}

// MARK: - Days Counter View
struct DaysCounterView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var now: Date = Date()
    
    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 1, on: .main, in: .common)
    }
    
    private var startDate: Date {
        dataStore.currentUser?.startDate ?? Date()
    }
    
    private var days: Int {
        let elapsed = now.timeIntervalSince(startDate)
        return max(0, Int(elapsed) / 86_400)
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(days)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            Text("Days")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
        .onReceive(timer.autoconnect()) { newValue in
            now = newValue
        }
        .onAppear {
            now = Date()
        }
        .onChange(of: dataStore.currentUser?.startDate) { _, _ in
            now = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserStartDateChanged"))) { _ in
            now = Date()
        }
    }
}

// MARK: - New Hero Timer View (days, hours, minutes, seconds format)
struct NewHeroTimerView: View {
    @EnvironmentObject var dataStore: AppDataStore
    var onMilestone: (() -> Void)? = nil
    
    @State private var now: Date = Date()
    @AppStorage("lastMilestoneNotifiedDays") private var lastMilestoneNotifiedDays: Int = 0
    
    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 1, on: .main, in: .common)
    }
    
    private var startDate: Date {
        dataStore.currentUser?.startDate ?? Date()
    }
    
    var body: some View {
        let elapsed = now.timeIntervalSince(startDate)
        let totalSeconds = max(0, Int(elapsed))
        let days = totalSeconds / 86_400
        let hours = (totalSeconds % 86_400) / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60
        
        HStack(spacing: 16) {
            timeMetric(value: hours, label: "hrs")
            timeMetric(value: minutes, label: "mins")
            timeMetric(value: seconds, label: "secs")
        }
        .onReceive(timer.autoconnect()) { newValue in
            now = newValue
            dataStore.updateLungHealth()
            handleMilestonesIfNeeded()
        }
        .onAppear {
            now = Date()
            dataStore.updateLungHealth()
        }
        .onChange(of: dataStore.currentUser?.startDate) { _, _ in
            now = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserStartDateChanged"))) { _ in
            now = Date()
        }
    }
    
    private func handleMilestonesIfNeeded() {
        let elapsed = now.timeIntervalSince(startDate)
        let days = max(0, Int(elapsed) / 86_400)
        guard let nextMilestone = nextMilestoneDay(after: lastMilestoneNotifiedDays) else { return }
        if days >= nextMilestone {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            lastMilestoneNotifiedDays = nextMilestone
            onMilestone?()
        }
    }
    
    private func nextMilestoneDay(after day: Int) -> Int? {
        let milestones = [1, 3, 7, 14, 30, 60, 90, 120, 180, 365]
        return milestones.first { $0 > day }
    }
    
    private func timeMetric(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.primary)
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.medium)
                .kerning(0.8)
                .foregroundColor(.secondary)
        }
    }
}

struct WeekdayStreakRow: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
    
    private func hasCheckIn(on date: Date) -> Bool {
        dataStore.dailyProgress.contains { Calendar.current.isDate($0.date, inSameDayAs: date) && $0.wasVapeFree }
    }
    
    private func shortWeekday(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "EEE"
        return df.string(from: date).uppercased()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                VStack(spacing: 8) {
                    Text(shortWeekday(date))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                            .frame(width: 32, height: 32)
                        
                        if hasCheckIn(on: date) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                                .transition(.scale)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct LungBuddyCenter: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    var body: some View {
        BreathingLungCharacter(daysSinceStart: dataStore.daysSinceQuitStartDate())
            .scaleEffect(1.2) // Make LungBuddy bigger
    }
}

struct HeroTimerView: View {
    @EnvironmentObject var dataStore: AppDataStore
    let startDate: Date
    var onMilestone: (() -> Void)? = nil
    
    @State private var now: Date = Date()
    @AppStorage("lastMilestoneNotifiedDays") private var lastMilestoneNotifiedDays: Int = 0
    
    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 1, on: .main, in: .common)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Timer label
            Text("You have been vape-free for")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Main timer display
            Text(formattedTime)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .bold()
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            // Live seconds chip
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .scaleEffect(now.timeIntervalSince1970.truncatingRemainder(dividingBy: 2) < 1 ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: now)
                
                Text("\(seconds)s")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .onReceive(timer.autoconnect()) { newValue in
            now = newValue
            dataStore.updateLungHealth()
            handleMilestonesIfNeeded()
        }
        .onAppear {
            dataStore.updateLungHealth()
        }
    }
    
    private var elapsed: TimeInterval { now.timeIntervalSince(startDate) }
    
    private var formattedTime: String {
        let totalSeconds = max(0, Int(elapsed))
        let days = totalSeconds / 86_400
        let hours = (totalSeconds % 86_400) / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        
        return "\(days)d \(hours)hrs \(minutes)mins"
    }
    
    private var seconds: Int {
        max(0, Int(elapsed) % 60)
    }
    
    private func handleMilestonesIfNeeded() {
        let days = max(0, Int(elapsed) / 86_400)
        guard let nextMilestone = nextMilestoneDay(after: lastMilestoneNotifiedDays) else { return }
        if days >= nextMilestone {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            lastMilestoneNotifiedDays = nextMilestone
            onMilestone?()
        }
    }
    
    private func nextMilestoneDay(after day: Int) -> Int? {
        let milestones = [1, 3, 7, 14, 30, 60, 90, 120, 180, 365]
        return milestones.first { $0 > day }
    }
}

// MARK: - Action Buttons
private struct ActionButton: View {
    let icon: String
    let label: String
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    
                    if isCompleted {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 56, height: 56)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isCompleted ? .green : .black)
                }
                
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FireStreakIcon: View {
    @EnvironmentObject var dataStore: AppDataStore
    
    private var consecutiveCheckInDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var consecutiveDays = 0
        
        // Get all check-in dates sorted by date (most recent first)
        let checkInDates = dataStore.dailyProgress
            .filter { $0.wasVapeFree }
            .map { calendar.startOfDay(for: $0.date) }
            .sorted { $0 > $1 }
        
        // Count consecutive days from today backwards
        var currentDate = today
        for checkInDate in checkInDates {
            if calendar.isDate(checkInDate, inSameDayAs: currentDate) {
                consecutiveDays += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return consecutiveDays
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundColor(.orange)
            
            Text("\(consecutiveCheckInDays)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(AppDataStore())
}
