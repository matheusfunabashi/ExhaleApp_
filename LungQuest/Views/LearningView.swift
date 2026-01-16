import SwiftUI

struct LearningView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var selectedLesson: Lesson? = nil
    
    // Primary brand color - used consistently throughout (light blue)
    private let primaryAccentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    private var topics: [LearningTopic] {
        [
            LearningTopic(
                kind: .physical,
                title: "Physical health",
                blurb: "Understand how your body heals from the inside out.",
                accent: primaryAccentColor,
                lessons: [
                    Lesson.withContent(
                        title: "Oxygen rebound",
                        summary: "How blood oxygen and heart rate improve within 24 hours.",
                        durationMinutes: 6,
                        icon: "🫁",
                        content: "Understanding how quickly your body begins to heal can be incredibly motivating. The oxygen rebound effect is one of the most immediate and noticeable improvements you'll experience after quitting vaping. This comprehensive guide will help you understand exactly what's happening in your body and why these changes matter for your long-term health.\n\nTHE FIRST 20 MINUTES: IMMEDIATE CARDIOVASCULAR CHANGES\n\nWithin just 20 minutes of your last vape, remarkable changes begin:\n\n• Heart rate normalization: Your heart rate starts to decrease from the elevated state caused by nicotine. Nicotine increases your heart rate by 10-20 beats per minute, so when you stop, your heart immediately begins to work less hard. This reduction in heart rate reduces strain on your cardiovascular system.\n\n• Blood pressure begins to stabilize: Nicotine causes blood vessels to constrict, which increases blood pressure. As nicotine levels drop, your blood vessels begin to relax and widen, allowing blood to flow more freely. This reduces the pressure your heart must generate to pump blood throughout your body.\n\n• Peripheral circulation improves: You may notice your hands and feet feeling warmer. This happens because nicotine constricts blood vessels in your extremities. As this constriction eases, more blood flows to your hands, feet, and other peripheral areas, improving circulation and warmth.\n\nTHE FIRST 2 HOURS: NICOTINE CLEARANCE AND OXYGEN RECOVERY\n\n• Nicotine levels drop by 50%: Your body begins actively processing and eliminating nicotine from your bloodstream. The half-life of nicotine is approximately 2 hours, meaning half of the nicotine in your system is cleared during this time. This is when you may start to feel the first withdrawal symptoms, but it's also when your body begins to function more normally.\n\n• Carbon monoxide begins to clear: Vape aerosols contain carbon monoxide and other toxins that bind to red blood cells more readily than oxygen. As these substances clear, your red blood cells can carry more oxygen. This is crucial because carbon monoxide has a much higher affinity for hemoglobin than oxygen does, effectively blocking oxygen transport.\n\n• Oxygen saturation improves: As carbon monoxide clears and blood vessels relax, more oxygen can bind to your red blood cells. Your blood oxygen saturation levels begin to increase, meaning more oxygen is available to your tissues and organs.\n\nTHE FIRST 8-12 HOURS: SIGNIFICANT CIRCULATORY IMPROVEMENTS\n\n• Carbon monoxide levels drop dramatically: By 8-12 hours, most of the carbon monoxide from your last vaping session has been cleared from your bloodstream. This is a critical milestone because carbon monoxide reduces your blood's oxygen-carrying capacity by up to 15-20%.\n\n• Enhanced oxygen delivery: With improved circulation and reduced carbon monoxide, your body can deliver significantly more oxygen to your brain, muscles, and organs. You may notice:\n  - Increased mental clarity and alertness\n  - Improved energy levels\n  - Better physical performance\n  - Reduced feelings of fatigue\n\n• Heart function improves: Your heart doesn't have to work as hard to pump oxygenated blood throughout your body. The reduced workload means less strain on your heart muscle and lower risk of cardiovascular events.\n\nTHE FIRST 24 HOURS: MAJOR CARDIOVASCULAR BENEFITS\n\n• Heart attack risk begins to decrease: Research shows that your risk of heart attack starts decreasing within 24 hours of quitting. This is because your cardiovascular system is no longer under constant stress from nicotine and reduced oxygen delivery.\n\n• Blood vessel health improves: The endothelial cells that line your blood vessels begin to function better. These cells produce nitric oxide, which helps blood vessels relax and widen. Nicotine damages these cells, so removing nicotine allows them to begin healing.\n\n• Improved exercise capacity: With better oxygen delivery and circulation, your exercise capacity begins to improve. You may notice you can walk further, climb stairs more easily, or exercise longer without getting winded.\n\nUNDERSTANDING THE SCIENCE: WHY OXYGEN MATTERS\n\nEvery cell in your body needs oxygen to function. When you vape:\n\n• Your blood carries less oxygen due to carbon monoxide binding\n• Your blood vessels are constricted, reducing blood flow\n• Your heart works harder to compensate\n• Your cells receive less oxygen than they need\n\nWhen you quit:\n\n• Carbon monoxide clears, allowing more oxygen binding\n• Blood vessels relax, improving blood flow\n• Your heart works more efficiently\n• Your cells receive the oxygen they need to function optimally\n\nTHE CUMULATIVE EFFECT: LONG-TERM BENEFITS\n\nWhile the immediate improvements are impressive, the long-term benefits are even more significant:\n\n• Reduced cardiovascular disease risk: Over time, improved oxygen delivery and reduced strain on your heart significantly lower your risk of heart disease, stroke, and other cardiovascular problems.\n\n• Better physical performance: Improved oxygen delivery means better athletic performance, more energy for daily activities, and faster recovery from exercise.\n\n• Enhanced brain function: Your brain uses about 20% of your body's oxygen. Better oxygen delivery means improved cognitive function, better memory, and enhanced mental clarity.\n\n• Improved healing: Oxygen is essential for wound healing and tissue repair. Better oxygen delivery means your body can heal more effectively from injuries and illnesses.\n\n• Better sleep: Improved oxygen levels can lead to better sleep quality, as your body doesn't have to work as hard to maintain oxygen levels during sleep.\n\nPRACTICAL TIPS TO MAXIMIZE OXYGEN REBOUND\n\n• Deep breathing exercises: Practice deep, slow breathing to help your body maximize oxygen intake and improve lung capacity.\n\n• Stay hydrated: Proper hydration helps your blood flow more efficiently, improving oxygen delivery.\n\n• Light exercise: Gentle movement like walking helps improve circulation and oxygen delivery throughout your body.\n\n• Avoid secondhand smoke: Exposure to smoke or vape aerosols can still affect your oxygen levels, so avoid these environments.\n\n• Be patient: While improvements begin immediately, full recovery takes time. Your body is healing, and each day brings more improvement.\n\nMONITORING YOUR PROGRESS\n\nYou may notice improvements in:\n\n• Energy levels throughout the day\n• Ability to exercise or be active\n• Mental clarity and focus\n• Sleep quality\n• Overall sense of well-being\n\nRemember: Every moment without vaping is a moment your body is improving oxygen delivery and cardiovascular health. The oxygen rebound effect is one of the first and most noticeable signs that your body is healing. Celebrate these improvements and let them motivate you to continue your quit journey.",
                        sources: ["American Heart Association - Cardiovascular Benefits of Quitting", "National Institute on Drug Abuse - Nicotine Withdrawal Timeline", "Journal of the American College of Cardiology - Acute Cardiovascular Effects of E-Cigarettes", "Circulation Research - Nicotine and Blood Vessel Function", "European Respiratory Journal - Carbon Monoxide and Oxygen Transport", "Mayo Clinic - Blood Oxygen Levels and Health"]
                    ),
                    Lesson.withContent(
                        title: "Lung repair timeline",
                        summary: "Daily milestones as cilia and lung capacity return.",
                        durationMinutes: 9,
                        icon: "💓",
                        content: "Your lungs are remarkable organs with an incredible capacity to heal and regenerate. Understanding the lung repair timeline can help you appreciate the progress your body is making every single day. This comprehensive guide will walk you through exactly what happens in your lungs from the first day to years after quitting vaping.\n\nDAYS 1-3: THE BEGINNING OF REGENERATION\n\n• Cilia begin to regenerate: Cilia are tiny, hair-like structures that line your airways. They act like microscopic brooms, constantly sweeping mucus, debris, and harmful particles out of your lungs. Vaping damages and paralyzes these cilia, but they begin to regenerate within just 24-48 hours of quitting.\n\n• Mucus clearance improves: As cilia begin to function again, your lungs become more effective at clearing mucus and debris. You may notice increased coughing initially—this is actually a good sign. Your lungs are actively clearing out accumulated toxins and mucus that couldn't be removed while cilia were damaged.\n\n• Inflammation begins to decrease: Vaping causes chronic inflammation in your airways. Within the first few days, this inflammation begins to decrease as your body stops being exposed to the irritants in vape aerosols.\n\n• Airway constriction eases: The chemicals in vape products can cause your airways to constrict, making breathing more difficult. As these chemicals clear, your airways begin to relax and widen, allowing for easier airflow.\n\nWEEK 1: NOTICEABLE FUNCTIONAL IMPROVEMENTS\n\n• Lung function starts improving: Spirometry tests (which measure lung function) show measurable improvements within the first week. Your forced expiratory volume (FEV1) and forced vital capacity (FVC) begin to increase.\n\n• Easier breathing: You'll likely notice that breathing feels easier, especially during physical activity. Simple tasks like climbing stairs or walking may become less taxing.\n\n• Reduced coughing: As your lungs clear out accumulated debris and inflammation decreases, coughing should diminish. The productive cough you may have experienced in the first few days should begin to subside.\n\n• Improved oxygen exchange: The tiny air sacs in your lungs (alveoli) begin to function more efficiently. These sacs are where oxygen enters your bloodstream and carbon dioxide is removed. As inflammation decreases, this gas exchange becomes more effective.\n\n• Better sleep: Improved breathing means better sleep quality. You may notice you're sleeping more deeply and waking more refreshed.\n\nMONTH 1: SIGNIFICANT STRUCTURAL RECOVERY\n\n• Cilia are fully functional: By one month, your cilia have fully regenerated and are working at near-normal capacity. This means your lungs are much better at clearing mucus, debris, and harmful particles.\n\n• Lung capacity increases: Your lung capacity (the total amount of air your lungs can hold) begins to increase measurably. This improvement continues for months, but the first month shows significant gains.\n\n• Exercise becomes easier: With improved lung function and capacity, physical activity becomes noticeably easier. You may find you can exercise longer, at higher intensities, or with less breathlessness.\n\n• Reduced infection risk: As your lung's defense mechanisms (including cilia) recover, your risk of respiratory infections like bronchitis and pneumonia begins to decrease.\n\n• Improved stamina: Better oxygen delivery and lung function mean improved stamina for daily activities. You may notice you have more energy and can do more without getting winded.\n\nMONTHS 3-9: CONTINUED HEALING AND IMPROVEMENT\n\n• Lung function continues to improve: Spirometry tests show continued improvements in lung function. Your FEV1 and FVC continue to increase, approaching levels closer to what they would be if you had never vaped.\n\n• Infection risk decreases significantly: Your lungs are now much better equipped to defend against bacteria and viruses. If you were prone to frequent colds or respiratory infections, you'll likely notice a dramatic improvement.\n\n• Chronic inflammation resolves: The chronic inflammation caused by vaping continues to decrease. This reduces your risk of developing chronic lung diseases like chronic obstructive pulmonary disease (COPD).\n\n• Alveolar function improves: The millions of tiny air sacs in your lungs continue to heal and function more efficiently. This improves oxygen exchange and overall lung efficiency.\n\n• Exercise capacity increases: Your ability to exercise continues to improve. Many people find they can now engage in activities they couldn't do while vaping.\n\n• Reduced mucus production: As inflammation decreases and your airways heal, excessive mucus production should normalize. Your lungs produce just the right amount of mucus needed for protection and lubrication.\n\nYEAR 1: MAJOR LONG-TERM IMPROVEMENTS\n\n• Lung capacity can improve by up to 30%: Research shows that lung capacity can improve significantly in the first year after quitting. Some people see improvements of 10-30%, depending on how long they vaped and their overall health.\n\n• Chronic lung disease risk decreases: Your risk of developing chronic lung diseases like COPD, emphysema, and chronic bronchitis continues to decrease. The longer you remain vape-free, the lower your risk becomes.\n\n• Lung function approaches normal: For many people, lung function can approach or even reach levels similar to someone who never vaped, especially if they quit relatively early.\n\n• Improved quality of life: Better lung function means better quality of life. You can do more, feel better, and enjoy activities without being limited by breathing difficulties.\n\n• Reduced risk of lung cancer: While lung cancer risk takes longer to decrease significantly, the first year of healing is crucial. Your lungs are actively repairing DNA damage and removing precancerous cells.\n\nYEARS 2-5: CONTINUED HEALING\n\n• Further lung capacity improvements: Lung capacity can continue to improve for several years after quitting, though the most dramatic improvements occur in the first year.\n\n• Reduced risk of respiratory diseases: Your risk of developing serious respiratory diseases continues to decrease the longer you remain vape-free.\n\n• Improved lung elasticity: The elasticity of your lung tissue continues to improve, allowing your lungs to expand and contract more efficiently.\n\n• Better overall health: Improved lung health contributes to better overall health, including better cardiovascular health, improved immune function, and enhanced physical performance.\n\nUNDERSTANDING THE HEALING PROCESS\n\nYour lungs heal through several mechanisms:\n\n• Regeneration: Damaged cells are replaced with new, healthy cells. This process is ongoing throughout your body, but removing harmful substances allows it to proceed more effectively.\n\n• Inflammation resolution: Chronic inflammation is resolved as your body is no longer exposed to irritants. This allows tissues to heal and function normally.\n\n• Mucus clearance: Improved cilia function means better clearance of mucus, debris, and harmful particles, reducing the risk of infection and damage.\n\n• Tissue repair: Damaged lung tissue is repaired and replaced with healthy tissue over time.\n\nFACTORS THAT AFFECT HEALING\n\nSeveral factors influence how quickly and completely your lungs heal:\n\n• How long you vaped: Generally, the longer you vaped, the longer healing takes, but significant improvements are still possible.\n\n• Age: Younger people tend to heal faster, but people of all ages can see significant improvements.\n\n• Overall health: Good nutrition, regular exercise, and overall health support lung healing.\n\n• Genetics: Some people may heal faster or more completely than others due to genetic factors.\n\n• Environmental factors: Avoiding secondhand smoke, air pollution, and other lung irritants supports healing.\n\nSUPPORTING YOUR LUNG HEALING\n\nYou can support your lung healing by:\n\n• Staying hydrated: Proper hydration helps keep mucus thin and easy to clear.\n\n• Deep breathing exercises: These help expand your lungs and improve capacity.\n\n• Regular exercise: Physical activity helps improve lung function and capacity.\n\n• Avoiding irritants: Stay away from smoke, pollution, and other lung irritants.\n\n• Eating a healthy diet: Good nutrition supports tissue repair and immune function.\n\n• Getting adequate sleep: Sleep is when your body does much of its repair work.\n\nREMEMBER: PROGRESS IS CUMULATIVE\n\nEvery day without vaping is a day your lungs are healing. The improvements are cumulative—each day builds on the previous day's healing. Even if progress feels slow, your lungs are constantly working to repair and regenerate.\n\nSome days you may notice more improvement than others, and that's normal. The overall trend is toward improvement, and your lungs have remarkable regenerative abilities. Trust the process, be patient with yourself, and celebrate every milestone along the way.",
                        sources: ["American Lung Association - Lung Health Benefits Timeline", "Mayo Clinic - Lung Recovery After Quitting", "European Respiratory Journal - Lung Function Recovery After Smoking Cessation", "Chest Journal - Cilia Regeneration and Lung Health", "American Thoracic Society - Respiratory Benefits of Quitting", "Journal of Clinical Medicine - Alveolar Repair Mechanisms"]
                    ),
                    Lesson.withContent(
                        title: "Movement that supports healing",
                        summary: "Gentle routines that open your chest and calm cravings.",
                        durationMinutes: 6,
                        icon: "🚶",
                        content: "Physical activity is one of the most powerful and underutilized tools for recovery from vaping. Movement doesn't just support physical healing—it also helps manage cravings, improves mood, and builds confidence. This comprehensive guide will help you understand why movement matters and how to incorporate it into your quit journey in a way that supports your healing.\n\nWHY MOVEMENT MATTERS FOR RECOVERY\n\nMovement supports recovery in multiple, interconnected ways:\n\n• Opens your chest and improves lung capacity: Deep breathing exercises, stretching, and movement expand your rib cage and strengthen the muscles involved in breathing. This directly improves your lung capacity and makes breathing easier.\n\n• Reduces cravings naturally: Exercise releases endorphins and dopamine—the same neurotransmitters that vaping triggered, but now they're tied to healthy behaviors. This natural reward system helps reduce cravings and makes not vaping feel good.\n\n• Improves circulation and oxygen delivery: Movement increases blood flow, helping your body deliver oxygen more efficiently to all your tissues and organs. This supports healing throughout your body, not just in your lungs.\n\n• Builds confidence and self-efficacy: Each walk, stretch, or movement session reinforces your commitment to healing. You're proving to yourself that you can make positive changes, which builds confidence in your ability to quit.\n\n• Manages stress and anxiety: Physical activity is one of the most effective ways to reduce stress and anxiety, which are common triggers for vaping. Movement activates your body's relaxation response.\n\n• Improves sleep quality: Regular movement helps regulate your sleep-wake cycle and improves sleep quality. Better sleep supports healing and reduces cravings.\n\n• Accelerates healing: Movement increases blood flow to healing tissues, bringing nutrients and removing waste products more efficiently. This accelerates the healing process.\n\nTYPES OF MOVEMENT FOR RECOVERY\n\n1. WALKING: THE FOUNDATION\n\nWalking is one of the best forms of movement for recovery because it's:\n\n• Low impact and accessible\n• Easy to start and build up gradually\n• Effective at improving lung capacity\n• Great for managing cravings\n• Can be done anywhere, anytime\n\nHow to start:\n\n• Begin with 10-15 minutes of gentle walking\n• Focus on deep, slow breaths as you walk\n• Gradually increase duration as your lung capacity improves\n• Try to walk daily, even if it's just for 5 minutes\n• Use walking as a craving management tool—when a craving hits, take a 5-minute walk\n\nBenefits:\n\n• Improves cardiovascular health\n• Strengthens leg muscles and core\n• Reduces stress and anxiety\n• Improves mood\n• Supports lung healing\n\n2. GENTLE YOGA AND STRETCHING\n\nYoga and stretching are excellent for recovery because they:\n\n• Open the chest and improve posture\n• Focus on deep, controlled breathing\n• Reduce stress and promote relaxation\n• Improve flexibility and range of motion\n• Can be done at home with minimal equipment\n\nKey poses for lung health:\n\n• Chest-opening poses: These expand your rib cage and improve lung capacity. Examples include:\n  - Cobra pose\n  - Bridge pose\n  - Camel pose\n  - Doorway chest stretch\n\n• Breathing-focused poses: These help you practice deep, controlled breathing. Examples include:\n  - Child's pose with deep breathing\n  - Seated forward fold with breath awareness\n  - Corpse pose with breath meditation\n\n• Gentle twists: These help mobilize your rib cage and improve breathing mechanics.\n\nHow to start:\n\n• Start with 10-15 minutes of gentle stretching\n• Focus on chest-opening and breathing exercises\n• Use online videos or apps for guidance\n• Listen to your body and don't push too hard\n• Make it a daily practice, even if brief\n\n3. DEEP BREATHING EXERCISES\n\nWhile not traditional \"movement,\" breathing exercises are crucial for lung recovery:\n\n• Diaphragmatic breathing: This strengthens your diaphragm and improves breathing efficiency.\n\n• 4-7-8 breathing: Inhale for 4 counts, hold for 7, exhale for 8. This activates your relaxation response and can reduce cravings.\n\n• Box breathing: Inhale for 4, hold for 4, exhale for 4, hold for 4. This helps regulate your nervous system.\n\n• Pursed-lip breathing: This technique helps keep airways open longer and improves oxygen exchange.\n\n4. LIGHT STRENGTH TRAINING\n\nAs your lung capacity improves, light strength training can:\n\n• Improve overall fitness\n• Build muscle, which increases metabolism\n• Improve posture, which supports better breathing\n• Build confidence and self-efficacy\n• Provide another healthy outlet for stress\n\nHow to start:\n\n• Begin with bodyweight exercises (push-ups, squats, planks)\n• Focus on proper form over intensity\n• Start with 1-2 sets of 8-10 repetitions\n• Gradually increase as you get stronger\n• Always warm up and cool down\n\n5. SWIMMING (IF AVAILABLE)\n\nSwimming is excellent for lung health because:\n\n• It requires controlled breathing\n• It's a full-body workout\n• The water provides resistance without impact\n• It can significantly improve lung capacity\n\nHOW TO USE MOVEMENT FOR CRAVING MANAGEMENT\n\nMovement is one of the most effective tools for managing cravings:\n\n• The 5-minute walk: When a craving hits, take a 5-minute walk. Often, by the time you return, the craving has passed or significantly decreased.\n\n• Breathing exercises: If you can't walk, do 5 minutes of deep breathing exercises. This can reduce cravings and calm your nervous system.\n\n• Quick movement breaks: Set reminders to take short movement breaks throughout the day. This prevents cravings from building up.\n\n• Replace vaping routines: If you used to vape at certain times (after meals, during breaks), replace those times with movement.\n\nBUILDING A MOVEMENT ROUTINE\n\nStart small and build gradually:\n\nWeek 1-2:\n• 10-15 minutes of walking daily\n• 5-10 minutes of gentle stretching\n• Focus on consistency over intensity\n\nWeek 3-4:\n• Increase walking to 20-30 minutes\n• Add more stretching or gentle yoga\n• Try light strength training 2-3 times per week\n\nMonth 2+:\n• Continue building duration and intensity\n• Try new activities you enjoy\n• Make movement a non-negotiable part of your day\n\nLISTENING TO YOUR BODY\n\nIt's important to listen to your body and not push too hard:\n\n• Start slowly and build gradually\n• Rest when you need to\n• Don't compare yourself to others\n• Celebrate small improvements\n• Be patient with your progress\n\nRemember: Any movement is better than no movement. Even 5 minutes can make a difference.\n\nMAKING MOVEMENT SUSTAINABLE\n\nTo make movement a lasting habit:\n\n• Choose activities you enjoy\n• Make it convenient (walk in your neighborhood, do home workouts)\n• Schedule it like any other appointment\n• Find an accountability partner\n• Track your progress\n• Celebrate milestones\n• Be flexible—if you miss a day, just get back to it\n\nTHE MENTAL BENEFITS OF MOVEMENT\n\nMovement provides powerful mental benefits:\n\n• Reduces anxiety and depression\n• Improves mood and self-esteem\n• Provides a sense of accomplishment\n• Reduces stress\n• Improves sleep\n• Increases energy levels\n• Builds confidence\n\nThese mental benefits are crucial for maintaining your quit, as they help you manage the emotional challenges of recovery.\n\nREMEMBER: PROGRESS, NOT PERFECTION\n\nMovement for recovery is about progress, not perfection:\n\n• Some days you'll do more, some days less—that's okay\n• The important thing is consistency over time\n• Every movement session supports your healing\n• Every walk, stretch, or breath is a step toward better health\n• You're building a new, healthier relationship with your body\n\nMovement is a gift you give yourself. It supports your physical healing, manages your cravings, improves your mood, and builds your confidence. Start where you are, be patient with yourself, and trust that every movement session is contributing to your recovery. Your body is capable of remarkable healing, and movement is one of the best ways to support that process.",
                        sources: ["Centers for Disease Control and Prevention - Physical Activity Guidelines", "Journal of Addiction Medicine - Exercise and Smoking Cessation", "American College of Sports Medicine - Exercise and Recovery", "Journal of Applied Physiology - Exercise and Lung Function", "Mayo Clinic - Exercise and Mental Health", "Yoga Journal - Breathing Exercises for Lung Health"]
                    )
                ]
            ),
            LearningTopic(
                kind: .mental,
                title: "Mental resilience",
                blurb: "Build calm habits and mindset shifts for the long term.",
                accent: primaryAccentColor,
                lessons: [
                    Lesson.withContent(
                        title: "Urge surfing",
                        summary: "Ride cravings with mindful breathing in under two minutes.",
                        durationMinutes: 6,
                        icon: "💨",
                        content: "Urge surfing is a powerful mindfulness technique that transforms how you relate to cravings. Instead of fighting urges or feeling overwhelmed by them, you learn to observe them with curiosity and ride them like a wave. This technique is based on the understanding that cravings are temporary experiences that rise, peak, and fall—and you don't have to act on them. This comprehensive guide will teach you how to master this skill and use it whenever cravings arise.\n\nUNDERSTANDING CRAVINGS: THE SCIENCE BEHIND THE WAVE\n\nCravings are not permanent states—they're temporary experiences with a predictable pattern:\n\n• Cravings typically peak within 3-5 minutes\n• They then begin to subside naturally\n• Most cravings are gone within 10-15 minutes\n• They're triggered by thoughts, emotions, situations, or physical sensations\n• They feel urgent, but they're not emergencies\n\nUnderstanding this pattern is crucial because it helps you realize that you don't have to act on every craving. You can wait them out, and they will pass.\n\nTHE URGENCY ILLUSION\n\nCravings create a sense of urgency—they make you feel like you need to vape right now. But this urgency is an illusion created by your brain's reward system. The craving itself is not dangerous, and acting on it is not necessary. Urge surfing helps you see through this illusion and realize you have a choice.\n\nTHE FIVE STEPS OF URGE SURFING\n\n1. NOTICE THE CRAVING: ACKNOWLEDGE WITHOUT JUDGMENT\n\nThe first step is simply to notice that a craving is present. This might seem simple, but it's actually a powerful act of awareness.\n\nWhat to do:\n\n• Say to yourself: 'I'm having a craving right now.'\n• Acknowledge it without judgment—don't label it as good or bad\n• Don't try to push it away or ignore it\n• Simply notice: 'A craving is here.'\n\nWhy this works:\n\n• Awareness creates space between the craving and your response\n• Non-judgmental awareness reduces the emotional charge\n• Simply noticing interrupts the automatic reaction\n• It gives you a moment to choose how to respond\n\nCommon mistakes:\n\n• Trying to ignore or suppress the craving\n• Judging yourself for having the craving\n• Immediately trying to distract yourself\n• Panicking about the craving\n\n2. OBSERVE IT: EXPLORE WITH CURIOSITY\n\nOnce you've noticed the craving, observe it with curiosity. This is where you become a scientist studying your own experience.\n\nWhat to observe:\n\n• Where do you feel it in your body? (chest, throat, hands, stomach)\n• What does it feel like? (tightness, restlessness, emptiness, tension)\n• What thoughts come with it? ('I need to vape,' 'Just one won't hurt,' 'I can't handle this')\n• What emotions are present? (anxiety, boredom, stress, sadness)\n• How intense is it on a scale of 1-10?\n• Does it feel like it's getting stronger or weaker?\n\nWhy this works:\n\n• Observation creates distance from the craving\n• Curiosity replaces fear and urgency\n• Understanding the craving reduces its power\n• You realize it's just a collection of sensations and thoughts\n\nPractice questions:\n\n• 'What does this craving actually feel like?'\n• 'Where in my body do I feel it most strongly?'\n• 'What story is my mind telling me about this craving?'\n• 'Is this craving getting stronger or weaker?'\n\n3. BREATHE THROUGH IT: ANCHOR IN THE PRESENT MOMENT\n\nBreathing is your anchor during urge surfing. It keeps you grounded in the present moment and helps regulate your nervous system.\n\nThe 4-7-8 breathing technique:\n\n• Inhale through your nose for 4 counts\n• Hold your breath for 7 counts\n• Exhale through your mouth for 8 counts\n• Repeat 4-8 times\n\nWhy this works:\n\n• Deep breathing activates your parasympathetic nervous system (relaxation response)\n• It reduces the physical intensity of the craving\n• It gives you something to focus on besides the craving\n• It regulates your heart rate and blood pressure\n• It creates a sense of calm and control\n\nOther breathing techniques:\n\n• Box breathing: Inhale 4, hold 4, exhale 4, hold 4\n• Equal breathing: Inhale and exhale for the same count (e.g., 4-4)\n• Belly breathing: Focus on breathing into your belly, expanding it on the inhale\n\n4. REMEMBER IT PASSES: TRUST THE PROCESS\n\nThis is a crucial step—remembering that cravings are temporary. This knowledge gives you confidence to wait them out.\n\nWhat to remember:\n\n• Cravings peak within 3-5 minutes\n• They naturally subside if you don't act on them\n• You've survived cravings before\n• This one will pass too\n• Each craving you surf makes the next one easier\n\nAffirmations to use:\n\n• 'This craving will pass, just like all the others.'\n• 'I don't have to act on this.'\n• 'I can handle this moment.'\n• 'This is temporary.'\n• 'I've done this before, I can do it again.'\n\nWhy this works:\n\n• Reminding yourself that it will pass reduces panic\n• It gives you hope and confidence\n• It helps you see the bigger picture\n• It connects you to your past successes\n\n5. RIDE THE WAVE: WATCH IT RISE, PEAK, AND FALL\n\nThis is the core of urge surfing—watching the craving like you would watch a wave in the ocean. You don't try to stop it or control it; you just observe it.\n\nWhat to do:\n\n• Imagine the craving as a wave\n• Watch it build and rise\n• Notice when it peaks\n• Observe it as it begins to fall\n• Stay present throughout the entire process\n• Don't try to make it go away faster\n• Just ride it out\n\nVisualization:\n\n• Picture yourself on a surfboard\n• The craving is a wave coming toward you\n• You're balanced and stable\n• You ride the wave as it rises\n• You stay balanced as it peaks\n• You ride it down as it falls\n• You remain standing on your board\n\nWhy this works:\n\n• It changes your relationship with cravings from fight to observation\n• It reduces resistance, which often makes cravings stronger\n• It teaches you that you can experience cravings without acting on them\n• It builds confidence in your ability to handle difficult moments\n• It reduces the fear of cravings\n\nCOMMON CHALLENGES AND HOW TO HANDLE THEM\n\nChallenge: 'The craving feels too strong.'\n\nResponse: Remind yourself that cravings always feel strong in the moment, but they peak and pass. Use your breathing to manage the intensity. Remember that you've handled strong cravings before.\n\nChallenge: 'I can't stop thinking about vaping.'\n\nResponse: Don't try to stop the thoughts. Instead, observe them like clouds passing in the sky. Notice them, label them ('thinking about vaping'), and let them pass. Thoughts are not commands.\n\nChallenge: 'What if this craving never goes away?'\n\nResponse: This is a common fear, but it's not based in reality. Cravings always pass. Set a timer for 10 minutes and commit to not acting during that time. Usually, the craving will have passed by then.\n\nChallenge: 'I've tried this before and it didn't work.'\n\nResponse: Urge surfing is a skill that improves with practice. Each time you try, you're building the skill. Be patient with yourself and keep practicing.\n\nBUILDING YOUR URGE SURFING SKILLS\n\nLike any skill, urge surfing improves with practice:\n\n• Practice during mild cravings first\n• Gradually work up to stronger cravings\n• Practice even when you don't have cravings (mental rehearsal)\n• Keep a journal of your urge surfing experiences\n• Celebrate each time you successfully surf an urge\n• Learn from times when it was challenging\n\nTHE REWIRING EFFECT\n\nEach time you successfully surf an urge, you're rewiring your brain:\n\n• You're breaking the automatic connection between craving and action\n• You're creating new neural pathways\n• You're teaching your brain that cravings don't require action\n• You're building confidence and self-efficacy\n• The craving loses its power over time\n\nThis rewiring is cumulative—each successful urge surf makes the next one easier. Over time, cravings become less intense, less frequent, and less compelling.\n\nINTEGRATING URGE SURFING INTO YOUR DAILY LIFE\n\nUrge surfing isn't just for cravings—it's a skill you can use for any difficult emotion or urge:\n\n• Use it for stress and anxiety\n• Apply it to anger or frustration\n• Use it for boredom or restlessness\n• Apply it to any urge to engage in unhealthy behaviors\n\nThis makes urge surfing a valuable life skill that extends far beyond quitting vaping.\n\nREMEMBER: YOU ARE NOT YOUR CRAVINGS\n\nA crucial understanding: cravings are experiences you have, not who you are. You can have a craving without being defined by it. Urge surfing helps you see this distinction clearly.\n\nYou are:\n\n• The one who observes the craving\n• The one who chooses how to respond\n• The one who rides the wave\n• The one who remains stable\n\nYou are not:\n\n• The craving itself\n• Powerless against it\n• Defined by it\n• Required to act on it\n\nThis understanding is liberating. It gives you agency and choice. You're not a victim of your cravings—you're someone who can observe and navigate them skillfully.\n\nUrge surfing is a powerful tool that transforms your relationship with cravings. It's not about fighting or resisting—it's about observing, understanding, and riding the wave. With practice, it becomes a natural response to cravings, and each successful urge surf builds your confidence and strengthens your quit. Remember: you can do this. You have the capacity to observe and navigate cravings without acting on them. Trust the process, trust yourself, and keep practicing.",
                        sources: ["Mindfulness-Based Relapse Prevention - Urge Surfing Technique", "Journal of Substance Abuse Treatment - Mindfulness and Addiction", "Addiction Research & Theory - Urge Management Strategies", "Journal of Consulting and Clinical Psychology - Mindfulness-Based Interventions", "Harvard Medical School - Mindfulness and Stress Reduction", "American Psychological Association - Coping with Cravings"]
                    ),
                    Lesson.withContent(
                        title: "Rewrite the story",
                        summary: "Reframe slips with compassionate language and intention.",
                        durationMinutes: 9,
                        icon: "💬",
                        content: "If you slip, the story you tell yourself about that slip matters more than the slip itself. The narrative you create determines whether you get back on track or give up entirely. Harsh self-criticism can be devastating and often leads to continued vaping, while compassionate reframing can turn a slip into a valuable learning opportunity. This comprehensive guide will teach you how to rewrite your story with compassion, wisdom, and resilience.\n\nUNDERSTANDING THE POWER OF YOUR STORY\n\nYour internal narrative—the story you tell yourself about your experiences—shapes your reality:\n\n• It influences how you feel about yourself\n• It affects your motivation and confidence\n• It determines your next actions\n• It can either support or undermine your recovery\n\nWhen you slip, you have a choice about what story you tell. You can choose a story that supports your recovery or one that undermines it.\n\nTHE HARSH STORY: THE PATH TO GIVING UP\n\nMany people tell themselves harsh stories after a slip:\n\n• 'I failed. I'm a failure.'\n• 'I'm weak. I have no willpower.'\n• 'I'll never be able to quit.'\n• 'I've ruined everything.'\n• 'I'm hopeless.'\n• 'Everyone else can do it, but I can't.'\n\nWhy this is harmful:\n\n• It creates shame and self-loathing\n• It reduces motivation to try again\n• It becomes a self-fulfilling prophecy\n• It leads to all-or-nothing thinking ('I've already messed up, so I might as well keep going')\n• It erases all the progress you've made\n• It makes you feel powerless\n\nThis harsh story often leads to continued vaping because it makes you feel like there's no point in trying again.\n\nTHE COMPASSIONATE STORY: THE PATH TO RECOVERY\n\nInstead, you can choose a compassionate, growth-oriented story:\n\n• 'I had a slip. This is a learning opportunity.'\n• 'I'm human, and humans make mistakes.'\n• 'I can get back on track right now.'\n• 'This doesn't erase my progress.'\n• 'I'm learning what works and what doesn't.'\n• 'I have the strength to try again.'\n\nWhy this is helpful:\n\n• It maintains your self-worth and dignity\n• It keeps you motivated to continue\n• It frames the slip as information, not failure\n• It helps you learn from the experience\n• It makes it easier to recommit\n• It preserves your progress\n• It empowers you to make different choices\n\nKEY REFRAMING PRINCIPLES\n\n1. SLIPS ARE DATA, NOT DESTINY\n\nEvery slip provides valuable information:\n\n• What triggered it? (stress, social situation, emotion, time of day, location)\n• What were you thinking before it happened?\n• What were you feeling?\n• What was happening in your environment?\n• What coping strategies did you try (if any)?\n• What could you do differently next time?\n\nThis information is gold. It helps you:\n\n• Understand your patterns and triggers\n• Develop better coping strategies\n• Prepare for similar situations\n• Make more informed choices\n• Strengthen your quit plan\n\nInstead of seeing a slip as proof you can't quit, see it as data about what you need to work on.\n\n2. PROGRESS ISN'T LINEAR\n\nRecovery is not a straight line from vaping to not vaping. It's more like a spiral or a journey with ups and downs:\n\n• You'll have good days and challenging days\n• You'll have moments of strength and moments of struggle\n• You'll make progress and sometimes take steps back\n• This is normal and expected\n\nUnderstanding this helps you:\n\n• Not catastrophize when you have a difficult moment\n• See the bigger picture of your progress\n• Maintain hope during challenging times\n• Recognize that setbacks are part of the process\n• Keep going even when it's hard\n\nOne slip doesn't erase:\n\n• All the days you were vape-free\n• All the progress you've made\n• All the skills you've learned\n• All the healing your body has done\n• All the confidence you've built\n\n3. SELF-COMPASSION BUILDS RESILIENCE\n\nSelf-compassion is treating yourself with the same kindness, understanding, and support you would offer a good friend who was struggling.\n\nThe three components of self-compassion:\n\n• Self-kindness: Being warm and understanding toward yourself rather than harshly critical\n• Common humanity: Recognizing that suffering and imperfection are part of the shared human experience\n• Mindfulness: Holding your experience in balanced awareness, neither ignoring nor over-identifying with it\n\nWhy self-compassion matters:\n\n• Research shows it's more effective than self-criticism for behavior change\n• It reduces shame and self-loathing\n• It increases motivation to try again\n• It builds resilience and emotional strength\n• It makes it easier to learn from mistakes\n• It supports long-term recovery\n\nHow to practice self-compassion after a slip:\n\n• Acknowledge your pain: 'This is really hard right now.'\n• Recognize common humanity: 'Many people struggle with this. I'm not alone.'\n• Offer yourself kindness: 'I'm doing my best. This is a learning process.'\n• Focus on growth: 'What can I learn from this?'\n\n4. FOCUS ON WHAT YOU LEARNED\n\nAfter a slip, shift your focus from what went wrong to what you can learn:\n\nQuestions to ask yourself:\n\n• What triggered this slip?\n• What was I thinking and feeling?\n• What coping strategies did I try?\n• What worked, even briefly?\n• What didn't work?\n• What will I do differently next time?\n• What support do I need?\n• What can I learn from this experience?\n\nThis learning-focused approach:\n\n• Transforms the slip from failure to information\n• Helps you prepare for future challenges\n• Builds your skills and knowledge\n• Increases your confidence\n• Makes you feel empowered rather than defeated\n\nTHE REFRAMING PROCESS: STEP BY STEP\n\nWhen you slip, follow this process:\n\nStep 1: Pause and breathe\n\n• Don't immediately start telling yourself a harsh story\n• Take a few deep breaths\n• Give yourself a moment to process what happened\n\nStep 2: Acknowledge what happened\n\n• 'I had a slip. That happened.'\n• Acknowledge it without judgment\n• Don't try to minimize it or make it bigger than it is\n\nStep 3: Practice self-compassion\n\n• 'This is hard, and I'm doing my best.'\n• 'Many people experience slips. I'm not alone.'\n• 'I'm human, and humans make mistakes.'\n\nStep 4: Reframe the story\n\n• Instead of: 'I failed. I'm weak.'\n• Try: 'I had a slip. This is a learning opportunity.'\n\nStep 5: Extract the learning\n\n• What triggered it?\n• What can I learn from this?\n• What will I do differently?\n\nStep 6: Recommit immediately\n\n• Don't wait until tomorrow or next week\n• Recommit to quitting right now\n• The longer you wait, the harder it becomes\n\nStep 7: Take action\n\n• Implement what you learned\n• Reach out for support if needed\n• Use your coping strategies\n• Get back on track\n\nCOMMON REFRAMING EXAMPLES\n\nInstead of: 'I failed. I'm a failure.'\nTry: 'I had a slip. This doesn't define me. I can learn from this and continue.'\n\nInstead of: 'I'm weak. I have no willpower.'\nTry: 'This is challenging, and I'm learning. Willpower is a skill I can develop.'\n\nInstead of: 'I'll never be able to quit.'\nTry: 'This attempt taught me valuable lessons. I can use this knowledge in my next attempt.'\n\nInstead of: 'I've ruined everything.'\nTry: 'I had a slip, but my progress isn't lost. I can get back on track.'\n\nInstead of: 'Everyone else can do it, but I can't.'\nTry: 'Everyone's journey is different. I'm on my own path, and I'm learning what works for me.'\n\nInstead of: 'I've already messed up, so I might as well keep going.'\nTry: 'One slip doesn't mean I should give up. I can recommit right now.'\n\nTHE STORY OF SUCCESSFUL QUITTERS\n\nResearch shows that people who successfully quit often have multiple attempts:\n\n• The average person tries to quit 5-7 times before succeeding\n• Each attempt teaches valuable lessons\n• Most successful quitters view previous attempts as learning experiences, not failures\n• They use what they learned to make the next attempt stronger\n\nYour story isn't over—it's being rewritten with each choice you make. Every attempt, every slip, every moment of recommitment is part of your story. You get to choose what that story means.\n\nBUILDING A GROWTH MINDSET\n\nA growth mindset is the belief that you can develop and improve through effort and learning. This is crucial for recovery:\n\nFixed mindset: 'I can't quit. I'm just not strong enough.'\nGrowth mindset: 'Quitting is challenging, and I'm learning how to do it. Each attempt makes me stronger.'\n\nHow to cultivate a growth mindset:\n\n• View challenges as opportunities to learn\n• See effort as the path to mastery\n• Learn from criticism and setbacks\n• Find inspiration in others' success\n• Embrace the process, not just the outcome\n\nPRACTICING COMPASSIONATE SELF-TALK\n\nYour self-talk—the way you talk to yourself—has a powerful impact. Practice compassionate self-talk:\n\n• Use your name: 'Felipe, you're doing your best. This is hard, and that's okay.'\n• Speak like a friend: 'I know this is difficult. You're not alone in this.'\n• Acknowledge effort: 'You've been working really hard. That matters.'\n• Offer encouragement: 'You can do this. You have the strength to try again.'\n\nREMEMBER: YOUR STORY IS YOURS TO WRITE\n\nYou have the power to rewrite your story at any moment:\n\n• You can choose compassion over criticism\n• You can choose learning over judgment\n• You can choose growth over stagnation\n• You can choose hope over despair\n• You can choose to continue over giving up\n\nEvery moment is a new opportunity to write a different story. A slip doesn't have to be the end of your story—it can be a turning point, a learning moment, a chance to grow stronger.\n\nYour story is still being written. Make it a story of resilience, learning, growth, and ultimately, success. You have the power to rewrite it with each choice you make. Choose compassion. Choose learning. Choose to continue. Your future self will thank you.",
                        sources: ["Self-Compassion Research - Kristin Neff", "Addiction Research & Theory - Self-Compassion and Recovery", "Journal of Clinical Psychology - Self-Compassion and Behavior Change", "American Psychological Association - Growth Mindset Research", "Harvard Business Review - The Power of Reframing", "Journal of Personality and Social Psychology - Self-Compassion and Resilience"]
                    ),
                    Lesson.withContent(
                        title: "Micro-celebrations",
                        summary: "Celebrate tiny wins to anchor motivation each day.",
                        durationMinutes: 6,
                        icon: "✨",
                        content: "Micro-celebrations are small, intentional acknowledgments of your progress that create powerful positive reinforcement loops. When you celebrate your wins—no matter how small—your brain releases dopamine, the same reward chemical that vaping triggered, but now it's tied to healthy behaviors. This rewires your reward system and makes not vaping feel rewarding. This comprehensive guide will teach you how to use micro-celebrations to build and maintain motivation throughout your quit journey.\n\nTHE SCIENCE OF CELEBRATION: WHY IT MATTERS\n\nCelebrating small wins is not just feel-good advice—it's backed by neuroscience:\n\n• Dopamine release: When you acknowledge and celebrate progress, your brain releases dopamine, creating positive associations with not vaping\n• Reward pathway rewiring: Over time, your brain learns that not vaping feels good, too\n• Motivation maintenance: Regular celebrations help maintain motivation during challenging times\n• Confidence building: Each celebration proves you're capable of change\n• Momentum creation: Small wins build momentum toward bigger achievements\n\nUnderstanding this science helps you see micro-celebrations as essential tools, not optional extras.\n\nWHAT TO CELEBRATE: THE SMALL WINS THAT MATTER\n\nEvery moment of progress deserves recognition. Here's what to celebrate:\n\nTIME-BASED MILESTONES:\n\n• One hour vape-free\n• One morning without vaping\n• One afternoon without vaping\n• One evening without vaping\n• One full day vape-free\n• One week vape-free\n• One month vape-free\n• Any time period that's meaningful to you\n\nCRAVING MANAGEMENT WINS:\n\n• Noticing a craving without acting on it\n• Using a coping strategy when a craving hit\n• Successfully surfing an urge\n• Choosing a healthy alternative to vaping\n• Getting through a challenging moment without vaping\n• Handling a trigger without vaping\n\nBEHAVIORAL WINS:\n\n• Waking up without vaping\n• Going to bed vape-free\n• Choosing water over vaping\n• Taking a walk when you felt an urge\n• Doing a breathing exercise during a craving\n• Reaching out for support instead of vaping\n• Saying no in a social situation\n• Removing vaping devices from your environment\n\nEMOTIONAL WINS:\n\n• Managing stress without vaping\n• Handling anxiety without vaping\n• Processing difficult emotions without vaping\n• Celebrating a success without vaping\n• Coping with boredom without vaping\n\nPHYSICAL WINS:\n\n• Noticing improved breathing\n• Feeling more energy\n• Sleeping better\n• Noticing improved sense of taste or smell\n• Feeling healthier overall\n\nMENTAL WINS:\n\n• Feeling more confident\n• Noticing improved mental clarity\n• Feeling proud of your progress\n• Feeling more in control\n• Having a positive thought about your quit\n\nRemember: No win is too small to celebrate. Every moment of progress matters.\n\nHOW TO CELEBRATE: PRACTICAL STRATEGIES\n\n1. ACKNOWLEDGE IT OUT LOUD\n\nVerbal acknowledgment is powerful:\n\n• 'I did it!'\n• 'I got through that craving!'\n• 'I'm one hour vape-free!'\n• 'I chose health over vaping!'\n• 'I'm proud of myself!'\n• 'I'm stronger than I thought!'\n\nWhy this works:\n\n• It makes the win real and concrete\n• It reinforces the positive behavior\n• It creates a positive memory\n• It builds confidence\n\n2. SHARE WITH SOMEONE SUPPORTIVE\n\nSharing your wins multiplies the celebration:\n\n• Tell a friend or family member\n• Post in a support group\n• Share with your accountability partner\n• Text someone who's supporting you\n\nWhy this works:\n\n• It creates external validation\n• It strengthens your support network\n• It inspires others\n• It makes the win feel more significant\n\n3. DO SOMETHING YOU ENJOY\n\nReward yourself with activities you love:\n\n• Read a chapter of a book\n• Listen to your favorite music\n• Watch an episode of a show you enjoy\n• Call a friend\n• Take a relaxing bath\n• Do a hobby you love\n• Have a special treat (healthy if possible)\n• Spend time in nature\n\nWhy this works:\n\n• It creates positive associations with not vaping\n• It gives you something to look forward to\n• It makes the reward immediate and tangible\n• It reinforces the behavior\n\n4. TRACK IT VISUALLY\n\nVisual tracking makes progress tangible:\n\n• Mark it in your app\n• Put a checkmark on a calendar\n• Add a sticker to a chart\n• Write it in a journal\n• Take a photo or screenshot\n\nWhy this works:\n\n• It creates a visual record of progress\n• It's satisfying to see progress accumulate\n• It provides motivation during challenging times\n• It proves you're making progress\n\n5. GIVE YOURSELF A MENTAL HIGH-FIVE\n\nInternal acknowledgment matters too:\n\n• Take a moment to feel proud\n• Recognize your strength\n• Acknowledge your effort\n• Give yourself credit\n• Feel the satisfaction\n\nWhy this works:\n\n• It builds self-esteem\n• It creates positive self-talk\n• It reinforces your capability\n• It builds confidence\n\n6. CREATE A CELEBRATION RITUAL\n\nDevelop your own celebration ritual:\n\n• Do a little dance\n• Pump your fist\n• Smile and say 'Yes!'\n• Take a deep breath and feel proud\n• Do a victory pose\n• Write it down in a 'wins' journal\n\nWhy this works:\n\n• Rituals make celebrations more meaningful\n• They create positive associations\n• They make the moment memorable\n• They're fun and energizing\n\nBUILDING A CELEBRATION HABIT\n\nTo make micro-celebrations a habit:\n\n• Set reminders to celebrate\n• Make it part of your daily routine\n• Celebrate immediately after a win\n• Don't wait for 'big' wins—celebrate small ones too\n• Be consistent\n• Make it fun and enjoyable\n\nTHE ACCUMULATION EFFECT\n\nMicro-celebrations have a powerful accumulation effect:\n\n• Each small celebration builds on the previous one\n• Over time, they create a positive momentum\n• They prove you're capable of change\n• They build confidence and self-efficacy\n• They create a positive narrative about your quit\n• They make the journey enjoyable, not just difficult\n\nRemember: Small wins accumulate into significant progress. Each celebration is a building block.\n\nCELEBRATING DURING CHALLENGING TIMES\n\nIt's especially important to celebrate during difficult times:\n\n• Celebrating small wins during challenges maintains motivation\n• It reminds you of your progress\n• It proves you can handle difficulties\n• It shifts your focus from what's hard to what's working\n• It builds resilience\n\nEven if you're struggling, find something to celebrate:\n\n• 'I'm still trying, and that matters.'\n• 'I got through today, even though it was hard.'\n• 'I used a coping strategy, even if it didn't work perfectly.'\n• 'I'm learning, and that's progress.'\n\nAVOIDING COMMON PITFALLS\n\nPitfall: 'I'll celebrate when I reach a big milestone.'\n\nResponse: Don't wait. Celebrate small wins along the way. Big milestones are made of many small wins.\n\nPitfall: 'This win is too small to celebrate.'\n\nResponse: No win is too small. Every moment of progress matters and deserves recognition.\n\nPitfall: 'I don't deserve to celebrate yet.'\n\nResponse: You deserve to celebrate every moment of progress. Celebration is not a reward for perfection—it's recognition of effort and progress.\n\nPitfall: 'Celebrating feels silly or self-indulgent.'\n\nResponse: Celebration is a powerful tool for behavior change. It's not silly—it's science-based and effective.\n\nINTEGRATING CELEBRATIONS INTO YOUR QUIT PLAN\n\nMake celebrations part of your quit strategy:\n\n• Plan how you'll celebrate different milestones\n• Set up systems to track and celebrate wins\n• Share your celebration plan with your support network\n• Make celebrations immediate and consistent\n• Adjust your celebration strategies as you learn what works\n\nTHE LONG-TERM IMPACT\n\nMicro-celebrations have lasting effects:\n\n• They rewire your reward system\n• They build lasting motivation\n• They create positive associations with not vaping\n• They build confidence and self-efficacy\n• They make the journey enjoyable\n• They support long-term success\n\nYour brain learns that not vaping feels good, too. This is crucial for long-term success.\n\nREMEMBER: CELEBRATION IS A SKILL\n\nCelebrating progress is a skill you can develop:\n\n• Start small and build the habit\n• Experiment with different celebration methods\n• Find what feels authentic and meaningful to you\n• Be consistent\n• Don't give up if it feels awkward at first\n• Keep practicing\n\nOver time, celebration becomes natural and automatic. You'll find yourself automatically acknowledging and celebrating your wins.\n\nMicro-celebrations are powerful tools that transform your quit journey from a struggle to a series of victories. Each small win proves you're capable of change. Each celebration reinforces your progress. Each moment of acknowledgment builds your confidence. Over time, these micro-celebrations accumulate into significant progress and lasting change. Start celebrating your wins today—no matter how small. Your brain, your motivation, and your future self will thank you.",
                        sources: ["Behavioral Neuroscience - Reward Pathways and Motivation", "Positive Psychology Research - Celebrating Small Wins", "Journal of Applied Psychology - The Progress Principle", "Harvard Business Review - The Power of Small Wins", "American Psychological Association - Motivation and Goal Achievement", "Neuroscience Research - Dopamine and Behavior Change"]
                    )
                ]
            ),
            LearningTopic(
                kind: .lifestyle,
                title: "Lifestyle & triggers",
                blurb: "Swap routines and prepare for the moments that matter.",
                accent: primaryAccentColor,
                lessons: [
                    Lesson.withContent(
                        title: "Morning rituals",
                        summary: "Start the day grounded to reduce cravings later on.",
                        durationMinutes: 6,
                        icon: "🌅",
                        content: "Your morning routine sets the tone for your entire day. The first hour after waking is crucial—it shapes your mindset, energy levels, and resilience for everything that follows. Replacing vaping with grounding, intentional morning rituals can significantly reduce cravings throughout the day and create a foundation of calm and control. This comprehensive guide will help you design morning rituals that support your quit journey and set you up for success.\n\nWHY MORNING RITUALS MATTER\n\nMorning rituals are powerful because:\n\n• They set your intention for the day\n• They activate your parasympathetic nervous system (relaxation response)\n• They create positive neural pathways\n• They reduce stress and anxiety before they build up\n• They give you a sense of control and agency\n• They replace the automatic morning vaping routine\n• They build momentum for the rest of the day\n\nUnderstanding why they matter helps you prioritize them, even when you're busy or tired.\n\nTHE SCIENCE BEHIND MORNING RITUALS\n\nMorning rituals work through several mechanisms:\n\n• Neural pathway formation: Repeating a behavior creates and strengthens neural pathways. When you replace morning vaping with healthy rituals, you're literally rewiring your brain.\n\n• Stress reduction: Intentional morning practices activate your parasympathetic nervous system, reducing cortisol (stress hormone) and setting a calmer baseline for the day.\n\n• Habit replacement: Morning rituals replace the automatic vaping habit with new, healthier automatic behaviors.\n\n• Mindset setting: How you start your day influences how you experience the rest of it. Positive morning rituals create a positive mindset.\n\n• Energy management: Proper morning routines help regulate your energy levels, reducing the need for stimulants like nicotine.\n\nEFFECTIVE MORNING RITUAL COMPONENTS\n\n1. DEEP BREATHING: ACTIVATE YOUR RELAXATION RESPONSE\n\nDeep breathing is one of the most powerful morning practices:\n\n• 5-10 minutes of intentional breathing activates your parasympathetic nervous system\n• It reduces stress and anxiety before they accumulate\n• It improves oxygen delivery throughout your body\n• It creates a sense of calm and centeredness\n• It sets a relaxed tone for the day\n\nHow to practice:\n\n• Find a comfortable position (sitting or lying down)\n• Close your eyes or soften your gaze\n• Inhale deeply through your nose for 4 counts\n• Hold for 4 counts\n• Exhale slowly through your mouth for 6-8 counts\n• Repeat for 5-10 minutes\n• Focus on the breath, letting thoughts come and go\n\nVariations:\n\n• 4-7-8 breathing: Inhale 4, hold 7, exhale 8\n• Box breathing: Inhale 4, hold 4, exhale 4, hold 4\n• Belly breathing: Focus on expanding your belly on the inhale\n\n2. HYDRATION: FUEL YOUR BODY\n\nStarting your day with hydration is crucial:\n\n• Dehydration can mimic cravings and fatigue\n• Proper hydration supports all bodily functions\n• It helps clear toxins from your system\n• It improves energy levels\n• It supports cognitive function\n\nHow to practice:\n\n• Keep a glass of water by your bed\n• Drink a large glass (16-20 oz) upon waking\n• Add lemon for extra benefits (vitamin C, digestion)\n• Continue hydrating throughout the morning\n• Aim for half your body weight in ounces daily\n\nBenefits:\n\n• Reduces false hunger and cravings\n• Improves energy and alertness\n• Supports healing and recovery\n• Improves skin health\n• Enhances physical performance\n\n3. MOVEMENT: SIGNAL HEALTH TO YOUR BODY\n\nEven brief morning movement is powerful:\n\n• 5-10 minutes of gentle movement signals to your body that you're choosing health\n• It improves circulation and oxygen delivery\n• It releases endorphins naturally\n• It reduces stress and anxiety\n• It builds confidence and self-efficacy\n\nOptions:\n\n• Gentle stretching or yoga\n• A short walk (even around your home)\n• Light calisthenics (push-ups, squats, planks)\n• Dancing to one song\n• Tai chi or qigong\n\nHow to start:\n\n• Begin with just 5 minutes\n• Choose something you enjoy\n• Make it easy to do (no special equipment needed)\n• Focus on how it feels, not how it looks\n• Gradually increase duration as it becomes a habit\n\n4. GRATITUDE: SHIFT FROM LACK TO ABUNDANCE\n\nGratitude practice shifts your mindset:\n\n• It moves you from focusing on what you lack to what you have\n• It reduces stress and anxiety\n• It improves mood and well-being\n• It creates positive neural pathways\n• It builds resilience\n\nHow to practice:\n\n• Write down 3 things you're grateful for each morning\n• They can be big or small\n• Be specific (not just 'family,' but 'my sister's phone call yesterday')\n• Feel the gratitude, don't just list it\n• You can also think them if you prefer\n\nExamples:\n\n• 'I'm grateful for a good night's sleep.'\n• 'I'm grateful for my body's ability to heal.'\n• 'I'm grateful for the support of my friends.'\n• 'I'm grateful for this moment of peace.'\n• 'I'm grateful for another day to work on my health.'\n\n5. INTENTION SETTING: CLARIFY YOUR DAY\n\nSetting intentions gives your day direction:\n\n• It clarifies your priorities\n• It reduces decision fatigue\n• It helps you stay focused\n• It creates a sense of purpose\n• It reduces anxiety about the day ahead\n\nHow to practice:\n\n• Ask yourself: 'How do I want to feel today?'\n• Ask: 'What's most important today?'\n• Set 1-3 intentions for the day\n• Write them down or say them out loud\n• Keep them simple and achievable\n\nExamples:\n\n• 'Today I intend to be patient with myself.'\n• 'Today I intend to choose health over cravings.'\n• 'Today I intend to be present and mindful.'\n• 'Today I intend to celebrate my progress.'\n\n6. DAY PLANNING: REDUCE ANXIETY\n\nPlanning your day reduces stress:\n\n• Knowing your schedule reduces anxiety\n• Having strategies for challenging moments builds confidence\n• It helps you anticipate and prepare for triggers\n• It creates a sense of control\n• It reduces decision fatigue\n\nHow to practice:\n\n• Review your schedule for the day\n• Identify potential challenging moments or triggers\n• Plan coping strategies for those moments\n• Set realistic expectations\n• Build in breaks and self-care\n\n7. MINDFULNESS OR MEDITATION: CULTIVATE AWARENESS\n\nMorning mindfulness sets a mindful tone:\n\n• It improves present-moment awareness\n• It reduces stress and anxiety\n• It enhances emotional regulation\n• It improves focus and attention\n• It builds resilience\n\nHow to practice:\n\n• Start with just 5 minutes\n• Use a guided meditation app if helpful\n• Focus on your breath or body sensations\n• When your mind wanders, gently return to your focus\n• Be patient and non-judgmental\n\nBUILDING YOUR PERSONAL MORNING RITUAL\n\nYour morning ritual should be personal and sustainable:\n\n• Choose components that resonate with you\n• Start small—you don't need to do everything\n• Make it realistic for your schedule\n• Adjust as you learn what works\n• Be flexible—some days you'll do more, some days less\n\nSample morning ritual (15-20 minutes):\n\n1. Wake up and drink a glass of water (2 minutes)\n2. Deep breathing or meditation (5-10 minutes)\n3. Gentle movement or stretching (5 minutes)\n4. Gratitude practice (2 minutes)\n5. Intention setting and day planning (3-5 minutes)\n\nYou can adapt this to fit your needs and schedule.\n\nMAKING IT STICK: HABIT FORMATION TIPS\n\nTo make morning rituals a lasting habit:\n\n• Start small: Begin with just one component, then add more\n• Be consistent: Do it at the same time every day\n• Make it easy: Remove barriers (lay out clothes, prepare water the night before)\n• Stack habits: Attach your ritual to an existing habit (after brushing teeth)\n• Track it: Mark it on a calendar or in an app\n• Be flexible: Some days you'll do less, and that's okay\n• Celebrate: Acknowledge when you complete your ritual\n\nOVERCOMING COMMON CHALLENGES\n\nChallenge: 'I don't have time.'\n\nResponse: Start with just 5 minutes. You can do a lot in 5 minutes. As it becomes a habit, you'll find you make time for it because it makes your day better.\n\nChallenge: 'I'm not a morning person.'\n\nResponse: You don't have to be a morning person to benefit. Start with something simple like drinking water and taking 3 deep breaths. Even small rituals make a difference.\n\nChallenge: 'I forget to do it.'\n\nResponse: Set a reminder, put a note by your bed, or attach it to an existing habit like brushing your teeth.\n\nChallenge: 'It feels forced or unnatural.'\n\nResponse: It may feel awkward at first, but that's normal. Keep practicing, and it will become natural. Also, adjust it to feel authentic to you.\n\nTHE LONG-TERM IMPACT\n\nMorning rituals have cumulative effects:\n\n• They create lasting neural pathways\n• They build resilience over time\n• They reduce overall stress and anxiety\n• They improve your relationship with yourself\n• They support long-term behavior change\n• They become automatic and effortless\n\nYour morning ritual becomes a gift you give yourself every day—a foundation of calm, control, and intention that supports your quit journey and your overall well-being.\n\nREMEMBER: PROGRESS, NOT PERFECTION\n\nMorning rituals are about progress, not perfection:\n\n• Some days you'll do your full ritual, some days just part of it\n• The important thing is consistency over time\n• Even a brief ritual is better than none\n• Be patient with yourself as you build the habit\n• Adjust and refine as you learn what works for you\n\nYour morning ritual is a powerful tool that sets the tone for your entire day. It replaces the automatic morning vaping routine with intentional, health-supporting practices. Start small, be consistent, and watch how it transforms your quit journey and your life. Your future self will thank you for these morning moments of grounding and intention.",
                        sources: ["Journal of Health Psychology - Morning Routines and Stress Reduction", "Neuroscience Research - Habit Formation and Neural Pathways", "Journal of Behavioral Medicine - Morning Routines and Well-being", "American Psychological Association - Stress Management Techniques", "Harvard Medical School - The Benefits of Morning Routines", "Positive Psychology Research - Gratitude and Well-being"]
                    ),
                    Lesson.withContent(
                        title: "Social support toolkit",
                        summary: "Ask for what you need from friends without pressure.",
                        durationMinutes: 6,
                        icon: "👥",
                        content: "Social support is one of the strongest predictors of successful quitting. Research consistently shows that people with strong support networks are significantly more likely to quit and stay quit. However, asking for help can feel vulnerable, and many people struggle to build effective support systems. This comprehensive guide will help you understand why social support matters, how to build your support toolkit, and how to ask for what you need in ways that feel comfortable and effective.\n\nWHY SOCIAL SUPPORT MATTERS\n\nSocial support helps in multiple ways:\n\n• Accountability: Knowing someone is checking in on you increases your commitment\n• Emotional support: Having someone to talk to reduces stress and isolation\n• Practical help: Others can help you navigate challenges and provide resources\n• Motivation: Encouragement from others boosts your motivation\n• Perspective: Others can help you see your progress when you can't\n• Belonging: Feeling connected reduces the loneliness that can trigger vaping\n• Role modeling: Seeing others succeed inspires and motivates you\n\nUnderstanding why it matters helps you prioritize building your support network.\n\nTHE SCIENCE BEHIND SOCIAL SUPPORT\n\nResearch shows that social support:\n\n• Reduces stress and cortisol levels\n• Improves immune function\n• Increases motivation and self-efficacy\n• Reduces relapse risk\n• Improves mental health and well-being\n• Enhances resilience\n• Provides a sense of belonging and purpose\n\nThis isn't just feel-good advice—it's backed by decades of research.\n\nBUILDING YOUR SUPPORT TOOLKIT: WHO TO INCLUDE\n\nYour support toolkit should include different types of support:\n\n1. SOMEONE WHO'S QUIT SUCCESSFULLY\n\nWhy they're valuable:\n\n• They understand the journey firsthand\n• They can offer practical, tested advice\n• They provide hope and proof that it's possible\n• They understand the challenges without judgment\n• They can share what worked for them\n\nHow to find them:\n\n• Online quit communities\n• Support groups\n• Friends or family members who've quit\n• Coworkers or acquaintances\n• Social media groups\n\nHow to connect:\n\n• Ask about their experience\n• Seek their advice on specific challenges\n• Learn from their strategies\n• Share your journey with them\n\n2. A NON-JUDGMENTAL FRIEND OR FAMILY MEMBER\n\nWhy they're valuable:\n\n• They know you well\n• They care about your well-being\n• They can provide emotional support\n• They won't lecture or judge\n• They'll listen without trying to fix everything\n\nWhat to look for:\n\n• Someone who listens more than they talk\n• Someone who doesn't judge your struggles\n• Someone who encourages without pressuring\n• Someone who respects your process\n• Someone who's available when you need them\n\nHow to identify them:\n\n• They've been supportive in the past\n• They don't lecture or give unsolicited advice\n• They celebrate your wins with you\n• They're patient and understanding\n• They respect your boundaries\n\n3. AN ACCOUNTABILITY PARTNER\n\nWhy they're valuable:\n\n• Regular check-ins increase commitment\n• They help you stay on track\n• They celebrate your progress\n• They notice when you're struggling\n• They provide consistent support\n\nHow it works:\n\n• Daily or weekly check-ins\n• Honest sharing about your progress\n• Mutual support and encouragement\n• Accountability without judgment\n• Celebration of wins together\n\nHow to set it up:\n\n• Agree on check-in frequency (daily, weekly, etc.)\n• Decide on method (text, call, in-person)\n• Set expectations for what you'll share\n• Establish boundaries\n• Make it reciprocal if possible\n\n4. ONLINE COMMUNITIES AND SUPPORT GROUPS\n\nWhy they're valuable:\n\n• Available 24/7\n• Anonymous if you prefer\n• Connect with others on the same journey\n• Share experiences and strategies\n• Get support without judgment\n• Learn from others' experiences\n\nTypes of communities:\n\n• Reddit communities (r/quitvaping, r/stopsmoking)\n• Facebook groups\n• Discord servers\n• Quit apps with community features\n• Online forums\n• Virtual support groups\n\nBenefits:\n\n• Access to diverse experiences and strategies\n• Support at any time of day\n• Anonymity if desired\n• Global community\n• Variety of perspectives\n\n5. PROFESSIONAL SUPPORT (IF NEEDED)\n\nWhen to consider:\n\n• If you're struggling significantly\n• If you have underlying mental health concerns\n• If you need medical support (NRT, medications)\n• If you want structured, evidence-based help\n\nTypes of professional support:\n\n• Therapists or counselors\n• Quit coaches\n• Medical professionals\n• Support group facilitators\n• Addiction specialists\n\nHOW TO ASK FOR SUPPORT: PRACTICAL STRATEGIES\n\nAsking for help can feel vulnerable, but it's a skill you can develop:\n\n1. BE SPECIFIC ABOUT WHAT YOU NEED\n\nVague requests are hard to fulfill. Be specific:\n\nInstead of: 'Can you support me?'\nTry: 'Can I text you when I'm having a craving? I just need someone to talk to for a few minutes.'\n\nExamples of specific requests:\n\n• 'Can you check in with me daily for the first week?'\n• 'Can I call you when I'm struggling?'\n• 'Can you remind me why I'm quitting if you see me struggling?'\n• 'Can you celebrate my milestones with me?'\n• 'Can you help me avoid situations where I might be tempted?'\n\n2. SET CLEAR BOUNDARIES\n\nBoundaries help both of you:\n\n• 'I need encouragement, not lectures.'\n• 'I don't want you to check up on me constantly, just weekly check-ins.'\n• 'Please don't bring up my past attempts unless I do.'\n• 'I need you to listen, not try to fix everything.'\n• 'I'll let you know if I need advice versus just someone to listen.'\n\nWhy boundaries matter:\n\n• They prevent resentment\n• They make support more effective\n• They protect your relationship\n• They help you feel safe asking for help\n• They make it clear what you need\n\n3. EXPRESS GRATITUDE\n\nGratitude strengthens relationships:\n\n• 'Thank you for supporting me in this.'\n• 'I really appreciate you being there for me.'\n• 'Your support means a lot to me.'\n• 'I couldn't do this without you.'\n\nWhy it matters:\n\n• It acknowledges their effort\n• It strengthens your relationship\n• It makes them feel valued\n• It encourages continued support\n\n4. OFFER RECIPROCITY\n\nReciprocal support is stronger:\n\n• 'How can I support you in return?'\n• 'I'm here for you too if you need anything.'\n• 'Let's support each other.'\n\nWhy it helps:\n\n• It creates mutual support\n• It reduces feelings of burden\n• It strengthens relationships\n• It makes support feel balanced\n\n5. START SMALL\n\nYou don't have to ask for everything at once:\n\n• Start with one person and one type of support\n• Build your network gradually\n• Add more support as you need it\n• Don't overwhelm yourself or others\n\n6. BE HONEST ABOUT YOUR STRUGGLES\n\nHonesty enables effective support:\n\n• Share your challenges, not just your successes\n• Be honest about what's hard\n• Ask for help when you need it\n• Don't pretend everything is fine when it's not\n\nWhy honesty matters:\n\n• It allows people to support you effectively\n• It prevents isolation\n• It builds trust\n• It enables real connection\n\nOVERCOMING BARRIERS TO ASKING FOR HELP\n\nBarrier: 'I don't want to burden others.'\n\nResponse: Most people want to help but don't know how. By being specific about what you need, you're actually making it easier for them. Also, people who care about you want to support you.\n\nBarrier: 'I should be able to do this alone.'\n\nResponse: Quitting is challenging, and support is a strength, not a weakness. Even the strongest people benefit from support. You don't have to do it alone.\n\nBarrier: 'I'm embarrassed about my struggles.'\n\nResponse: Struggling with addiction is common and nothing to be ashamed of. The people who care about you won't judge you—they'll want to help.\n\nBarrier: 'I don't know who to ask.'\n\nResponse: Start with one person you trust. You can build your network gradually. Online communities are also great places to start.\n\nBarrier: 'I've asked for help before and it didn't work.'\n\nResponse: This time might be different. Also, different types of support work for different people. Keep trying until you find what works for you.\n\nMAINTAINING YOUR SUPPORT NETWORK\n\nOnce you've built your support network, maintain it:\n\n• Check in regularly, not just when you're struggling\n• Celebrate your wins with them\n• Express gratitude regularly\n• Be supportive in return\n• Respect boundaries\n• Communicate your needs clearly\n• Be patient and understanding\n\nTHE LONG-TERM BENEFITS\n\nA strong support network provides:\n\n• Lasting accountability\n• Ongoing encouragement\n• Reduced isolation\n• Increased resilience\n• Better mental health\n• Improved relationships\n• Long-term success\n\nYour support network is an investment in your recovery and your relationships. It's worth the effort to build and maintain.\n\nREMEMBER: ASKING FOR HELP IS A STRENGTH\n\nAsking for help is not a sign of weakness—it's a sign of:\n\n• Self-awareness\n• Courage\n• Wisdom\n• Strength\n• Commitment to your goals\n\nMost people want to help but don't know how. By being specific about your needs, you make it easier for them to support you effectively. Your support network is one of your most valuable resources in your quit journey. Build it, nurture it, and let it support you. You don't have to do this alone.",
                        sources: ["American Psychological Association - Social Support and Health Behavior Change", "Addiction Science & Clinical Practice - Peer Support in Recovery", "Journal of Health and Social Behavior - Social Support and Health Outcomes", "American Journal of Public Health - Social Support and Smoking Cessation", "Harvard Medical School - The Importance of Social Support", "Journal of Consulting and Clinical Psychology - Support Networks and Recovery"]
                    ),
                    Lesson.withContent(
                        title: "Evening unwinding",
                        summary: "Wind down without the vape—sleep-friendly swaps.",
                        durationMinutes: 9,
                        icon: "🌙",
                        content: "Evening was likely a prime vaping time for many people. The end of the day often brings stress, fatigue, and the desire to unwind, which can trigger strong cravings. Creating new, intentional evening wind-down rituals helps break the association between evening and vaping while significantly improving your sleep quality. This comprehensive guide will help you design evening routines that promote relaxation, support your quit journey, and set you up for restful sleep.\n\nWHY EVENING RITUALS MATTER\n\nEvening rituals are crucial for several reasons:\n\n• They break the association between evening and vaping\n• They signal to your body that it's time to rest\n• They reduce stress and anxiety before bed\n• They improve sleep quality\n• They create positive alternatives to vaping\n• They support your body's natural healing during sleep\n• They set you up for success the next day\n\nUnderstanding why they matter helps you prioritize them, even when you're tired or busy.\n\nTHE IMPACT OF NICOTINE ON SLEEP\n\nUnderstanding how nicotine affects sleep helps you appreciate the benefits of quitting:\n\n• Nicotine is a stimulant that disrupts sleep architecture\n• It reduces REM sleep (the restorative phase)\n• It increases sleep latency (time to fall asleep)\n• It causes more frequent awakenings\n• It reduces total sleep time\n• It decreases sleep quality overall\n\nWhen you quit:\n\n• You'll fall asleep more easily\n• You'll sleep more deeply\n• You'll get more restorative REM sleep\n• You'll wake less frequently\n• You'll wake more refreshed\n• You'll have more energy during the day\n\nBetter sleep reduces stress and cravings the next day, creating a positive cycle.\n\nSLEEP-FRIENDLY EVENING ALTERNATIVES\n\n1. HERBAL TEA: NATURAL RELAXATION\n\nHerbal teas can promote relaxation without stimulants:\n\n• Chamomile: Known for its calming properties, reduces anxiety and promotes sleep\n• Lavender: Has relaxing and sedative effects\n• Valerian root: Traditionally used for sleep support\n• Passionflower: Reduces anxiety and promotes relaxation\n• Peppermint: Soothes digestion and promotes calm\n• Lemon balm: Reduces stress and anxiety\n\nHow to practice:\n\n• Brew a cup 30-60 minutes before bed\n• Make it a ritual—use a special mug, sit in a comfortable place\n• Sip slowly and mindfully\n• Focus on the warmth and flavor\n• Let it be a moment of calm\n\nBenefits:\n\n• Provides oral satisfaction (replacing the hand-to-mouth habit)\n• Creates a calming ritual\n• Promotes relaxation\n• Supports sleep\n• Hydrates your body\n\n2. READING: MENTAL TRANSITION\n\nReading helps your mind transition from active to restful:\n\n• A physical book (not a screen) is best for sleep\n• It engages your mind in a calming way\n• It distracts from cravings and worries\n• It helps you unwind mentally\n• It creates a bedtime routine\n\nHow to practice:\n\n• Choose calming, non-stimulating content\n• Read for 20-30 minutes before bed\n• Read in dim light\n• Stop when you feel sleepy\n• Keep a book by your bed\n\nWhat to read:\n\n• Fiction (engaging but not too exciting)\n• Self-help or personal development\n• Poetry\n• Spiritual or philosophical texts\n• Anything that calms rather than stimulates\n\n3. GENTLE STRETCHING OR YOGA: RELEASE PHYSICAL TENSION\n\nGentle movement releases physical tension:\n\n• 10-15 minutes of gentle stretching or yoga\n• Focus on relaxing, not challenging poses\n• Emphasize deep breathing\n• Release tension in your body\n• Prepare your body for rest\n\nRecommended poses:\n\n• Child's pose: Calming and grounding\n• Legs up the wall: Promotes relaxation\n• Seated forward fold: Calms the nervous system\n• Supine twists: Releases tension in the spine\n• Corpse pose: Ultimate relaxation\n\nHow to practice:\n\n• Keep it gentle and slow\n• Focus on breath, not perfection\n• Hold poses for 30 seconds to 2 minutes\n• End with a few minutes of relaxation\n• Use props (pillows, blankets) for comfort\n\n4. JOURNALING: CLEAR YOUR MIND\n\nJournaling helps process the day and clear your mind:\n\n• Write down your thoughts, worries, or concerns\n• Express gratitude for the day\n• Reflect on your progress\n• Plan for tomorrow\n• Release what's on your mind\n\nWhat to write:\n\n• Three things you're grateful for today\n• One thing you're proud of\n• Any worries or concerns (getting them on paper can help release them)\n• Tomorrow's intentions\n• Reflections on your quit journey\n\nHow to practice:\n\n• Keep a journal by your bed\n• Write for 5-10 minutes\n• Don't worry about grammar or structure\n• Write stream-of-consciousness if helpful\n• Make it a regular practice\n\nBenefits:\n\n• Clears your mind before sleep\n• Processes emotions and thoughts\n• Creates closure for the day\n• Reduces anxiety and worry\n• Supports self-reflection\n\n5. WARM BATH OR SHOWER: TEMPERATURE REGULATION\n\nTemperature change signals rest to your body:\n\n• A warm bath or shower 1-2 hours before bed\n• The temperature change helps regulate your body's sleep-wake cycle\n• It promotes relaxation\n• It can reduce muscle tension\n• It creates a calming ritual\n\nHow to enhance it:\n\n• Add Epsom salts for muscle relaxation\n• Use calming essential oils (lavender, chamomile)\n• Dim the lights\n• Play calming music\n• Focus on the sensation, not rushing\n\nBenefits:\n\n• Promotes relaxation\n• Reduces physical tension\n• Signals to your body that it's time to rest\n• Creates a spa-like experience\n• Supports sleep onset\n\n6. BREATHING EXERCISES: ACTIVATE RELAXATION\n\nBreathing exercises are powerful for evening relaxation:\n\n• 4-7-8 breathing: Inhale 4, hold 7, exhale 8\n• Box breathing: Inhale 4, hold 4, exhale 4, hold 4\n• Belly breathing: Focus on deep abdominal breaths\n• Progressive relaxation: Tense and release muscle groups with breath\n\nHow to practice:\n\n• Lie in bed or sit comfortably\n• Close your eyes\n• Focus solely on your breath\n• Practice for 5-10 minutes\n• Let thoughts come and go\n\nBenefits:\n\n• Activates parasympathetic nervous system\n• Reduces stress and anxiety\n• Promotes relaxation\n• Improves sleep quality\n• Can reduce cravings\n\n7. AROMATHERAPY: CREATE A CALMING ENVIRONMENT\n\nScents can promote relaxation:\n\n• Lavender: Most researched for sleep and relaxation\n• Chamomile: Calming and soothing\n• Eucalyptus: Clears the mind\n• Sandalwood: Grounding and calming\n• Bergamot: Reduces anxiety\n\nHow to use:\n\n• Essential oil diffuser\n• Pillow spray\n• Scented candles (blow out before sleep)\n• Aromatherapy lotion\n• Bath products\n\nBenefits:\n\n• Creates a calming environment\n• Signals to your brain that it's time to rest\n• Reduces stress and anxiety\n• Improves sleep quality\n• Makes your bedroom a sanctuary\n\n8. GRATITUDE PRACTICE: END THE DAY POSITIVELY\n\nEnding the day with gratitude shifts your mindset:\n\n• Reflect on three things you're grateful for today\n• They can be big or small\n• Focus on the positive aspects of your day\n• Feel the gratitude, don't just list it\n• Write them down or think them\n\nBenefits:\n\n• Shifts focus from stress to appreciation\n• Improves mood\n• Reduces anxiety\n• Promotes positive thinking\n• Supports better sleep\n\nBUILDING YOUR EVENING RITUAL\n\nYour evening ritual should be personal and sustainable:\n\n• Choose 2-3 activities that work for you\n• Start 30-60 minutes before your desired sleep time\n• Make it consistent (same time, same activities)\n• Keep it relaxing, not stimulating\n• Adjust as you learn what works\n\nSample evening ritual (30-45 minutes):\n\n1. Dim the lights and reduce screen time (30 minutes before bed)\n2. Brew and enjoy herbal tea (15 minutes)\n3. Gentle stretching or yoga (10-15 minutes)\n4. Journaling or gratitude practice (5-10 minutes)\n5. Breathing exercises in bed (5 minutes)\n\nYou can adapt this to fit your needs and schedule.\n\nCREATING A SLEEP-SUPPORTIVE ENVIRONMENT\n\nYour environment matters for sleep:\n\n• Keep your bedroom cool (65-68°F is ideal)\n• Make it dark (blackout curtains, eye mask)\n• Keep it quiet (white noise machine if needed)\n• Remove screens (TV, phone, tablet)\n• Make your bed comfortable\n• Keep it clean and organized\n• Use it primarily for sleep and intimacy\n\nAVOIDING SLEEP DISRUPTERS\n\nIn the evening, avoid:\n\n• Caffeine (after 2 PM)\n• Large meals (within 2-3 hours of bed)\n• Alcohol (disrupts sleep quality)\n• Screens (blue light disrupts melatonin)\n• Intense exercise (within 2-3 hours of bed)\n• Stressful conversations or activities\n• Work or stimulating content\n\nTHE LONG-TERM IMPACT\n\nEvening rituals have cumulative effects:\n\n• They break the association between evening and vaping\n• They improve sleep quality over time\n• They reduce stress and anxiety\n• They support your body's healing during sleep\n• They create positive habits\n• They improve your overall well-being\n\nBetter sleep means:\n\n• Reduced cravings the next day\n• Better mood and energy\n• Improved cognitive function\n• Better stress management\n• Enhanced physical recovery\n• Stronger immune function\n\nREMEMBER: CONSISTENCY OVER PERFECTION\n\nEvening rituals are about consistency, not perfection:\n\n• Some nights you'll do your full ritual, some nights just part of it\n• The important thing is doing something consistently\n• Even a brief ritual is better than none\n• Be patient as you build the habit\n• Adjust and refine as you learn what works\n\nYour evening ritual becomes a gift you give yourself every night—a time to unwind, process the day, and prepare for restful sleep. It replaces the evening vaping routine with intentional, sleep-supporting practices. Start small, be consistent, and watch how it transforms your sleep, your quit journey, and your overall well-being. Your future self will thank you for these evening moments of calm and restoration.",
                        sources: ["Sleep Medicine Reviews - Nicotine and Sleep Quality", "Journal of Behavioral Medicine - Evening Routines and Sleep", "Journal of Sleep Research - Sleep Hygiene and Sleep Quality", "American Academy of Sleep Medicine - Healthy Sleep Habits", "Harvard Medical School - Sleep and Health", "Journal of Clinical Sleep Medicine - Non-Pharmacological Sleep Interventions"]
                    )
                ]
            ),
            LearningTopic(
                kind: .physical,
                title: "Learn & Reflect",
                blurb: "Short reads to reinforce your progress and calm cravings.",
                accent: primaryAccentColor,
                lessons: [
                    Lesson.withContent(
                        title: "Benefits of quitting",
                        summary: "Your body heals from day one.",
                        durationMinutes: 9,
                        icon: "❤️",
                        content: "Your body begins healing the moment you stop vaping. Understanding these benefits can strengthen your motivation during challenging moments. This comprehensive guide will walk you through every stage of recovery, from the first hour to years of improved health.\n\nIMMEDIATE BENEFITS (Within Hours):\n\n• 20 minutes: Your heart rate and blood pressure start to normalize. The constricting effects of nicotine on your blood vessels begin to reverse, allowing your cardiovascular system to function more efficiently. Your pulse rate drops, and your blood pressure begins to stabilize.\n\n• 2 hours: Nicotine levels in your bloodstream drop by half. Your body starts processing and eliminating the nicotine, reducing its immediate effects on your nervous system. You may notice your hands and feet feeling warmer as circulation improves.\n\n• 8-12 hours: Carbon monoxide levels in your blood drop significantly, allowing more oxygen to reach your cells. This is crucial because carbon monoxide binds to red blood cells more readily than oxygen, reducing your body's oxygen-carrying capacity. As it clears, you'll feel more alert and energetic.\n\n• 24 hours: Your risk of heart attack begins to decrease. The strain on your heart lessens as your cardiovascular system starts to recover. Your heart doesn't have to work as hard to pump blood, reducing the risk of cardiac events.\n\nSHORT-TERM BENEFITS (Days to Weeks):\n\n• 2-3 days: Your sense of taste and smell begin to improve dramatically. The nerve endings in your nose and taste buds start regenerating. Food will taste richer and more flavorful. You may notice scents you haven't smelled in years. This improvement continues for several weeks.\n\n• 3-5 days: Nicotine is completely eliminated from your body. Withdrawal symptoms typically peak during this time, but knowing that the physical dependency is ending can be empowering. Your body is now free from nicotine's influence.\n\n• 1 week: Circulation improves significantly, making physical activity easier. Your blood vessels are less constricted, allowing better blood flow to your muscles and organs. You may notice improved stamina during exercise and daily activities. Your skin may also look healthier due to improved circulation.\n\n• 2-4 weeks: Lung function increases measurably. You'll notice easier breathing, especially during physical activity. Your lung capacity improves as inflammation decreases. Coughing and shortness of breath should diminish. Many people report feeling like they can take deeper, fuller breaths.\n\n• 1 month: Your immune system begins to strengthen. White blood cell function improves, making you less susceptible to infections. You may notice fewer colds and faster recovery when you do get sick.\n\nMEDIUM-TERM BENEFITS (Months):\n\n• 1-3 months: Cilia in your lungs fully recover. These tiny hair-like structures line your airways and help clear mucus and debris. As they regenerate, your lungs become more effective at self-cleaning, reducing your risk of infections like bronchitis and pneumonia. Your lung capacity can increase by up to 30%.\n\n• 3-6 months: Your risk of respiratory infections decreases significantly. Your lungs are better equipped to defend against bacteria and viruses. If you were prone to frequent colds or respiratory issues, you'll likely notice a dramatic improvement.\n\n• 6 months: Your energy levels should be noticeably higher. Without the constant cycle of nicotine highs and crashes, your energy becomes more stable throughout the day. Many people report feeling more alert and less fatigued.\n\nLONG-TERM BENEFITS (Years):\n\n• 1 year: Your risk of heart disease drops by 50%. This is one of the most significant health improvements. Your cardiovascular system has had time to repair damage and reduce inflammation. Your heart attack risk is now half of what it was when you were vaping.\n\n• 2-5 years: Your stroke risk decreases significantly. The improved cardiovascular health and reduced inflammation lower your chances of experiencing a stroke. Your blood vessels are healthier and more flexible.\n\n• 5 years: Your risk of cancers of the mouth, throat, and esophagus decreases by 50%. The cells in these areas have had time to regenerate and repair damage. Your body's natural defense mechanisms are functioning better.\n\n• 10 years: Your lung cancer risk drops by 50% compared to continued vaping. Your lungs have had significant time to heal and regenerate. The risk continues to decrease the longer you remain vape-free.\n\n• 15 years: Your risk of heart disease is now similar to someone who never vaped. Your cardiovascular system has had extensive time to recover. This is a remarkable milestone that shows the body's incredible capacity for healing.\n\nADDITIONAL BENEFITS:\n\nBeyond the physical improvements, quitting vaping brings numerous other benefits:\n\n• Financial savings: Calculate how much you spent weekly on vaping supplies. Over a year, this can amount to hundreds or even thousands of dollars saved.\n\n• Improved appearance: Your skin will look healthier as circulation improves. You may notice fewer wrinkles and a more youthful complexion. Your teeth and gums will be healthier.\n\n• Better sleep: Nicotine disrupts sleep patterns. Without it, you'll sleep more deeply and wake more refreshed. Many people report needing less sleep but feeling more rested.\n\n• Reduced anxiety: While withdrawal can temporarily increase anxiety, long-term vaping cessation typically reduces overall anxiety levels. The constant cycle of nicotine highs and crashes creates anxiety that disappears once you quit.\n\n• Improved fertility: For both men and women, quitting vaping improves fertility and reproductive health. Sperm quality improves in men, and women have better chances of conception.\n\n• Better oral health: Your gums and teeth will be healthier. Reduced risk of gum disease, tooth loss, and oral cancers.\n\n• Enhanced sense of freedom: Many people report feeling liberated from the constant need to vape. You're no longer planning your day around vaping opportunities or worrying about running out of supplies.\n\nUNDERSTANDING THE HEALING PROCESS:\n\nYour body has remarkable regenerative abilities. Every cell in your body is constantly being replaced, and when you remove harmful substances like nicotine and the chemicals in vape products, your body can focus on healing and regeneration.\n\nThe timeline above shows average recovery rates, but individual experiences vary. Some people notice improvements faster, while others may take longer. Factors like age, overall health, how long you vaped, and genetics all play a role.\n\nWhat's important is that every moment without vaping is a step toward better health. Your body is designed to heal—you just need to give it the chance. Even if you've vaped for years, your body can still recover significantly.\n\nRemember: Progress isn't always linear. Some days you'll feel great, others you might feel tired or notice lingering symptoms. This is normal. The overall trend is toward improvement, and your body is working hard to repair itself.\n\nEvery benefit listed here is a reason to stay committed to your quit journey. When cravings hit, remind yourself of these improvements. Your future self will thank you for every moment you choose not to vape.",
                        sources: ["American Heart Association - Benefits of Quitting Smoking", "Centers for Disease Control and Prevention - Health Benefits Timeline", "Mayo Clinic - Quitting Smoking: Health Benefits", "National Cancer Institute - Health Benefits of Quitting", "American Lung Association - Benefits of Quitting", "World Health Organization - Tobacco Cessation Benefits"]
                    ),
                    Lesson.withContent(
                        title: "What vaping does",
                        summary: "Understand short and long-term risks.",
                        durationMinutes: 12,
                        icon: "🫁",
                        content: "Understanding what happens in your body when you vape can help clarify why quitting matters. This comprehensive guide explores the immediate and long-term effects of vaping on your body, mind, and overall health. Knowledge is power—understanding these effects isn't meant to create fear, but to empower you with information so you can make informed decisions about your health.\n\nIMMEDIATE SHORT-TERM EFFECTS (Within Minutes to Hours):\n\n• Nicotine constricts blood vessels: Within seconds of inhaling, nicotine enters your bloodstream and causes your blood vessels to narrow. This increases your heart rate by 10-20 beats per minute and raises your blood pressure. Your heart has to work harder to pump blood through constricted vessels, putting strain on your cardiovascular system. This effect can last for 30 minutes to several hours after vaping.\n\n• Reduces oxygen delivery: The chemicals in vape aerosols, including carbon monoxide and other toxins, bind to red blood cells more readily than oxygen. This means less oxygen reaches your brain, muscles, and organs. You may not notice this immediately, but it affects your energy levels, cognitive function, and physical performance. Over time, this oxygen deprivation can cause cellular damage.\n\n• Affects brain chemistry immediately: Nicotine reaches your brain within 10 seconds of inhalation. It binds to nicotinic acetylcholine receptors, triggering a massive release of dopamine—the \"feel-good\" neurotransmitter. This creates a temporary sense of pleasure and alertness. However, your brain quickly adapts, requiring more nicotine to achieve the same effect. This is how dependency develops so rapidly.\n\n• Alters reward pathways: Each time you vape, you're reinforcing the neural pathways that associate vaping with reward. Your brain learns that vaping = pleasure, making it increasingly difficult to resist cravings. This rewiring happens quickly and can persist long after you quit, which is why cravings can feel so powerful.\n\n• Impairs lung function immediately: Even a single vaping session can cause inflammation in your airways. Your lungs respond to the foreign substances by producing mucus and constricting airways. This reduces your lung capacity temporarily. You may not notice this if you're a regular vaper, but your lungs are working harder than they should.\n\n• Increases stress hormones: While nicotine initially feels calming, it actually increases cortisol and adrenaline—stress hormones. This creates a cycle where you vape to feel better, but the vaping itself increases stress, leading to more vaping. This is why many people feel more anxious overall when vaping regularly.\n\n• Affects blood sugar: Nicotine can cause blood sugar spikes and crashes, leading to energy fluctuations throughout the day. This can contribute to mood swings and make it harder to maintain stable energy levels.\n\nMEDIUM-TERM EFFECTS (Days to Months):\n\n• Chronic inflammation: Regular vaping keeps your body in a state of low-grade inflammation. Your immune system is constantly fighting the foreign substances, which can lead to fatigue, joint pain, and increased susceptibility to illness. This inflammation affects your entire body, not just your lungs.\n\n• Reduced immune function: The constant exposure to chemicals weakens your immune system's ability to fight infections. You may notice you get sick more often, take longer to recover, or develop more severe symptoms when you do get ill.\n\n• Skin and appearance changes: Reduced circulation and oxygen delivery can make your skin look dull and aged. You may notice premature wrinkles, especially around your mouth from the repetitive motion. Your skin may also heal more slowly from cuts and bruises.\n\n• Dental and oral health issues: Vaping can cause dry mouth, which increases the risk of cavities and gum disease. The chemicals can irritate your gums and lead to inflammation. Some studies suggest vaping may increase the risk of oral infections and periodontal disease.\n\n• Sleep disruption: Nicotine is a stimulant that can disrupt your sleep patterns. Even if you don't vape right before bed, the effects on your nervous system can make it harder to fall asleep and stay asleep. Poor sleep quality affects every aspect of your health.\n\n• Digestive issues: Nicotine affects your digestive system, potentially causing nausea, stomach pain, or changes in appetite. Some people experience constipation or other digestive problems.\n\nLONG-TERM RISKS (Months to Years):\n\n• Cardiovascular disease: Chronic exposure to nicotine and other chemicals significantly increases your risk of heart attack, stroke, and peripheral artery disease. The constant constriction of blood vessels, increased heart rate, and inflammation create conditions that can lead to serious cardiovascular problems. Research shows that vaping increases heart attack risk by up to 34% compared to non-users.\n\n• Respiratory problems: Long-term vaping can lead to chronic bronchitis, emphysema, and significantly reduced lung function. The delicate tissues in your lungs can become scarred and damaged. You may develop a chronic cough, wheezing, or shortness of breath that persists even when you're not actively vaping.\n\n• EVALI (E-cigarette or Vaping product use-Associated Lung Injury): This serious condition can develop from vaping, causing severe lung damage, difficulty breathing, and in some cases, death. While more common with certain products, it highlights the unpredictable risks of vaping.\n\n• Cancer risk: While research is ongoing, vaping exposes you to known carcinogens including formaldehyde, acetaldehyde, and acrolein. These substances can damage DNA and increase cancer risk. Studies suggest increased risk of lung, oral, and esophageal cancers. The full extent of cancer risk may not be known for decades, as many cancers develop slowly over time.\n\n• Brain development issues: For younger users, vaping can interfere with brain development, affecting attention, learning, and impulse control. The brain continues developing until around age 25, and nicotine exposure during this time can have lasting effects.\n\n• Reproductive health: Vaping can affect fertility in both men and women. In men, it can reduce sperm quality and count. In women, it can affect egg quality and increase the risk of pregnancy complications. During pregnancy, vaping can harm fetal development.\n\n• Bone health: Some research suggests that nicotine can interfere with bone healing and may contribute to decreased bone density over time, increasing fracture risk, especially as you age.\n\n• Mental health impacts: While many people vape to manage stress or anxiety, nicotine dependency actually increases anxiety and depression over time. The constant cycle of nicotine highs and crashes creates mood instability. Withdrawal symptoms can include increased anxiety, irritability, and depression.\n\n• Addiction and dependency: Nicotine is one of the most addictive substances known. The ease of vaping (no need to light anything, can do it indoors, less social stigma) can lead to more frequent use and stronger dependency than traditional smoking. Breaking this dependency becomes increasingly difficult the longer you vape.\n\nUNDERSTANDING THE CHEMICALS:\n\nVape aerosols contain numerous chemicals beyond nicotine:\n\n• Propylene glycol and vegetable glycerin: While generally recognized as safe for consumption, the effects of heating and inhaling these substances are less understood. They can break down into harmful compounds when heated.\n\n• Flavoring chemicals: Many flavorings used in vape products haven't been tested for safety when inhaled. Some, like diacetyl, have been linked to serious lung disease.\n\n• Heavy metals: Vaping devices can release small amounts of metals like lead, nickel, and chromium into the aerosol, which you then inhale.\n\n• Ultrafine particles: These tiny particles can penetrate deep into your lungs and enter your bloodstream, potentially causing inflammation and other health issues throughout your body.\n\nTHE CUMULATIVE EFFECT:\n\nIt's important to understand that these effects are cumulative. Each vaping session adds to the damage. Your body has remarkable healing abilities, but constant exposure prevents it from fully recovering. The longer you vape, the more damage accumulates, and the longer it takes to heal once you quit.\n\nHowever, this isn't meant to be discouraging. Every moment you choose not to vape is a moment your body can begin healing. The damage isn't necessarily permanent—your body can recover significantly once you remove the source of harm.\n\nKNOWLEDGE AS EMPOWERMENT:\n\nUnderstanding what vaping does to your body gives you power. When cravings hit, you can remind yourself of these effects. When you're tempted to vape, you can remember that you're choosing to avoid these risks. Knowledge helps you make informed decisions and strengthens your resolve to quit.\n\nYour body has remarkable healing abilities once you stop vaping. Many of these effects begin to reverse within hours or days of quitting. The sooner you quit, the sooner your body can begin the healing process. Every day without vaping is a step toward better health.",
                        sources: ["National Institute on Drug Abuse - Vaping Health Effects", "American Lung Association - Health Risks of Vaping", "World Health Organization - Electronic Nicotine Delivery Systems", "Centers for Disease Control and Prevention - Health Effects of E-Cigarettes", "Journal of the American Heart Association - Cardiovascular Effects of E-Cigarettes", "Nature Reviews Drug Discovery - Nicotine Addiction and Health Effects"]
                    ),
                    Lesson.withContent(
                        title: "Tips to quit",
                        summary: "Craving hacks and routines that work.",
                        durationMinutes: 9,
                        icon: "💡",
                        content: "Quitting vaping is a journey, and having practical strategies makes all the difference. This comprehensive guide provides evidence-based tips that have helped millions of people successfully quit. Remember: there's no one-size-fits-all approach. Try different strategies and find what works best for you. The key is to keep trying and not give up, even if you experience setbacks.\n\nPHASE 1: PREPARATION (Before You Quit)\n\n1. Set a quit date and stick to it:\n\nChoose a date within the next two weeks—not too far away that you lose motivation, but not so soon that you're not prepared. Pick a day when you'll have minimal stress and can focus on your quit. Some people choose a meaningful date like a birthday or anniversary. Mark it on your calendar and treat it as seriously as any important appointment.\n\n2. Remove all vaping devices and supplies:\n\nThis is crucial. Remove temptation by getting rid of all vape devices, pods, e-liquids, chargers, and any related accessories. Don't keep \"just one\" as a backup—that backup will become your downfall. Give them away, throw them away, or return them if possible. Clean your car, home, and workspace of any vaping-related items.\n\n3. Tell friends and family:\n\nAccountability is powerful. Tell people you trust about your decision to quit. Ask for their support and be specific about what you need. For example: \"I'm quitting vaping on [date]. Can you check in with me daily for the first week?\" or \"If you see me struggling, can you remind me why I'm quitting?\" Having people who know and support your goal makes it harder to give up.\n\n4. Identify your triggers:\n\nSpend a few days before your quit date noticing when and why you vape. Common triggers include: stress, boredom, after meals, while driving, social situations, certain times of day, specific locations, or emotional states. Write these down. Awareness is the first step to managing triggers.\n\n5. Prepare your environment:\n\nStock up on healthy alternatives: water, sugar-free gum, healthy snacks, herbal tea, toothpicks, or fidget toys. Prepare activities that can distract you: books, puzzles, exercise equipment, or hobby supplies. Make your environment supportive of your quit attempt.\n\n6. Plan for withdrawal:\n\nUnderstand that withdrawal symptoms are temporary and manageable. Common symptoms include: irritability, anxiety, difficulty concentrating, restlessness, increased appetite, and cravings. These typically peak within the first 3-5 days and gradually decrease. Knowing what to expect helps you prepare mentally.\n\nPHASE 2: REPLACEMENT STRATEGIES (During Cravings)\n\n1. Physical replacements:\n\n• Water: Keep a water bottle with you at all times. When a craving hits, take slow sips. The act of drinking and the hydration can help reduce cravings.\n• Sugar-free gum or mints: The oral fixation of vaping can be satisfied with gum. The minty flavor can also feel refreshing.\n• Healthy snacks: Crunchy vegetables like carrots or celery, or fruits like apples can satisfy the hand-to-mouth habit.\n• Toothpicks or cinnamon sticks: These can help with the oral fixation without adding calories.\n• Fidget toys: Stress balls, worry stones, or fidget spinners can keep your hands busy.\n\n2. Activity replacements:\n\n• Walking: Even a 5-minute walk can reduce cravings and improve mood. The movement and change of scenery help break the craving cycle.\n• Deep breathing: The 4-7-8 technique (inhale for 4, hold for 7, exhale for 8) activates your relaxation response and can reduce cravings.\n• Exercise: More intense exercise releases endorphins and can significantly reduce cravings for up to an hour afterward.\n• Reading: Engaging your mind with a book or article can distract you from cravings.\n• Calling a friend: Social connection releases dopamine naturally and can replace the social aspect of vaping.\n• Hobbies: Engage in activities you enjoy—drawing, music, gardening, cooking, or anything that keeps your hands and mind busy.\n\n3. Mental replacements:\n\n• Remind yourself why you're quitting: Keep a list of your reasons visible. Read it when cravings hit.\n• Visualize success: Picture yourself as a non-vaper. Imagine how you'll feel, look, and what you'll be able to do.\n• Count the benefits: Mentally list the benefits you've already experienced or will experience.\n• Use affirmations: \"I am stronger than this craving,\" \"This will pass,\" \"I choose my health.\"\n\nPHASE 3: HANDLING CRAVINGS (The 3-5 Minute Window)\n\nCravings typically peak within 3-5 minutes and then subside. Here's how to ride them out:\n\n1. The 4-7-8 breathing technique:\n\nThis powerful technique can reduce cravings and anxiety:\n• Inhale through your nose for 4 counts\n• Hold your breath for 7 counts\n• Exhale through your mouth for 8 counts\n• Repeat 4-8 times\n\nThis activates your parasympathetic nervous system, reducing stress and cravings.\n\n2. The 5-minute rule:\n\nWhen a craving hits, tell yourself: \"I'll wait 5 minutes before deciding.\" Set a timer. During those 5 minutes, do one of your replacement activities. Often, by the time the timer goes off, the craving has passed or significantly decreased.\n\n3. Physical activity:\n\n• 10 push-ups or sit-ups\n• Jumping jacks\n• A quick walk up and down stairs\n• Stretching\n• Dancing to one song\n\nPhysical movement releases endorphins and can interrupt the craving cycle.\n\n4. Distraction techniques:\n\n• Count backwards from 100 by 7s\n• Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste\n• Recite something from memory (a poem, song lyrics, etc.)\n• Do a quick mental puzzle\n• Focus intensely on a single object and describe it in detail\n\n5. Cold water technique:\n\nSplash cold water on your face or hold an ice cube. The shock can interrupt the craving and activate your dive reflex, which can calm your nervous system.\n\nPHASE 4: MANAGING WITHDRAWAL\n\n1. Stay hydrated:\n\nDehydration can mimic or worsen withdrawal symptoms. Aim for 8-10 glasses of water daily. Herbal teas can also be soothing and help with hydration.\n\n2. Get plenty of sleep:\n\nWithdrawal can disrupt sleep, but adequate rest is crucial for managing symptoms. Create a bedtime routine, avoid screens before bed, and aim for 7-9 hours of sleep.\n\n3. Eat regular, balanced meals:\n\nBlood sugar fluctuations can worsen cravings and mood swings. Eat regular meals with protein, complex carbs, and healthy fats. Avoid skipping meals.\n\n4. Consider nicotine replacement therapy (NRT):\n\nUnder medical guidance, NRT can help manage withdrawal symptoms. Options include patches, gum, lozenges, or nasal spray. NRT provides nicotine without the harmful chemicals in vape products, allowing you to gradually reduce nicotine intake.\n\n5. Manage stress:\n\nWithdrawal can increase stress, which can trigger cravings. Practice stress management techniques:\n• Meditation or mindfulness\n• Yoga or gentle stretching\n• Journaling\n• Talking to a supportive person\n• Taking breaks when needed\n\n6. Be patient with yourself:\n\nWithdrawal symptoms are temporary. They're a sign that your body is healing and adjusting to life without nicotine. Remind yourself that these symptoms will pass.\n\nPHASE 5: RECOVERING FROM SLIPS\n\nIf you slip, don't give up. Slips are common and don't mean you've failed. Here's how to recover:\n\n1. Don't catastrophize:\n\nOne slip doesn't erase your progress. Don't fall into the \"I've already messed up, so I might as well keep going\" trap. A slip is a single event, not a failure.\n\n2. Log what happened:\n\nAs soon as possible, write down:\n• What triggered the slip?\n• Where were you?\n• What were you feeling?\n• What time was it?\n• What were you thinking?\n\nThis information helps you identify patterns and prepare for similar situations.\n\n3. Identify the trigger:\n\nUnderstanding what led to the slip helps you prepare for next time. Was it stress? Social pressure? A specific location? A certain time of day?\n\n4. Adjust your strategy:\n\nBased on what you learned, what will you do differently? Do you need to avoid certain situations? Do you need different coping strategies? Do you need more support?\n\n5. Recommit immediately:\n\nDon't wait until tomorrow or next week. Recommit to quitting right now. The longer you wait, the harder it becomes.\n\n6. Learn from it:\n\nEvery slip teaches you something. What did you learn? How can you use this knowledge to strengthen your quit attempt?\n\n7. Progress over perfection:\n\nRemember: every moment vape-free counts. If you were vape-free for 3 days and then slipped, you still had 3 days of healing. That progress isn't lost.\n\nADDITIONAL SUCCESS STRATEGIES:\n\n1. Track your progress:\n\nUse an app, calendar, or journal to track your quit journey. Mark each vape-free day. Celebrate milestones. Seeing your progress visually can be very motivating.\n\n2. Reward yourself:\n\nSet up a reward system. Calculate how much money you're saving and use some of it to reward yourself at milestones (1 day, 1 week, 1 month, etc.).\n\n3. Find your \"why\":\n\nConnect with your deeper reasons for quitting. Is it for your health? Your family? Your future? Your finances? Write these down and revisit them regularly.\n\n4. Build a support network:\n\nConnect with others who are quitting or have quit. Join online communities, support groups, or find a quit buddy. Sharing the journey makes it easier.\n\n5. Avoid high-risk situations:\n\nEspecially in early days, avoid situations where you know you'll be tempted. This isn't forever—just until you're stronger in your quit.\n\n6. Practice self-compassion:\n\nBe kind to yourself. Quitting is hard. You're doing something difficult. Treat yourself with the same compassion you'd show a friend going through this.\n\n7. Celebrate small wins:\n\nEvery hour, every day vape-free is an achievement. Acknowledge and celebrate these moments. They build momentum.\n\nREMEMBER:\n\nMillions of people have successfully quit vaping. You have the tools and the strength to do it too. It may not be easy, but it's absolutely possible. Every attempt teaches you something. Every moment vape-free is progress. Keep trying, keep learning, and keep moving forward. You can do this.",
                        sources: ["Centers for Disease Control and Prevention - Tips for Quitting", "American Cancer Society - Quitting Guide", "Smokefree.gov - Quit Plan"]
                    )
                ]
            )
        ]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
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
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .navigationTitle("Learn")
            .breathableBackground()
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailModal(lesson: lesson, accent: accentForLesson(lesson))
                .environmentObject(dataStore)
        }
    }
    
    private func accentForLesson(_ lesson: Lesson) -> Color {
        // Always return primary accent color for consistency
        return primaryAccentColor
    }
    
    private func progressValue(for topic: LearningTopic) -> Double {
        // Progress based on read lessons in this topic for all sections
        let topicLessons = topic.lessons
        guard !topicLessons.isEmpty else { return 0.0 }
        let readCount = topicLessons.filter { dataStore.isLessonRead($0.title) }.count
        return Double(readCount) / Double(topicLessons.count)
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
    @EnvironmentObject var dataStore: AppDataStore
    let topic: LearningTopic
    let progress: Double
    let encouragement: String
    let onLessonTap: (Lesson) -> Void
    
    // Primary brand color - consistent across all sections (light blue)
    private let primaryAccentColor = Color(red: 0.45, green: 0.72, blue: 0.99)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Section header - more prominent
            VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                    Group {
                        if topic.icon.unicodeScalars.first?.properties.isEmoji == true {
                            Text(topic.icon)
                                .font(.title2)
                        } else {
                    Image(systemName: topic.icon)
                                .foregroundColor(primaryAccentColor)
                        .font(.title2)
                }
                    }
                    Text(topic.title)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }
                    Text(topic.blurb)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Thinner progress bar
                HStack(spacing: 8) {
                    SwiftUI.ProgressView(value: progress)
                        .tint(primaryAccentColor)
                        .frame(height: 2)
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 35, alignment: .trailing)
                }
            }
            
            // Lessons with increased vertical spacing
            VStack(alignment: .leading, spacing: 16) {
                ForEach(topic.lessons) { lesson in
                    LessonTile(lesson: lesson, accent: primaryAccentColor, onTap: {
                        onLessonTap(lesson)
                    })
                    .environmentObject(dataStore)
                }
            }
            
            Text(encouragement)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .combine)
    }
}

private struct LessonTile: View {
    @EnvironmentObject var dataStore: AppDataStore
    let lesson: Lesson
    let accent: Color
    let onTap: () -> Void
    
    private var isRead: Bool {
        dataStore.isLessonRead(lesson.title)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon - subtle completion indicator
                ZStack {
                    Circle()
                    .fill(accent.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                if isRead {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(accent.opacity(0.6))
                        .font(.title3)
                } else {
                    if lesson.icon.unicodeScalars.first?.properties.isEmoji == true {
                        Text(lesson.icon)
                            .font(.title3)
                    } else {
                    Image(systemName: lesson.icon)
                        .foregroundColor(accent)
                            .font(.title3)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Bolder title
                    Text(lesson.title)
                    .font(.headline.weight(.bold))
                        .foregroundColor(.primary)
                
                // Lighter, smaller description
                    Text(lesson.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                
                // Low-contrast pills
                HStack(spacing: 8) {
                    Text("\(lesson.durationMinutes) min read")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 8)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.08))
                        )
                    
                    if isRead {
                        Text("Read")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.08))
                            )
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        )
        .opacity(isRead ? 0.85 : 1.0) // Subtle opacity for completed items
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
    @EnvironmentObject var dataStore: AppDataStore
    let lesson: Lesson
    let accent: Color
    
    private var isRead: Bool {
        dataStore.isLessonRead(lesson.title)
    }
    
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
                    
                    Group {
                        if lesson.icon.unicodeScalars.first?.properties.isEmoji == true {
                            Text(lesson.icon)
                                .font(.system(size: 24, weight: .medium))
                        } else {
                    Image(systemName: lesson.icon)
                        .foregroundColor(accent)
                        .font(.system(size: 24, weight: .medium))
                        }
                    }
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
                if !isRead {
                    dataStore.markLessonAsRead(lesson.title)
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Spacer()
                    Text(isRead ? "Marked as read" : getCTAButtonText())
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [accent, accent.opacity(0.85)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: accent.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isRead)
            .opacity(1.0) // Maintain full opacity even when disabled
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
            return "Mark as read"
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












