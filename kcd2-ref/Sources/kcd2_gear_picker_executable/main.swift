import Foundation
import Dispatch
import Atomics

// MARK: - Core Data Structures

struct Die {
    let name: String
    private let cumulative: [Int]  // Cumulative weights for faster rolling
    let totalWeight: Int
    
    init(name: String, weights: [Int]) {
        self.name = name
        // Precompute cumulative weights for faster rolling
        var sum = 0
        self.cumulative = weights.map { sum += $0; return sum }
        self.totalWeight = sum
    }
    
    // Optimized roll function using thread-local RNG
    @inline(__always)
    func roll<R: RandomNumberGenerator>(using rng: inout R) -> Int {
        let randomValue = Int.random(in: 1...totalWeight, using: &rng)
        
        // Binary search through cumulative weights (much faster for weighted dice)
        var low = 0
        var high = cumulative.count - 1
        
        while low <= high {
            let mid = (low + high) / 2
            if randomValue <= cumulative[mid] {
                if mid == 0 || randomValue > cumulative[mid - 1] {
                    return mid + 1  // Converting from 0-indexed to 1-indexed
                }
                high = mid - 1
            } else {
                low = mid + 1
            }
        }
        
        // Should never reach here if weights are correctly defined
        return 6
    }
}

struct DiceCombination {
    let diceIndices: [Int]  // Indices of dice in the master dice array
    var avgScore: Double = 0.0
    
    func description(dice: [Die]) -> String {
        var counts: [Int: Int] = [:]
        for idx in diceIndices {
            counts[idx, default: 0] += 1
        }
        
        var description = ""
        for (idx, count) in counts.sorted(by: { $0.key < $1.key }) {
            if description.count > 0 {
                description += ", "
            }
            if count > 1 {
                description += "\(count)× \(dice[idx].name)"
            } else {
                description += dice[idx].name
            }
        }
        return description
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

// Find all possible scoring combinations in a roll (optimized to reduce allocations)
func findScoringCombinations(roll: [Int]) -> [ScoringCombination] {
    var combinations: [ScoringCombination] = []
    
    // Check for straights first using a fixed-size array instead of Set
    var seen = [false, false, false, false, false, false, false]  // Index 0 is unused
    var uniqueCount = 0
    
    for die in roll {
        if !seen[die] {
            seen[die] = true
            uniqueCount += 1
        }
    }
    
    if uniqueCount == 6 {
        combinations.append(.straight(type: .full))
        return combinations  // Full straight always best option
    } else if seen[1] && seen[2] && seen[3] && seen[4] && seen[5] {
        combinations.append(.straight(type: .low))
        return combinations  // Low straight is very good
    } else if seen[2] && seen[3] && seen[4] && seen[5] && seen[6] {
        combinations.append(.straight(type: .high))
        return combinations  // High straight is very good
    }
    
    // Count occurrences using a fixed-size array instead of dictionary
    var counts = [0, 0, 0, 0, 0, 0, 0]  // Index 0 is unused
    for die in roll {
        counts[die] += 1
    }
    
    // Check for N-of-a-kind (prioritize larger sets)
    for value in 1...6 {
        let count = counts[value]
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
            
            // Mark these dice as used by zeroing their count
            counts[value] = 0
        }
    }
    
    // Add individual 1s and 5s from remaining counts
    if counts[1] > 0 {
        for _ in 0..<counts[1] {
            combinations.append(.single(value: 1))
        }
    }
    
    if counts[5] > 0 {
        for _ in 0..<counts[5] {
            combinations.append(.single(value: 5))
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

// Decide whether to roll again or bank points (optimized version using inline lookups)
@inline(__always)
func decideToRollAgain(turnScore: Int, remainingDiceCount: Int) -> Bool {
    // If all dice scored, always roll again (no risk)
    if remainingDiceCount == 0 {
        return true
    }
    
    // Get probabilities for given number of dice (inlined for performance)
    let probScoring: Double
    let expectedAdditionalPoints: Double
    
    switch remainingDiceCount {
    case 1: probScoring = 0.333; expectedAdditionalPoints = 25.0
    case 2: probScoring = 0.556; expectedAdditionalPoints = 65.0
    case 3: probScoring = 0.704; expectedAdditionalPoints = 150.0
    case 4: probScoring = 0.802; expectedAdditionalPoints = 280.0
    case 5: probScoring = 0.873; expectedAdditionalPoints = 450.0
    case 6: probScoring = 0.916; expectedAdditionalPoints = 650.0
    default: probScoring = 0.5; expectedAdditionalPoints = 100.0
    }
    
    let probBusting = 1.0 - probScoring
    
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

// Simulate a full turn with a set of dice (optimized with thread-local RNG)
func simulateTurn<R: RandomNumberGenerator>(dice: [Die], using rng: inout R) -> Int {
    var remainingDice = 6
    var turnScore = 0
    let diceIndices = Array(0..<6)  // Start with all 6 dice - changed to constant
    
    // Continue rolling until we bust or decide to stop
    while remainingDice > 0 {
        // Roll the dice using thread-local RNG
        var roll: [Int] = []
        roll.reserveCapacity(remainingDice) // Pre-allocate capacity
        
        for i in 0..<remainingDice {
            let dieIndex = diceIndices[i % diceIndices.count]  // Cycle through available dice
            roll.append(dice[dieIndex].roll(using: &rng))
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

// Simulate performance for a particular dice combination (optimized with thread-local RNG)
func simulateCombinationPerformance<R: RandomNumberGenerator>(diceIndices: [Int], allDice: [Die], numSimulations: Int = 1000, using rng: inout R) -> Double {
    let combinationDice = diceIndices.map { allDice[$0] }
    var totalScore = 0
    
    for _ in 0..<numSimulations {
        let turnScore = simulateTurn(dice: combinationDice, using: &rng)
        totalScore += turnScore
    }
    
    return Double(totalScore) / Double(numSimulations)
}

// Calculate the number of combinations (more efficient than generating them all first)
func binomialCoefficient(_ n: Int, _ k: Int) -> Int {
    if k < 0 || k > n {
        return 0
    }
    if k == 0 || k == n {
        return 1
    }
    
    // Calculate C(n+k-1,k) for multiset combination count (with repetition)
    let n2 = n + k - 1
    let k2 = min(k, n2 - k)
    
    var result = 1
    for i in 0..<k2 {
        result = result * (n2 - i) / (i + 1)
    }
    return result
}

// Generate the nth combination without storing all combinations
func generateNthCombination(n: Int, k: Int, maxVal: Int) -> [Int] {
    var combination = [Int](repeating: 0, count: k)
    var remain = n
    
    for i in 0..<k {
        var low = combination[i == 0 ? 0 : i-1]
        var high = maxVal
        
        while low <= high {
            let mid = (low + high) / 2
            
            // Calculate number of combinations starting with [low..mid]
            let count = stars_and_bars(n: maxVal - mid + k - i - 1, k: k - i - 1)
            
            if remain < count {
                high = mid - 1
            } else {
                remain -= count
                low = mid + 1
            }
        }
        
        combination[i] = low - 1
    }
    
    return combination
}

// Helper for calculating multiset combination count
func stars_and_bars(n: Int, k: Int) -> Int {
    if n < 0 || k < 0 {
        return 0
    }
    if k == 0 {
        return n == 0 ? 1 : 0
    }
    
    var result = 1
    for i in 0..<k {
        result = result * (n - i) / (i + 1)
    }
    return result
}

// MARK: - Progress Tracking

func showProgressUpdate(completed: Int, total: Int) {
    let percentage = Double(completed) / Double(total) * 100.0
    let progressBar = String(repeating: "=", count: Int(percentage / 2)) + String(repeating: " ", count: 50 - Int(percentage / 2))
    let timeRemaining = estimateTimeRemaining(completed: completed, total: total)
    
    // Clear the line and print the new progress
    print("\r\u{1B}[KProgress: [\(progressBar)] \(Int(percentage))% (\(completed)/\(total)) - Est. time remaining: \(timeRemaining)", terminator: "")
    fflush(stdout)
}

// Estimate time remaining based on completed work
var startTime = Date()
var lastUpdateTime = Date()

func estimateTimeRemaining(completed: Int, total: Int) -> String {
    let now = Date()
    let elapsedTime = now.timeIntervalSince(startTime)
    
    if completed == 0 {
        return "calculating..."
    }
    
    let remainingWork = total - completed
    let estimatedSecondsRemaining = (elapsedTime / Double(completed)) * Double(remainingWork)
    
    if estimatedSecondsRemaining < 60 {
        return "\(Int(estimatedSecondsRemaining))s"
    } else if estimatedSecondsRemaining < 3600 {
        return "\(Int(estimatedSecondsRemaining / 60))m \(Int(estimatedSecondsRemaining) % 60)s"
    } else {
        let hours = Int(estimatedSecondsRemaining / 3600)
        let minutes = Int((estimatedSecondsRemaining - Double(hours) * 3600) / 60)
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Main Execution

func main() {
    let allDice = parseDice()
    let n = allDice.count  // Number of dice types
    let k = 6  // Number of dice in a combination

    // Calculate total combination count (multiset combination)
    let totalCombinations = binomialCoefficient(n, k)
    
    print("Generating all possible 6-dice combinations from all dice...")
    print("Total combinations to test: \(totalCombinations)")
    print("Simulating 1000 turns for each combination...")

    // Start timing
    startTime = Date()
    lastUpdateTime = startTime

    // Create atomic counter for work distribution
    let nextCombinationIndex = ManagedAtomic<Int>(0)
    let completedCount = ManagedAtomic<Int>(0)
    
    // Results array and access queue
    var results: [DiceCombination] = []
    results.reserveCapacity(totalCombinations)  // Pre-allocate for better performance
    let resultsQueue = DispatchQueue(label: "com.diceSim.resultsQueue")
    
    // Determine optimal number of threads based on CPU cores
    let processorCount = ProcessInfo.processInfo.processorCount
    let concurrencyLimit = max(1, processorCount - 1) // Leave one core free for system
    print("Using up to \(concurrencyLimit) concurrent tasks...")
    
    // Set up progress reporting timer
    let progressQueue = DispatchQueue(label: "com.diceSim.progressQueue")
    let progressTimer = DispatchSource.makeTimerSource(queue: progressQueue)
    progressTimer.schedule(deadline: .now(), repeating: .seconds(1))
    progressTimer.setEventHandler {
        showProgressUpdate(completed: completedCount.load(ordering: .relaxed), 
                          total: totalCombinations)
    }
    progressTimer.resume()

    // Use DispatchQueue.concurrentPerform for better automatic load balancing
    DispatchQueue.concurrentPerform(iterations: concurrencyLimit) { _ in
        // Thread-local random number generator
        var rng = SystemRandomNumberGenerator()
        var localResults: [DiceCombination] = []
        localResults.reserveCapacity(1000)  // Reasonable buffer for local results
        
        while true {
            // Get next combination index atomically
            let index = nextCombinationIndex.loadThenWrappingIncrement(ordering: .relaxed)
            if index >= totalCombinations {
                break
            }
            
            // Generate the specific combination for this index
            let combo = generateNthCombination(n: index, k: k, maxVal: n-1)
            
            // Simulate performance for this combination
            let avgScore = simulateCombinationPerformance(
                diceIndices: combo, 
                allDice: allDice,
                using: &rng
            )
            
            // Store result locally
            localResults.append(DiceCombination(diceIndices: combo, avgScore: avgScore))
            
            // Update completed count
            completedCount.wrappingIncrement(ordering: .relaxed)
            
            // Periodically flush results to reduce lock contention
            if localResults.count >= 100 {
                let resultsToFlush = localResults
                resultsQueue.async {
                    results.append(contentsOf: resultsToFlush)
                }
                localResults.removeAll(keepingCapacity: true)
            }
        }
        
        // Flush any remaining local results
        if !localResults.isEmpty {
            resultsQueue.async {
                results.append(contentsOf: localResults)
            }
        }
    }
    
    // Cancel the progress timer
    progressTimer.cancel()

    // Clear the progress line
    print("\r\u{1B}[K", terminator: "")

    // Sort results by average score in descending order
    resultsQueue.sync {
        results.sort { $0.avgScore > $1.avgScore }
    }

    // Print the top 50 results
    print("\nTop 50 Dice Combinations:")
    print("----------------------------------------------")
    for (index, result) in results.prefix(50).enumerated() {
        print("\(index + 1). \(result.description(dice: allDice)): \(Int(result.avgScore.rounded()))")
    }

    // Save full results to a file
    let outputFilePath = "dice_combinations_results.txt"
    var fullOutput = "All Dice Combinations Ranked:\n"
    fullOutput += "----------------------------------------------\n"
    for (index, result) in results.enumerated() {
        fullOutput += "\(index + 1). \(result.description(dice: allDice)): \(Int(result.avgScore.rounded()))\n"
    }

    do {
        try fullOutput.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
        print("\nFull results saved to \(outputFilePath)")
    } catch {
        print("\nFailed to save full results: \(error)")
    }
}

main() 