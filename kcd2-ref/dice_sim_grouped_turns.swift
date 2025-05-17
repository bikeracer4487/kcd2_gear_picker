import Foundation

// MARK: - Core Data Structures

struct Die {
    let name: String
    let weights: [Int]  // Weights for sides 1-6
    let totalWeight: Int
    
    init(name: String, weights: [Int]) {
        self.name = name
        self.weights = weights
        self.totalWeight = weights.reduce(0, +)
    }
    
    func roll() -> Int {
        let randomValue = Int.random(in: 1...totalWeight)
        var cumulativeWeight = 0
        
        for (index, weight) in weights.enumerated() {
            cumulativeWeight += weight
            if randomValue <= cumulativeWeight {
                return index + 1  // Converting from 0-indexed to 1-indexed
            }
        }
        
        // Should never reach here if weights are correctly defined
        return 6
    }
}

// Represents a scoring combination of dice
enum ScoringCombination: Equatable {
    case single(value: Int)
    case threeOfAKind(value: Int)
    case fourOfAKind(value: Int)
    case fiveOfAKind(value: Int)
    case sixOfAKind(value: Int)
    case straight(type: StraightType)
    
    enum StraightType {
        case low   // 1-2-3-4-5
        case high  // 2-3-4-5-6
        case full  // 1-2-3-4-5-6
    }
    
    var score: Int {
        switch self {
        case .single(let value):
            return value == 1 ? 100 : (value == 5 ? 50 : 0)
            
        case .threeOfAKind(let value):
            return value == 1 ? 1000 : value * 100
            
        case .fourOfAKind(let value):
            return 2 * (value == 1 ? 1000 : value * 100)
            
        case .fiveOfAKind(let value):
            return 4 * (value == 1 ? 1000 : value * 100)
            
        case .sixOfAKind(let value):
            return 8 * (value == 1 ? 1000 : value * 100)
            
        case .straight(let type):
            switch type {
            case .low: return 500
            case .high: return 750
            case .full: return 1500
            }
        }
    }
    
    var diceUsed: [Int] {
        switch self {
        case .single(let value):
            return [value]
            
        case .threeOfAKind(let value):
            return Array(repeating: value, count: 3)
            
        case .fourOfAKind(let value):
            return Array(repeating: value, count: 4)
            
        case .fiveOfAKind(let value):
            return Array(repeating: value, count: 5)
            
        case .sixOfAKind(let value):
            return Array(repeating: value, count: 6)
            
        case .straight(let type):
            switch type {
            case .low: return [1, 2, 3, 4, 5]
            case .high: return [2, 3, 4, 5, 6]
            case .full: return [1, 2, 3, 4, 5, 6]
            }
        }
    }
}

// Represents a selection of dice to keep after a roll
struct DiceSelection {
    let combinations: [ScoringCombination]
    let indices: [Int]  // Indices of the selected dice in the original roll
    
    var score: Int {
        combinations.reduce(0) { $0 + $1.score }
    }
}

// MARK: - Decision-Making and Probability Tables

// Probability of scoring with N dice
let SCORING_PROBABILITY: [Int: Double] = [
    1: 0.333,  // Only 1s and 5s score (2/6)
    2: 0.556,  // 1-(4/6)²
    3: 0.704,  // 1-(4/6)³
    4: 0.802,  // Includes probability of 3-of-a-kind
    5: 0.873,  // Includes straights
    6: 0.916   // High probability of scoring something
]

// Expected points from rolling N dice (simplified)
let EXPECTED_POINTS: [Int: Double] = [
    1: 25.0,    // (100+50)/6
    2: 65.0,    // More chances for 1s and 5s
    3: 150.0,   // Possibility of three-of-a-kind
    4: 280.0,   // Higher chance of three-of-a-kind
    5: 450.0,   // Chance of straights/four-of-a-kind
    6: 650.0    // All possibilities
]

// MARK: - Scoring and Dice Selection Functions

// Find all possible scoring combinations in a roll
func findScoringCombinations(roll: [Int]) -> [ScoringCombination] {
    var combinations: [ScoringCombination] = []
    var availableDice = roll.sorted()
    
    // Check for straights first
    let uniqueDice = Set(roll)
    if uniqueDice.count == 6 && uniqueDice == Set(1...6) {
        combinations.append(.straight(type: .full))
        return combinations  // Full straight always best option, no need to check others
    } else if uniqueDice.isSuperset(of: [1, 2, 3, 4, 5]) {
        combinations.append(.straight(type: .low))
        return combinations  // Low straight is very good, take it
    } else if uniqueDice.isSuperset(of: [2, 3, 4, 5, 6]) {
        combinations.append(.straight(type: .high))
        return combinations  // High straight is very good, take it
    }
    
    // Count occurrences of each value
    var counts: [Int: Int] = [:]
    for die in roll {
        counts[die, default: 0] += 1
    }
    
    // Check for N-of-a-kind (prioritize larger sets)
    for value in 1...6 {
        let count = counts[value, default: 0]
        if count >= 3 {
            switch count {
            case 6:
                combinations.append(.sixOfAKind(value: value))
            case 5:
                combinations.append(.fiveOfAKind(value: value))
            case 4:
                combinations.append(.fourOfAKind(value: value))
            case 3:
                combinations.append(.threeOfAKind(value: value))
            default:
                break
            }
            
            // Remove this value from available dice after adding the combination
            availableDice.removeAll { $0 == value }
        }
    }
    
    // Add individual 1s and 5s from remaining dice
    for die in availableDice {
        if die == 1 || die == 5 {
            combinations.append(.single(value: die))
        }
    }
    
    return combinations
}

// Select the best scoring option from a roll
func selectBestScoringOption(roll: [Int], turnScore: Int) -> DiceSelection? {
    let combinations = findScoringCombinations(roll: roll)
    if combinations.isEmpty {
        return nil  // No scoring options, busted
    }
    
    // For this simulation, we'll use a simplified approach:
    // 1. If we have a straight, take it
    // 2. If we have N-of-a-kind, take the highest scoring one
    // 3. If we only have singles, take them all
    
    // Handle straights
    if let straightIndex = combinations.firstIndex(where: { 
        if case .straight = $0 { return true } else { return false }
    }) {
        return DiceSelection(combinations: [combinations[straightIndex]], 
                             indices: getStraightIndices(type: combinations[straightIndex], roll: roll))
    }
    
    // Handle sets of 3 or more
    let setOfAKind = combinations.filter { 
        if case .threeOfAKind = $0 { return true }
        if case .fourOfAKind = $0 { return true }
        if case .fiveOfAKind = $0 { return true }
        if case .sixOfAKind = $0 { return true }
        return false 
    }.sorted { $0.score > $1.score }
    
    if !setOfAKind.isEmpty {
        // Take the highest scoring set
        let bestSet = setOfAKind[0]
        
        // Find indices for this set
        let indices = getIndicesForCombination(bestSet, in: roll)
        
        // Also take any 1s and 5s that aren't part of the set
        var additionalIndices: [Int] = []
        var additionalCombinations: [ScoringCombination] = []
        
        for (index, value) in roll.enumerated() {
            if !indices.contains(index) && (value == 1 || value == 5) {
                additionalIndices.append(index)
                additionalCombinations.append(.single(value: value))
            }
        }
        
        return DiceSelection(
            combinations: [bestSet] + additionalCombinations,
            indices: indices + additionalIndices
        )
    }
    
    // If only singles, take all of them
    let singles = combinations.filter {
        if case .single = $0 { return true } else { return false }
    }
    
    if !singles.isEmpty {
        var indices: [Int] = []
        for combination in singles {
            if case .single(let value) = combination {
                if let index = roll.firstIndex(of: value), !indices.contains(index) {
                    indices.append(index)
                }
            }
        }
        return DiceSelection(combinations: singles, indices: indices)
    }
    
    // Shouldn't reach here if we have scoring combinations
    return nil
}

// Helper function to get indices for a straight
func getStraightIndices(type: ScoringCombination, roll: [Int]) -> [Int] {
    var indices: [Int] = []
    var neededValues: [Int] = []
    
    if case .straight(let straightType) = type {
        switch straightType {
        case .low:
            neededValues = [1, 2, 3, 4, 5]
        case .high:
            neededValues = [2, 3, 4, 5, 6]
        case .full:
            neededValues = [1, 2, 3, 4, 5, 6]
        }
    }
    
    for value in neededValues {
        if let index = roll.firstIndex(of: value), !indices.contains(index) {
            indices.append(index)
        }
    }
    
    return indices
}

// Helper function to get indices for a combination in a roll
func getIndicesForCombination(_ combination: ScoringCombination, in roll: [Int]) -> [Int] {
    var indices: [Int] = []
    var neededValue: Int = 0
    var count: Int = 0
    
    switch combination {
    case .single(let value):
        neededValue = value
        count = 1
    case .threeOfAKind(let value):
        neededValue = value
        count = 3
    case .fourOfAKind(let value):
        neededValue = value
        count = 4
    case .fiveOfAKind(let value):
        neededValue = value
        count = 5
    case .sixOfAKind(let value):
        neededValue = value
        count = 6
    case .straight:
        // Handled in separate function
        return []
    }
    
    for (index, value) in roll.enumerated() {
        if value == neededValue && !indices.contains(index) && indices.count < count {
            indices.append(index)
        }
    }
    
    return indices
}

// Decide whether to roll again or bank points
func decideToRollAgain(turnScore: Int, remainingDiceCount: Int) -> Bool {
    // If all dice scored, always roll again (no risk)
    if remainingDiceCount == 0 {
        return true
    }
    
    // Get probabilities for given number of dice
    let probScoring = SCORING_PROBABILITY[remainingDiceCount, default: 0.5]
    let probBusting = 1.0 - probScoring
    let expectedAdditionalPoints = EXPECTED_POINTS[remainingDiceCount, default: 100.0]
    
    // Calculate expected value
    let expectedValue = (probScoring * expectedAdditionalPoints) - (probBusting * Double(turnScore))
    
    // Conservative adjustment when turn score is high
    let adjustedEV = turnScore > 500 ? expectedValue * (1.0 - (Double(turnScore) / 12000.0)) : expectedValue
    
    return adjustedEV > 0
}

// MARK: - Dice Game Simulation

func parseDice() -> [Die] {
    var dice: [Die] = []
    
    // Directly hardcoding the dice from the provided markdown file
    dice.append(Die(name: "Aranka's die", weights: [6, 1, 6, 1, 6, 1]))
    dice.append(Die(name: "Cautious cheater's die", weights: [5, 3, 2, 3, 5, 3]))
    dice.append(Die(name: "Ci die", weights: [3, 3, 3, 3, 3, 6]))
    dice.append(Die(name: "Devil's head die", weights: [1, 1, 1, 1, 1, 1]))
    dice.append(Die(name: "Die of misfortune", weights: [1, 5, 5, 5, 5, 1]))
    dice.append(Die(name: "Even die", weights: [2, 8, 2, 8, 2, 8]))
    dice.append(Die(name: "Favourable die", weights: [6, 0, 1, 1, 6, 4]))
    dice.append(Die(name: "Fer die", weights: [3, 3, 3, 3, 3, 5]))
    dice.append(Die(name: "Greasy die", weights: [3, 2, 3, 2, 3, 4]))
    dice.append(Die(name: "Grimy die", weights: [1, 5, 1, 1, 7, 1]))
    dice.append(Die(name: "Grozav's lucky die", weights: [1, 10, 1, 1, 1, 1]))
    dice.append(Die(name: "Heavenly Kingdom die", weights: [7, 2, 2, 2, 2, 4]))
    dice.append(Die(name: "Holy Trinity die", weights: [4, 5, 7, 1, 1, 1]))
    dice.append(Die(name: "Hugo's Die", weights: [1, 1, 1, 1, 1, 1]))
    dice.append(Die(name: "King's die", weights: [4, 6, 7, 8, 4, 3]))
    dice.append(Die(name: "Lousy gambler's die", weights: [2, 3, 2, 3, 7, 3]))
    dice.append(Die(name: "Lu die", weights: [3, 3, 3, 3, 3, 6]))
    dice.append(Die(name: "Lucky Die", weights: [6, 1, 2, 3, 4, 6]))
    dice.append(Die(name: "Mathematician's Die", weights: [4, 5, 6, 7, 1, 1]))
    dice.append(Die(name: "Molar die", weights: [1, 1, 1, 1, 1, 1]))
    dice.append(Die(name: "Odd die", weights: [8, 2, 8, 2, 8, 2]))
    dice.append(Die(name: "Ordinary die", weights: [1, 1, 1, 1, 1, 1]))
    dice.append(Die(name: "Painted die", weights: [3, 1, 1, 1, 6, 3]))
    dice.append(Die(name: "Pie die", weights: [6, 1, 3, 3, 0, 0]))
    dice.append(Die(name: "Premolar die", weights: [1, 1, 1, 1, 1, 1]))
    dice.append(Die(name: "Sad Greaser's Die", weights: [6, 6, 1, 1, 6, 3]))
    dice.append(Die(name: "Saint Antiochus' die", weights: [3, 1, 5, 1, 2, 3]))
    dice.append(Die(name: "Shrinking die", weights: [2, 1, 1, 1, 1, 3]))
    dice.append(Die(name: "St. Stephen's die", weights: [1, 1, 1, 1, 1, 1]))
    dice.append(Die(name: "Strip die", weights: [4, 2, 2, 2, 3, 3]))
    dice.append(Die(name: "Three die", weights: [2, 1, 4, 1, 2, 1]))
    dice.append(Die(name: "Unbalanced Die", weights: [3, 4, 1, 1, 2, 1]))
    dice.append(Die(name: "Unlucky die", weights: [1, 3, 2, 2, 2, 1]))
    dice.append(Die(name: "Wagoner's Die", weights: [1, 5, 6, 2, 2, 2]))
    dice.append(Die(name: "Weighted die", weights: [10, 1, 1, 1, 1, 1]))
    dice.append(Die(name: "Wisdom tooth die", weights: [1, 1, 1, 1, 1, 1]))
    
    return dice
}

// Simulate a full turn with a set of dice
func simulateTurn(die: Die) -> Int {
    var remainingDice = 6
    var turnScore = 0
    
    // Continue rolling until we bust or decide to stop
    while remainingDice > 0 {
        // Roll the dice
        var roll: [Int] = []
        for _ in 0..<remainingDice {
            roll.append(die.roll())
        }
        
        // Find scoring options
        guard let selection = selectBestScoringOption(roll: roll, turnScore: turnScore) else {
            // Busted - no scoring combinations
            return 0
        }
        
        // Add to turn score
        turnScore += selection.score
        
        // Determine number of dice remaining
        remainingDice -= selection.indices.count
        
        // If all dice have been used, get 6 new dice
        if remainingDice == 0 {
            remainingDice = 6
        }
        
        // Decide whether to roll again
        if !decideToRollAgain(turnScore: turnScore, remainingDiceCount: remainingDice) {
            return turnScore
        }
    }
    
    return turnScore
}

// Simulate performance for a particular die
func simulateDiePerformance(die: Die, numSimulations: Int = 1000) -> Double {
    var totalScore = 0
    
    for _ in 0..<numSimulations {
        let turnScore = simulateTurn(die: die)
        totalScore += turnScore
    }
    
    return Double(totalScore) / Double(numSimulations)
}

// MARK: - Main Execution

func main() {
    let dice = parseDice()
    var diePerformance: [(name: String, avgScore: Double)] = []
    
    for die in dice {
        print("Simulating 1000 turns with \(die.name)...")
        let avgScore = simulateDiePerformance(die: die)
        diePerformance.append((name: die.name, avgScore: avgScore))
    }
    
    // Sort by average score in descending order
    diePerformance.sort { $0.avgScore > $1.avgScore }
    
    // Print results
    print("\nAverage Scores After 1000 Turns:")
    print("----------------------------------------------")
    for (index, result) in diePerformance.enumerated() {
        print("\(index + 1). \(result.name): \(Int(result.avgScore.rounded()))")
    }
}

// main() // Removed to prevent issues when not part of an executable target