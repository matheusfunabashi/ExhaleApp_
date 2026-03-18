import SwiftUI

struct ConnectDotsView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var puzzle: ConnectDotsPuzzle = ConnectDotsPuzzleLibrary.puzzleForToday()
    @State private var loadedDayKey: String = ConnectDotsPuzzleLibrary.dayKeyForToday()
    
    @State private var solvedPaths: [PathColorID: [GridCell]] = [:]
    @State private var activeColor: PathColorID? = nil
    @State private var activePath: [GridCell] = []
    
    private var connectedPairs: Int {
        puzzle.colors.filter { color in
            guard let path = currentPath(for: color) else { return false }
            return isCompletedPath(path, for: color)
        }.count
    }
    
    private var puzzleCompleted: Bool {
        connectedPairs == puzzle.colors.count
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Connect the Dots")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Connect matching colors without crossing the paths.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Today's Puzzle")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Pairs connected: \(connectedPairs)/\(puzzle.colors.count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.black.opacity(0.85))
                    Spacer()
                    Button(action: resetPuzzle) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.92))
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                ConnectDotsBoardView(
                    puzzle: puzzle,
                    solvedPaths: solvedPaths,
                    activeColor: activeColor,
                    activePath: activePath,
                    onDragChanged: handleDragChanged(cell:),
                    onDragEnded: finalizeActivePath
                )
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 6)
                )
                
                if puzzleCompleted {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nice work! Puzzle complete.")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.black.opacity(0.9))
                        Text("You connected every color pair without crossing paths.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Connect the Dots")
        .navigationBarTitleDisplayMode(.inline)
        .breathableBackground()
        .onAppear {
            refreshDailyPuzzleIfNeeded()
            resetPuzzle()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                refreshDailyPuzzleIfNeeded()
            }
        }
        .onChange(of: puzzleCompleted) { _, completed in
            if completed {
                ExerciseDailyProgress.markCompletedToday(.connectDots)
            }
        }
    }
    
    private func resetPuzzle() {
        solvedPaths = [:]
        activeColor = nil
        activePath = []
    }
    
    private func refreshDailyPuzzleIfNeeded() {
        let currentDayKey = ConnectDotsPuzzleLibrary.dayKeyForToday()
        guard currentDayKey != loadedDayKey else { return }
        loadedDayKey = currentDayKey
        puzzle = ConnectDotsPuzzleLibrary.puzzleForToday()
        resetPuzzle()
    }
    
    private func handleDragChanged(cell: GridCell) {
        // Begin a path only from a valid endpoint.
        if activeColor == nil {
            guard let startColor = puzzle.color(atEndpoint: cell) else { return }
            activeColor = startColor
            activePath = [cell]
            return
        }
        
        guard let color = activeColor, let last = activePath.last else { return }
        guard cell != last else { return }
        guard isOrthogonallyAdjacent(last, cell) else { return }
        
        // Allow intuitive backtracking while dragging.
        if let idx = activePath.firstIndex(of: cell) {
            activePath = Array(activePath.prefix(idx + 1))
            return
        }
        
        // Once we reach the opposite endpoint, do not extend past it.
        if let start = activePath.first,
           let opposite = puzzle.oppositeEndpoint(for: color, from: start),
           last == opposite {
            return
        }
        
        // Never step onto another color's endpoint.
        if let endpointColor = puzzle.color(atEndpoint: cell), endpointColor != color {
            return
        }
        
        // Paths cannot cross existing solved paths from other colors.
        if isOccupiedByOtherSolvedPath(cell, excluding: color) {
            return
        }
        
        activePath.append(cell)
    }
    
    private func finalizeActivePath() {
        guard let color = activeColor else { return }
        defer {
            activeColor = nil
            activePath = []
        }
        
        if isCompletedPath(activePath, for: color) {
            withAnimation(.easeInOut(duration: 0.18)) {
                solvedPaths[color] = activePath
            }
        }
    }
    
    private func isOccupiedByOtherSolvedPath(_ cell: GridCell, excluding color: PathColorID) -> Bool {
        solvedPaths.contains { key, path in
            key != color && path.contains(cell)
        }
    }
    
    private func isCompletedPath(_ path: [GridCell], for color: PathColorID) -> Bool {
        guard path.count >= 2 else { return false }
        guard let first = path.first, let last = path.last else { return false }
        
        let endpoints = Set(puzzle.endpoints[color] ?? [])
        guard endpoints.count == 2 else { return false }
        guard Set([first, last]) == endpoints else { return false }
        
        for index in 1..<path.count where !isOrthogonallyAdjacent(path[index - 1], path[index]) {
            return false
        }
        return true
    }
    
    private func currentPath(for color: PathColorID) -> [GridCell]? {
        if color == activeColor { return activePath }
        return solvedPaths[color]
    }
    
    private func isOrthogonallyAdjacent(_ a: GridCell, _ b: GridCell) -> Bool {
        let dr = abs(a.row - b.row)
        let dc = abs(a.col - b.col)
        return (dr == 1 && dc == 0) || (dr == 0 && dc == 1)
    }
}

private struct ConnectDotsBoardView: View {
    let puzzle: ConnectDotsPuzzle
    let solvedPaths: [PathColorID: [GridCell]]
    let activeColor: PathColorID?
    let activePath: [GridCell]
    let onDragChanged: (GridCell) -> Void
    let onDragEnded: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let cellSize = side / CGFloat(puzzle.size)
            let boardRect = CGRect(x: (geo.size.width - side) / 2, y: (geo.size.height - side) / 2, width: side, height: side)
            
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.16, blue: 0.23))
                    .frame(width: side, height: side)
                    .position(x: boardRect.midX, y: boardRect.midY)
                
                // Grid lines
                Path { path in
                    for idx in 0...puzzle.size {
                        let offset = CGFloat(idx) * cellSize
                        let x = boardRect.minX + offset
                        path.move(to: CGPoint(x: x, y: boardRect.minY))
                        path.addLine(to: CGPoint(x: x, y: boardRect.maxY))
                        
                        let y = boardRect.minY + offset
                        path.move(to: CGPoint(x: boardRect.minX, y: y))
                        path.addLine(to: CGPoint(x: boardRect.maxX, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.13), lineWidth: 1)
                
                // Draw paths with rounded joints/caps for a smooth game feel.
                ForEach(puzzle.colors, id: \.self) { color in
                    let pathCells = visiblePath(for: color)
                    if pathCells.count >= 2 {
                        Path { drawPath in
                            guard let first = pathCells.first else { return }
                            drawPath.move(to: center(of: first, cellSize: cellSize, boardRect: boardRect))
                            for cell in pathCells.dropFirst() {
                                drawPath.addLine(to: center(of: cell, cellSize: cellSize, boardRect: boardRect))
                            }
                        }
                        .stroke(
                            color.swiftUIColor.opacity(0.95),
                            style: StrokeStyle(lineWidth: cellSize * 0.44, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
                
                // Endpoints always stay visible on top.
                ForEach(puzzle.colors, id: \.self) { color in
                    ForEach(puzzle.endpoints[color] ?? [], id: \.self) { endpoint in
                        Circle()
                            .fill(color.swiftUIColor)
                            .frame(width: cellSize * 0.58, height: cellSize * 0.58)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.85), lineWidth: 2)
                            )
                            .shadow(color: color.swiftUIColor.opacity(0.4), radius: 6, x: 0, y: 3)
                            .position(center(of: endpoint, cellSize: cellSize, boardRect: boardRect))
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if let cell = cell(at: value.location, boardRect: boardRect, cellSize: cellSize, size: puzzle.size) {
                            onDragChanged(cell)
                        }
                    }
                    .onEnded { _ in
                        onDragEnded()
                    }
            )
        }
    }
    
    private func visiblePath(for color: PathColorID) -> [GridCell] {
        if color == activeColor { return activePath }
        return solvedPaths[color] ?? []
    }
    
    private func center(of cell: GridCell, cellSize: CGFloat, boardRect: CGRect) -> CGPoint {
        CGPoint(
            x: boardRect.minX + (CGFloat(cell.col) + 0.5) * cellSize,
            y: boardRect.minY + (CGFloat(cell.row) + 0.5) * cellSize
        )
    }
    
    private func cell(at location: CGPoint, boardRect: CGRect, cellSize: CGFloat, size: Int) -> GridCell? {
        guard boardRect.contains(location) else { return nil }
        let col = Int((location.x - boardRect.minX) / cellSize)
        let row = Int((location.y - boardRect.minY) / cellSize)
        guard row >= 0, row < size, col >= 0, col < size else { return nil }
        return GridCell(row: row, col: col)
    }
}

struct ConnectDotsPuzzle {
    let size: Int
    let endpoints: [PathColorID: [GridCell]]
    
    var colors: [PathColorID] {
        PathColorID.allCases.filter { endpoints[$0] != nil }
    }
    
    func color(atEndpoint cell: GridCell) -> PathColorID? {
        colors.first { color in
            endpoints[color]?.contains(cell) == true
        }
    }
    
    func oppositeEndpoint(for color: PathColorID, from start: GridCell) -> GridCell? {
        guard let points = endpoints[color], points.count == 2 else { return nil }
        return points.first(where: { $0 != start })
    }
}

struct GridCell: Hashable {
    let row: Int
    let col: Int
}

enum PathColorID: CaseIterable {
    case red
    case green
    case blue
    case purple
    case pink
    case cyan
    case yellow
    
    var swiftUIColor: Color {
        switch self {
        case .red: return Color(red: 0.96, green: 0.34, blue: 0.38)
        case .green: return Color(red: 0.35, green: 0.80, blue: 0.53)
        case .blue: return Color(red: 0.35, green: 0.67, blue: 0.98)
        case .purple: return Color(red: 0.67, green: 0.49, blue: 0.94)
        case .pink: return Color(red: 0.96, green: 0.46, blue: 0.72)
        case .cyan: return Color(red: 0.22, green: 0.78, blue: 0.86)
        case .yellow: return Color(red: 0.96, green: 0.84, blue: 0.25)
        }
    }
}

#Preview {
    NavigationView {
        ConnectDotsView()
    }
}
