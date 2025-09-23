import SwiftUI
import UIKit

struct LungBuddyImageView: View {
    let healthLevel: Int // 0-100
    @State private var bob: Bool = false
    
    private var bucketedLevel: Int {
        let clamped = max(0, min(100, healthLevel))
        let buckets: [Int] = [0, 25, 50, 75, 100]
        // Find nearest bucket
        if let nearest = buckets.min(by: { abs($0 - clamped) < abs($1 - clamped) }) {
            return nearest
        }
        return 0
    }
    
    private var assetName: String { "LungBuddy_\(bucketedLevel)" }
    
    var body: some View {
        Group {
            if let uiImage = UIImage(named: assetName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                // Fallback to vector lungs if asset not present yet
                LungCharacter(healthLevel: healthLevel, isAnimating: true)
            }
        }
        .offset(y: bob ? -4 : 4)
        .animation(.easeInOut(duration: bobbingDuration).repeatForever(autoreverses: true), value: bob)
        .onAppear { bob = true }
        .accessibilityLabel("LungBuddy health image for level \(bucketedLevel)")
    }
    
    private var bobbingDuration: Double {
        // Slightly faster bob when healthier
        let base = 2.0
        let factor = 1.2 - (Double(healthLevel) / 100.0)
        return max(0.9, base * factor)
    }
}

#Preview {
    VStack(spacing: 20) {
        LungBuddyImageView(healthLevel: 5).frame(width: 180, height: 140)
        LungBuddyImageView(healthLevel: 55).frame(width: 180, height: 140)
        LungBuddyImageView(healthLevel: 95).frame(width: 180, height: 140)
    }
    .padding()
}


