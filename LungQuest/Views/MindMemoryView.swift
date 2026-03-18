import SwiftUI
import UIKit

struct MindMemoryView: View {
    @State private var cards: [MemoryCard] = []
    @State private var selectedIndices: [Int] = []
    @State private var isResolvingMismatch: Bool = false
    @State private var matchesFound: Int = 0
    @State private var turnsTaken: Int = 0
    
    private let assetNames: [String] = ["memory_1", "memory_2", "memory_3", "memory_4", "memory_5", "memory_6"]
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    private var allMatched: Bool {
        matchesFound == assetNames.count
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Mind Memory")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Flip cards and find matching pairs. Stay calm, stay focused, and clear the board at your own pace.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label("Matches found: \(matchesFound)/\(assetNames.count)", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.black.opacity(0.85))
                    Spacer()
                    Text("Turns: \(turnsTaken)")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 2)
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        Button(action: { handleCardTap(at: index) }) {
                            MemoryCardView(card: card)
                                .aspectRatio(0.88, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                        .allowsHitTesting(
                            !isResolvingMismatch &&
                            !card.isMatched &&
                            !card.isFaceUp &&
                            selectedIndices.count < 2
                        )
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.88))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.55), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                )
                
                if allMatched {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Great work! You matched all pairs.")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.black.opacity(0.9))
                        
                        Text("Take a steady breath and play again whenever you want another quick reset.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: resetGame) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                Text("Play Again")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.45, green: 0.72, blue: 0.99),
                                                Color(red: 0.30, green: 0.60, blue: 0.90)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                } else {
                    Button(action: resetGame) {
                        Text("Shuffle & Restart")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.white.opacity(0.85))
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding()
        }
        .navigationTitle("Mind Memory")
        .navigationBarTitleDisplayMode(.inline)
        .breathableBackground()
        .onAppear {
            if cards.isEmpty {
                resetGame()
            }
        }
        .onChange(of: allMatched) { _, completed in
            if completed {
                ExerciseDailyProgress.markCompletedToday(.mindMemory)
            }
        }
    }
    
    private func resetGame() {
        selectedIndices.removeAll()
        isResolvingMismatch = false
        matchesFound = 0
        turnsTaken = 0
        
        var deck: [MemoryCard] = assetNames.flatMap { name in
            [MemoryCard(assetName: name), MemoryCard(assetName: name)]
        }
        deck.shuffle()
        cards = deck
    }
    
    private func handleCardTap(at index: Int) {
        guard cards.indices.contains(index) else { return }
        guard !isResolvingMismatch else { return }
        guard !cards[index].isMatched, !cards[index].isFaceUp else { return }
        guard selectedIndices.count < 2 else { return }
        
        withAnimation(.easeInOut(duration: 0.22)) {
            cards[index].isFaceUp = true
        }
        selectedIndices.append(index)
        
        guard selectedIndices.count == 2 else { return }
        
        turnsTaken += 1
        let first = selectedIndices[0]
        let second = selectedIndices[1]
        
        if cards[first].assetName == cards[second].assetName {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                withAnimation(.easeInOut(duration: 0.18)) {
                    cards[first].isMatched = true
                    cards[second].isMatched = true
                }
                matchesFound += 1
                selectedIndices.removeAll()
            }
        } else {
            isResolvingMismatch = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
                withAnimation(.easeInOut(duration: 0.22)) {
                    cards[first].isFaceUp = false
                    cards[second].isFaceUp = false
                }
                selectedIndices.removeAll()
                isResolvingMismatch = false
            }
        }
    }
}

private struct MemoryCard: Identifiable {
    let id = UUID()
    let assetName: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

private struct MemoryCardView: View {
    let card: MemoryCard
    
    private var hasAsset: Bool {
        UIImage(named: card.assetName) != nil
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(frontColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .opacity(card.isFaceUp || card.isMatched ? 1 : 0)
            
            Group {
                if hasAsset {
                    Image(card.assetName)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .opacity(1.0)
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "photo")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Image")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundColor(.secondary)
                }
            }
            .opacity(card.isFaceUp || card.isMatched ? 1 : 0)
            
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(backGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "questionmark")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                )
                .opacity(card.isFaceUp || card.isMatched ? 0 : 1)
        }
        .animation(.easeInOut(duration: 0.20), value: card.isFaceUp)
        .animation(.easeInOut(duration: 0.20), value: card.isMatched)
        .shadow(
            color: Color.black.opacity(card.isMatched ? 0.14 : 0.08),
            radius: card.isMatched ? 8 : 5,
            x: 0,
            y: card.isMatched ? 6 : 3
        )
        .scaleEffect(card.isMatched ? 0.98 : 1.0)
    }
    
    private var frontColor: Color {
        Color.white
    }
    
    private var backGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.45, green: 0.72, blue: 0.99),
                Color(red: 0.31, green: 0.61, blue: 0.90)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    NavigationView {
        MindMemoryView()
    }
}
