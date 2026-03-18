import Foundation

struct ConnectDotsPuzzleLibrary {
    struct OneBasedPoint {
        let column: Int
        let row: Int
        
        func toZeroBasedCell() -> GridCell {
            GridCell(row: row - 1, col: column - 1)
        }
    }
    
    struct Combination {
        let red: (OneBasedPoint, OneBasedPoint)
        let green: (OneBasedPoint, OneBasedPoint)
        let blue: (OneBasedPoint, OneBasedPoint)
        let purple: (OneBasedPoint, OneBasedPoint)
        let pink: (OneBasedPoint, OneBasedPoint)
        let cyan: (OneBasedPoint, OneBasedPoint)
        let yellow: (OneBasedPoint, OneBasedPoint)
        
        var zeroBasedEndpoints: [PathColorID: [GridCell]] {
            [
                .red: [red.0.toZeroBasedCell(), red.1.toZeroBasedCell()],
                .green: [green.0.toZeroBasedCell(), green.1.toZeroBasedCell()],
                .blue: [blue.0.toZeroBasedCell(), blue.1.toZeroBasedCell()],
                .purple: [purple.0.toZeroBasedCell(), purple.1.toZeroBasedCell()],
                .pink: [pink.0.toZeroBasedCell(), pink.1.toZeroBasedCell()],
                .cyan: [cyan.0.toZeroBasedCell(), cyan.1.toZeroBasedCell()],
                .yellow: [yellow.0.toZeroBasedCell(), yellow.1.toZeroBasedCell()],
            ]
        }
    }
    
    // Paste your manually crafted combinations here.
    // Coordinate format is 1-based (column, row): top-left is (1,1), bottom-right is (8,8).
    static let combinations: [Combination] = [
        Combination(
            red: (p(1, 1), p(5, 2)),
            green: (p(7, 2), p(6, 6)),
            blue: (p(1, 3), p(6, 3)),
            purple: (p(1, 4), p(5, 7)),
            pink: (p(1, 5), p(3, 8)),
            cyan: (p(6, 8), p(8, 6)),
            yellow: (p(7, 5), p(8, 3))
        ),
        Combination(
            red: (p(1, 3), p(2, 2)),
            green: (p(7, 1), p(7, 4)),
            blue: (p(1, 7), p(8, 6)),
            purple: (p(1, 2), p(6, 1)),
            pink: (p(1, 8), p(8, 7)),
            cyan: (p(1, 6), p(8, 5)),
            yellow: (p(1, 4), p(8, 5))
        ),
        Combination(
            red: (p(4, 8), p(8, 6)),
            green: (p(1, 2), p(3, 2)),
            blue: (p(3, 4), p(6, 4)),
            purple: (p(1, 8), p(7, 2)),
            pink: (p(1, 1), p(8, 3)),
            cyan: (p(5, 8), p(8, 8)),
            yellow: (p(2, 8), p(8, 4))
        ),
        Combination(
            red: (p(1, 5), p(8, 3)),
            green: (p(1, 2), p(7, 1)),
            blue: (p(1, 1), p(5, 1)),
            purple: (p(1, 6), p(1, 8)),
            pink: (p(3, 5), p(5, 6)),
            cyan: (p(2, 8), p(8, 8)),
            yellow: (p(1, 4), p(8, 1))
        ),
        Combination(
            red: (p(1, 6), p(6, 5)),
            green: (p(7, 1), p(7, 8)),
            blue: (p(8, 1), p(8, 8)),
            purple: (p(1, 2), p(1, 3)),
            pink: (p(1, 7), p(4, 8)),
            cyan: (p(1, 1), p(3, 4)),
            yellow: (p(5, 8), p(6, 8))
        ),
        Combination(
            red: (p(2, 4), p(4, 5)),
            green: (p(4, 7), p(7, 7)),
            blue: (p(1, 8), p(3, 2)),
            purple: (p(5, 7), p(6, 7)),
            pink: (p(2, 2), p(4, 2)),
            cyan: (p(2, 8), p(6, 3)),
            yellow: (p(4, 3), p(6, 2))
        ),
        Combination(
            red: (p(1, 2), p(2, 2)),
            green: (p(4, 3), p(5, 1)),
            blue: (p(1, 5), p(6, 8)),
            purple: (p(1, 4), p(3, 1)),
            pink: (p(1, 7), p(2, 7)),
            cyan: (p(7, 8), p(8, 1)),
            yellow: (p(6, 1), p(7, 7))
        ),
        Combination(
            red: (p(3, 7), p(3, 8)),
            green: (p(2, 5), p(8, 5)),
            blue: (p(1, 8), p(8, 1)),
            purple: (p(5, 4), p(6, 5)),
            pink: (p(2, 8), p(8, 8)),
            cyan: (p(4, 4), p(5, 5)),
            yellow: (p(3, 3), p(7, 5))
        ),
        Combination(
            red: (p(1, 8), p(3, 3)),
            green: (p(3, 7), p(7, 4)),
            blue: (p(3, 8), p(6, 6)),
            purple: (p(2, 2), p(8, 1)),
            pink: (p(1, 7), p(2, 3)),
            cyan: (p(3, 6), p(4, 5)),
            yellow: (p(1, 3), p(7, 1))
        )
    ]
    
    static func puzzleForToday(date: Date = Date()) -> ConnectDotsPuzzle {
        let index = dailyIndex(for: date)
        return puzzle(at: index)
    }
    
    static func dayKeyForToday(date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    static func dailyIndex(for date: Date, calendar: Calendar = Calendar(identifier: .gregorian)) -> Int {
        let safeCalendar = configured(calendar)
        let referenceDate = safeCalendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? date
        let start = safeCalendar.startOfDay(for: referenceDate)
        let today = safeCalendar.startOfDay(for: date)
        let days = safeCalendar.dateComponents([.day], from: start, to: today).day ?? 0
        return positiveModulo(days, combinations.count)
    }
    
    private static func puzzle(at index: Int) -> ConnectDotsPuzzle {
        guard !combinations.isEmpty else {
            // Fallback impossible in normal use; keeps the app stable if combinations become empty.
            return ConnectDotsPuzzle(size: 8, endpoints: [:])
        }
        let selected = combinations[safeIndex(index)]
        
        return ConnectDotsPuzzle(size: 8, endpoints: selected.zeroBasedEndpoints)
    }
    
    private static func safeIndex(_ index: Int) -> Int {
        positiveModulo(index, combinations.count)
    }
    
    private static func positiveModulo(_ value: Int, _ modulus: Int) -> Int {
        guard modulus > 0 else { return 0 }
        let result = value % modulus
        return result >= 0 ? result : result + modulus
    }
    
    private static func configured(_ calendar: Calendar) -> Calendar {
        var configured = calendar
        configured.timeZone = .current
        return configured
    }
    
    private static func p(_ column: Int, _ row: Int) -> OneBasedPoint {
        precondition((1...8).contains(column) && (1...8).contains(row), "Puzzle point out of 1...8 bounds")
        return OneBasedPoint(column: column, row: row)
    }
}
