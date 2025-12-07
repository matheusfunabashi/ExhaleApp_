import SwiftUI

struct LearningView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedLesson: Lesson? = nil
    
    private var topics: [LearningTopic] {
        [
            LearningTopic(
                kind: .physical,
                title: "Physical health",
                blurb: "Understand how your body heals from the inside out.",
                accent: .green,
                lessons: [
                    Lesson.withContent(
                        title: "Oxygen rebound",
                        summary: "How blood oxygen and heart rate improve within 24 hours.",
                        durationMinutes: 2,
                        icon: "lungs.fill",
                        content: "Within just 20 minutes of your last vape, your heart rate begins to normalize. After 2 hours, blood oxygen levels start to improve as carbon monoxide clears from your system. By 12-24 hours, your circulation has significantly improved, delivering more oxygen to your tissues and organs.\n\nThis rapid improvement happens because your body is no longer fighting the constricting effects of nicotine on blood vessels. Your heart doesn't have to work as hard, and your cells receive the oxygen they need to function optimally.",
                        sources: ["American Heart Association - Cardiovascular Benefits of Quitting", "National Institute on Drug Abuse - Nicotine Withdrawal Timeline"]
                    ),
                    Lesson.withContent(
                        title: "Lung repair timeline",
                        summary: "Daily milestones as cilia and lung capacity return.",
                        durationMinutes: 3,
                        icon: "waveform.path.ecg",
                        content: "Your lungs have an incredible capacity to heal. Here's what happens:\n\n• Days 1-3: Cilia (tiny hair-like structures) begin to regenerate, helping clear mucus and debris from your airways.\n• Week 1: Lung function starts improving. You may notice easier breathing and less coughing.\n• Month 1: Cilia are fully functional again. Your lung capacity increases, and exercise becomes easier.\n• Months 3-9: Lung function continues to improve. The risk of infection decreases significantly.\n• Year 1: Your lung capacity can improve by up to 10%, and the risk of chronic lung disease continues to decrease.\n\nEvery day without vaping gives your lungs more time to heal and repair.",
                        sources: ["American Lung Association - Lung Health Benefits Timeline", "Mayo Clinic - Lung Recovery After Quitting"]
                    ),
                    Lesson.withContent(
                        title: "Movement that supports healing",
                        summary: "Gentle routines that open your chest and calm cravings.",
                        durationMinutes: 2,
                        icon: "figure.walk",
                        content: "Physical activity is one of the most powerful tools for recovery. Gentle movement helps in multiple ways:\n\n• Opens your chest: Deep breathing exercises and stretching expand your rib cage, improving lung capacity.\n• Reduces cravings: Exercise releases endorphins and dopamine naturally, reducing the urge to vape.\n• Improves circulation: Movement helps your body deliver oxygen more efficiently.\n• Builds confidence: Each walk or stretch session reinforces your commitment to healing.\n\nStart with 10-15 minutes of walking, gentle yoga, or stretching. Focus on deep, slow breaths. As your lung capacity improves, gradually increase duration and intensity. Even 5 minutes of movement can make a difference when cravings hit.",
                        sources: ["Centers for Disease Control and Prevention - Physical Activity Guidelines", "Journal of Addiction Medicine - Exercise and Smoking Cessation"]
                    )
                ]
            ),
            LearningTopic(
                kind: .mental,
                title: "Mental resilience",
                blurb: "Build calm habits and mindset shifts for the long term.",
                accent: Color(red: 0.67, green: 0.52, blue: 0.93),
                lessons: [
                    Lesson.withContent(
                        title: "Urge surfing",
                        summary: "Ride cravings with mindful breathing in under two minutes.",
                        durationMinutes: 2,
                        icon: "wind",
                        content: "Urge surfing is a mindfulness technique that helps you observe cravings without acting on them. Instead of fighting the urge, you learn to ride it like a wave.\n\nHere's how:\n\n1. Notice the craving: Acknowledge it without judgment. Say to yourself, 'I'm having a craving right now.'\n2. Observe it: Where do you feel it in your body? What thoughts come with it?\n3. Breathe through it: Take 4-7-8 breaths (inhale for 4, hold for 7, exhale for 8).\n4. Remember it passes: Cravings typically peak within 3-5 minutes and then subside.\n5. Ride the wave: Watch the craving rise, peak, and fall without acting on it.\n\nEach time you successfully surf an urge, you're rewiring your brain. The craving loses its power, and you gain confidence in your ability to handle difficult moments.",
                        sources: ["Mindfulness-Based Relapse Prevention - Urge Surfing Technique", "Journal of Substance Abuse Treatment - Mindfulness and Addiction"]
                    ),
                    Lesson.withContent(
                        title: "Rewrite the story",
                        summary: "Reframe slips with compassionate language and intention.",
                        durationMinutes: 3,
                        icon: "quote.bubble",
                        content: "If you slip, the story you tell yourself matters. Harsh self-criticism can lead to giving up entirely. Instead, practice compassionate reframing:\n\nInstead of: 'I failed. I'm weak. I'll never quit.'\nTry: 'I had a slip. This is a learning opportunity. I can get back on track.'\n\nKey reframing principles:\n\n• Slips are data, not destiny: Each slip teaches you about your triggers and patterns.\n• Progress isn't linear: Recovery involves ups and downs. One slip doesn't erase your progress.\n• Self-compassion builds resilience: Treating yourself with kindness makes it easier to try again.\n• Focus on what you learned: What triggered the slip? What will you do differently next time?\n\nRemember: People who successfully quit often have multiple attempts. Each attempt teaches you something valuable. Your story isn't over—it's being rewritten with each choice you make.",
                        sources: ["Self-Compassion Research - Kristin Neff", "Addiction Research & Theory - Self-Compassion and Recovery"]
                    ),
                    Lesson.withContent(
                        title: "Micro-celebrations",
                        summary: "Celebrate tiny wins to anchor motivation each day.",
                        durationMinutes: 2,
                        icon: "sparkles",
                        content: "Small celebrations create positive reinforcement loops that strengthen your motivation. When you acknowledge your progress, your brain releases dopamine—the same reward chemical that vaping triggered, but now it's tied to healthy behaviors.\n\nWhat to celebrate:\n\n• Waking up without vaping\n• Completing a craving without giving in\n• Choosing water over vaping\n• Taking a walk when you felt an urge\n• Going to bed vape-free\n• One hour, one day, one week vape-free\n\nHow to celebrate:\n\n• Acknowledge it out loud: 'I did it!'\n• Share with someone supportive\n• Do something you enjoy (read, listen to music, call a friend)\n• Track it in your app\n• Give yourself a mental high-five\n\nThese micro-celebrations build momentum. Each small win proves you're capable of change. Over time, these moments accumulate into significant progress. Your brain learns that not vaping feels good, too.",
                        sources: ["Behavioral Neuroscience - Reward Pathways and Motivation", "Positive Psychology Research - Celebrating Small Wins"]
                    )
                ]
            ),
            LearningTopic(
                kind: .lifestyle,
                title: "Lifestyle & triggers",
                blurb: "Swap routines and prepare for the moments that matter.",
                accent: Color(red: 0.85, green: 0.32, blue: 0.57),
                lessons: [
                    Lesson.withContent(
                        title: "Morning rituals",
                        summary: "Start the day grounded to reduce cravings later on.",
                        durationMinutes: 2,
                        icon: "sunrise.fill",
                        content: "Your morning routine sets the tone for the entire day. Replacing vaping with grounding rituals can significantly reduce cravings throughout the day.\n\nEffective morning rituals:\n\n• Deep breathing: 5 minutes of intentional breathing activates your parasympathetic nervous system, reducing stress and cravings.\n• Hydration: Start with a large glass of water. Dehydration can mimic cravings.\n• Movement: Even 5 minutes of stretching or walking signals to your body that you're choosing health.\n• Gratitude: Write down or think of 3 things you're grateful for. This shifts your mindset from lack to abundance.\n• Plan your day: Knowing your schedule and having strategies for challenging moments reduces anxiety.\n\nWhy it works: Morning rituals create new neural pathways. Instead of reaching for your vape, your brain learns to reach for these healthier alternatives. The routine itself becomes calming and rewarding.",
                        sources: ["Journal of Health Psychology - Morning Routines and Stress Reduction", "Neuroscience Research - Habit Formation and Neural Pathways"]
                    ),
                    Lesson.withContent(
                        title: "Social support toolkit",
                        summary: "Ask for what you need from friends without pressure.",
                        durationMinutes: 2,
                        icon: "person.2.fill",
                        content: "Social support is one of the strongest predictors of successful quitting. However, asking for help can feel vulnerable. Here's how to build your support toolkit:\n\nWho to include:\n\n• Someone who's quit successfully: They understand the journey and can offer practical advice.\n• A non-judgmental friend: Someone who won't lecture but will listen and encourage.\n• An accountability partner: Someone you can check in with daily or weekly.\n• Online communities: Support groups where you can share anonymously.\n\nHow to ask for support:\n\n• Be specific: 'Can I text you when I'm having a craving?'\n• Set boundaries: 'I need encouragement, not lectures.'\n• Express gratitude: 'Thank you for supporting me in this.'\n• Offer reciprocity: 'How can I support you in return?'\n\nRemember: Asking for help is a strength, not a weakness. Most people want to help but don't know how. By being specific about your needs, you make it easier for them to support you effectively.",
                        sources: ["American Psychological Association - Social Support and Health Behavior Change", "Addiction Science & Clinical Practice - Peer Support in Recovery"]
                    ),
                    Lesson.withContent(
                        title: "Evening unwinding",
                        summary: "Wind down without the vape—sleep-friendly swaps.",
                        durationMinutes: 3,
                        icon: "moon.stars.fill",
                        content: "Evening was likely a prime vaping time. Creating new wind-down rituals helps break this association and improves your sleep quality.\n\nSleep-friendly alternatives:\n\n• Herbal tea: Chamomile, lavender, or valerian root tea can promote relaxation without the stimulant effects of nicotine.\n• Reading: A physical book (not a screen) helps your mind transition from active to restful.\n• Gentle stretching: 10 minutes of yoga or stretching releases physical tension.\n• Journaling: Write down your thoughts, worries, or gratitudes to clear your mind.\n• Warm bath: The temperature change helps signal to your body that it's time to rest.\n• Breathing exercises: 4-7-8 breathing activates your relaxation response.\n• Aromatherapy: Lavender or eucalyptus can create a calming environment.\n\nWhy it matters: Nicotine disrupts sleep architecture. Without it, you'll sleep more deeply and wake more refreshed. Better sleep reduces stress and cravings the next day. Your evening routine becomes a gift to your future self.",
                        sources: ["Sleep Medicine Reviews - Nicotine and Sleep Quality", "Journal of Behavioral Medicine - Evening Routines and Sleep"]
                    )
                ]
            ),
            LearningTopic(
                kind: .physical,
                title: "Learn & Reflect",
                blurb: "Short reads to reinforce your progress and calm cravings.",
                accent: Color(red: 0.95, green: 0.65, blue: 0.75),
                lessons: [
                    Lesson.withContent(
                        title: "Benefits of quitting",
                        summary: "Your body heals from day one.",
                        durationMinutes: 3,
                        icon: "heart.text.square.fill",
                        content: "Your body begins healing the moment you stop vaping. Understanding these benefits can strengthen your motivation during challenging moments.\n\nImmediate benefits (within hours):\n\n• 20 minutes: Heart rate and blood pressure start to normalize.\n• 12 hours: Carbon monoxide levels drop, allowing more oxygen to reach your cells.\n• 24 hours: Your risk of heart attack begins to decrease.\n\nShort-term benefits (days to weeks):\n\n• 2-3 days: Your sense of taste and smell begin to improve.\n• 1 week: Circulation improves, making physical activity easier.\n• 2-4 weeks: Lung function increases, and you'll notice easier breathing.\n\nLong-term benefits (months to years):\n\n• 1-3 months: Cilia in your lungs fully recover, reducing infection risk.\n• 1 year: Your risk of heart disease drops by 50%.\n• 5 years: Stroke risk decreases significantly.\n• 10 years: Lung cancer risk drops by 50% compared to continued vaping.\n\nEvery moment without vaping is a step toward better health. Your body is designed to heal—you just need to give it the chance.",
                        sources: ["American Heart Association - Benefits of Quitting Smoking", "Centers for Disease Control and Prevention - Health Benefits Timeline", "Mayo Clinic - Quitting Smoking: Health Benefits"]
                    ),
                    Lesson.withContent(
                        title: "What vaping does",
                        summary: "Understand short and long-term risks.",
                        durationMinutes: 4,
                        icon: "lungs.fill",
                        content: "Understanding what happens in your body when you vape can help clarify why quitting matters.\n\nShort-term effects:\n\n• Nicotine constricts blood vessels: This increases heart rate and blood pressure, making your heart work harder.\n• Reduces oxygen delivery: Carbon monoxide from vaping binds to red blood cells, reducing the amount of oxygen your body receives.\n• Affects brain chemistry: Nicotine triggers dopamine release, creating dependency and altering reward pathways.\n• Impairs lung function: Vaping can cause inflammation and reduce lung capacity, even in the short term.\n\nLong-term risks:\n\n• Cardiovascular disease: Chronic exposure increases the risk of heart attack, stroke, and peripheral artery disease.\n• Respiratory problems: Long-term vaping can lead to chronic bronchitis, emphysema, and reduced lung function.\n• Cancer risk: While research is ongoing, vaping exposes you to carcinogens and increases cancer risk.\n• Immune system: Vaping weakens your immune response, making you more susceptible to infections.\n• Mental health: Nicotine dependency can increase anxiety and depression over time.\n\nKnowledge is power: Understanding these effects isn't meant to create fear, but to empower you with information. Your body has remarkable healing abilities once you stop vaping.",
                        sources: ["National Institute on Drug Abuse - Vaping Health Effects", "American Lung Association - Health Risks of Vaping", "World Health Organization - Electronic Nicotine Delivery Systems"]
                    ),
                    Lesson.withContent(
                        title: "Tips to quit",
                        summary: "Craving hacks and routines that work.",
                        durationMinutes: 3,
                        icon: "lightbulb.fill",
                        content: "Quitting vaping is a journey, and having practical strategies makes all the difference. Here are evidence-based tips that work:\n\n1. Prepare before you quit:\n\nSet a quit date and stick to it. Remove all vaping devices and supplies from your environment. Tell friends and family about your decision for accountability.\n\n2. Replace the habit:\n\nCarry water, sugar-free gum, or healthy snacks. When a craving hits, reach for these instead. Swap your vaping routine with a new activity—walking, reading, or calling a friend.\n\nCravings typically last 3-5 minutes. Try the 4-7-8 breathing technique: inhale for 4, hold for 7, exhale for 8. Do 10 push-ups or take a short walk. Distract yourself with an engaging activity.\n\n4. Manage withdrawal:\n\nExpect some discomfort—it's temporary. Stay hydrated and get plenty of sleep. Consider nicotine replacement therapy if needed, under medical guidance.\n\n5. Recover from slips:\n\nIf you slip, don't give up. Log what happened, identify the trigger, and adjust your strategy. Progress over perfection—every moment vape-free counts.\n\nRemember: Millions of people have successfully quit. You have the tools and the strength to do it too.",
                        sources: ["Centers for Disease Control and Prevention - Tips for Quitting", "American Cancer Society - Quitting Guide", "Smokefree.gov - Quit Plan"]
                    )
                ]
            )
        ]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 22) {
                    ForEach(topics) { topic in
                        LearningTopicCard(
                            topic: topic,
                            progress: progressValue(for: topic),
                            encouragement: encouragement(for: topic),
                            onLessonTap: { lesson in
                                selectedLesson = lesson
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Learn")
            .breathableBackground()
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailModal(lesson: lesson, accent: accentForLesson(lesson))
        }
    }
    
    private func accentForLesson(_ lesson: Lesson) -> Color {
        for topic in topics {
            if topic.lessons.contains(where: { $0.id == lesson.id }) {
                return topic.accent
            }
        }
        return Color(red: 0.16, green: 0.36, blue: 0.87)
    }
    
    private func progressValue(for topic: LearningTopic) -> Double {
        switch topic.kind {
        case .physical:
            return Double(appState.lungState.healthLevel) / 100.0
        case .mental:
            let cappedXP = min(Double(appState.statistics.totalXP), 400)
            return max(0, cappedXP / 400.0)
        case .lifestyle:
            let completed = Double(appState.statistics.completedQuests)
            return min(1.0, completed / 10.0)
        case .learnAndReflect:
            // Progress based on days vape-free
            let days = Double(appState.statistics.daysVapeFree)
            return min(1.0, days / 30.0)
        }
    }
    
    private func encouragement(for topic: LearningTopic) -> String {
        let progress = progressValue(for: topic)
        let percent = Int(progress * 100)
        switch topic.kind {
        case .physical:
            return percent >= 100 ? "Your body is flourishing—keep revisiting lessons when you need a refresher." : "You're restoring each system—these lessons show what's improving right now."
        case .mental:
            return percent >= 100 ? "Your mindset toolkit is shining. Re-read a favorite strategy when cravings whisper." : "Each read is another calm thought ready for the next craving."
        case .lifestyle:
            return percent >= 100 ? "Your routines are resilient—share a tip with someone you care about." : "Swap in one new ritual today and watch the momentum build."
        case .learnAndReflect:
            return percent >= 100 ? "You're building a strong foundation of knowledge—keep learning and growing." : "Every read strengthens your resolve. Knowledge is your ally in this journey."
        }
    }
}

private struct LearningTopicCard: View {
    let topic: LearningTopic
    let progress: Double
    let encouragement: String
    let onLessonTap: (Lesson) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(topic.accent.opacity(0.18))
                        .frame(width: 54, height: 54)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(topic.accent.opacity(0.28), lineWidth: 1)
                        )
                    Image(systemName: topic.icon)
                        .foregroundColor(topic.accent)
                        .font(.title2)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(topic.title)
                        .font(.title3.weight(.semibold))
                    Text(topic.blurb)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 6) {
                        SwiftUI.ProgressView(value: progress)
                            .tint(topic.accent)
                            .frame(height: 4)
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(topic.lessons) { lesson in
                    LessonTile(lesson: lesson, accent: topic.accent, onTap: {
                        onLessonTap(lesson)
                    })
                }
            }
            
            Text(encouragement)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(accent: topic.accent, cornerRadius: 30)
        .accessibilityElement(children: .combine)
    }
}

private struct LessonTile: View {
    let lesson: Lesson
    let accent: Color
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.15))
                        .frame(width: 42, height: 42)
                        .overlay(
                            Circle()
                                .stroke(accent.opacity(0.25), lineWidth: 1)
                        )
                    Image(systemName: lesson.icon)
                        .foregroundColor(accent)
                        .font(.headline)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    Text(lesson.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        Label("\(lesson.durationMinutes) min read", systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(accent)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule()
                                    .fill(accent.opacity(0.12))
                            )
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.6))
        )
        .onTapGesture {
            onTap()
        }
    }
}

struct Lesson: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let durationMinutes: Int
    let icon: String
    let detailedContent: String
    let sources: [String]
    
    init(title: String, summary: String, durationMinutes: Int, icon: String, detailedContent: String = "", sources: [String] = []) {
        self.title = title
        self.summary = summary
        self.durationMinutes = durationMinutes
        self.icon = icon
        self.detailedContent = detailedContent
        self.sources = sources
    }
    
    static func withContent(title: String, summary: String, durationMinutes: Int, icon: String, content: String, sources: [String] = []) -> Lesson {
        return Lesson(title: title, summary: summary, durationMinutes: durationMinutes, icon: icon, detailedContent: content, sources: sources)
    }
}

private struct LearningTopic: Identifiable {
    enum Kind { case physical, mental, lifestyle, learnAndReflect }
    let id = UUID()
    let kind: Kind
    let title: String
    let blurb: String
    let accent: Color
    let lessons: [Lesson]
    
    var icon: String {
        switch kind {
        case .physical: return "lungs.fill"
        case .mental: return "person.crop.circle.badge.checkmark"
        case .lifestyle: return "leaf.fill"
        case .learnAndReflect: return "book.fill"
        }
    }
}

struct TipsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("A practical quitting plan")
                    .font(.title2)
                    .fontWeight(.bold)
                Group {
                    Text("1. Prepare")
                        .font(.headline)
                    Text("Pick a quit date, list your reasons, clear devices.")
                        .foregroundColor(.secondary)
                }
                Group {
                    Text("2. Replace")
                        .font(.headline)
                    Text("Carry water, sugar-free gum, and a fidget. Swap routines.")
                        .foregroundColor(.secondary)
                }
                Group {
                    Text("3. Respond to cravings")
                        .font(.headline)
                    Text("Try 4-7-8 breathing, 10 push-ups or a short walk, and a quick journal note.")
                        .foregroundColor(.secondary)
                }
                Group {
                    Text("4. Recover")
                        .font(.headline)
                    Text("Slip? Log it, learn your trigger, and continue. Progress over perfection.")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Tips to quit")
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Lesson Detail Modal

struct LessonDetailModal: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    let lesson: Lesson
    let accent: Color
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        headerSection
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                            .padding(.bottom, 24)
                        
                        // Meta
                        metaSection
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                        
                        // Content sections
                        contentSections
                            .padding(.horizontal, 24)
                            .padding(.bottom, 100) // Space for sticky button
                        
                        // Sources (if available)
                        if !lesson.sources.isEmpty {
                            sourcesSection
                                .padding(.horizontal, 24)
                                .padding(.bottom, 100)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(accent)
                )
                .breathableBackground()
                
                // Sticky CTA button
                stickyCTAButton
            }
        }
        .preferredColorScheme(nil) // Support both light and dark mode
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(accent.opacity(colorScheme == .dark ? 0.2 : 0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: lesson.icon)
                        .foregroundColor(accent)
                        .font(.system(size: 24, weight: .medium))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(lesson.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Subtitle (summary)
                    Text(lesson.summary)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Meta Section
    private var metaSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            Text("\(lesson.durationMinutes) min read")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.secondary.opacity(colorScheme == .dark ? 0.2 : 0.1))
        )
    }
    
    // MARK: - Content Sections
    private var contentSections: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !lesson.detailedContent.isEmpty {
                ContentText(content: lesson.detailedContent, accent: accent)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
    
    // MARK: - Sources Section
    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sources")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(lesson.sources, id: \.self) { source in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "book.closed.fill")
                            .foregroundColor(accent)
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 20)
                            .padding(.top, 2)
                        
                        Text(source)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(accent.opacity(colorScheme == .dark ? 0.15 : 0.08))
        )
    }
    
    // MARK: - Sticky CTA Button
    private var stickyCTAButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.secondary.opacity(0.2))
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Spacer()
                    Text(getCTAButtonText())
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [accent, accent.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: accent.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                Color(UIColor.systemBackground)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
    
    private func getCTAButtonText() -> String {
        // Generate contextual CTA based on lesson title
        let title = lesson.title.lowercased()
        if title.contains("movement") || title.contains("walk") {
            return "Start 5-min movement"
        } else if title.contains("breathing") || title.contains("urge") {
            return "Try the breathing drill"
        } else if title.contains("ritual") || title.contains("morning") || title.contains("evening") {
            return "Try this ritual"
        } else if title.contains("celebration") {
            return "Celebrate a win"
        } else {
            return "Got it"
        }
    }
}

// MARK: - Content Text Parser
fileprivate struct ContentText: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isVisible = false
    let content: String
    let accent: Color
    
    var body: some View {
        let sections = parseContent(content)
        
        VStack(alignment: .leading, spacing: 20) {
            ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                SectionView(section: section, accent: accent, colorScheme: colorScheme)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                isVisible = true
            }
        }
    }
    
    private func parseContent(_ content: String) -> [ContentSection] {
        var sections: [ContentSection] = []
        let paragraphs = content.components(separatedBy: "\n\n")
        
        var currentSection: ContentSection?
        
        for paragraph in paragraphs {
            let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            
            // Check for numbered steps (e.g., "1. ", "2. ")
            if trimmed.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
                let parts = trimmed.split(separator: ".", maxSplits: 1)
                if parts.count == 2 {
                    let number = String(parts[0]).trimmingCharacters(in: .whitespaces)
                    let text = String(parts[1]).trimmingCharacters(in: .whitespaces)
                    
                    if currentSection == nil {
                        currentSection = ContentSection(title: nil, items: [])
                    }
                    currentSection?.items.append(.step(number: number, text: text))
                    continue
                }
            } else if trimmed.hasPrefix("•") || trimmed.hasPrefix("-") {
                let text = trimmed.dropFirst().trimmingCharacters(in: .whitespaces)
                if currentSection == nil {
                    currentSection = ContentSection(title: nil, items: [])
                }
                currentSection?.items.append(.bullet(text: text))
            } else if trimmed.contains(":") && trimmed.split(separator: ":").count == 2 && !trimmed.contains("http") {
                // Save previous section if exists
                if let section = currentSection {
                    sections.append(section)
                }
                // New section with title
                let parts = trimmed.split(separator: ":", maxSplits: 1)
                currentSection = ContentSection(title: String(parts[0]), items: [])
                if parts.count == 2 {
                    let bodyText = String(parts[1]).trimmingCharacters(in: .whitespaces)
                    if !bodyText.isEmpty {
                        currentSection?.items.append(.paragraph(text: bodyText))
                    }
                }
            } else {
                // Regular paragraph
                if currentSection == nil {
                    currentSection = ContentSection(title: nil, items: [])
                }
                currentSection?.items.append(.paragraph(text: trimmed))
            }
        }
        
        // Add last section
        if let section = currentSection {
            sections.append(section)
        }
        
        return sections.isEmpty ? [ContentSection(title: nil, items: [.paragraph(text: content)])] : sections
    }
}

// MARK: - Content Section Model
fileprivate struct ContentSection {
    let title: String?
    var items: [ContentItem]
}

fileprivate enum ContentItem {
    case paragraph(text: String)
    case bullet(text: String)
    case step(number: String, text: String)
}

// MARK: - Section View
fileprivate struct SectionView: View {
    let section: ContentSection
    let accent: Color
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = section.title {
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)
            }
            
            ForEach(Array(section.items.enumerated()), id: \.offset) { index, item in
                switch item {
                case .paragraph(let text):
                    Text(text)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 600, alignment: .leading)
                    
                case .bullet(let text):
                    BulletRow(text: text, accent: accent, colorScheme: colorScheme)
                    
                case .step(let number, let text):
                    StepRow(number: number, text: text, accent: accent, colorScheme: colorScheme)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Step Row
fileprivate struct StepRow: View {
    let number: String
    let text: String
    let accent: Color
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(accent.opacity(colorScheme == .dark ? 0.25 : 0.15))
                    .frame(width: 28, height: 28)
                
                Text(number)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(accent)
            }
            .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Bullet Row
fileprivate struct BulletRow: View {
    let text: String
    let accent: Color
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(accent)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 20)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    LearningView()
}












