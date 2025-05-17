import Foundation

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

func scoreRoll(_ roll: [Int]) -> Int {
    // First handle the special case of six dice in sequence
    if Set(roll).count == 6 && Set(roll) == Set(1...6) {
        return 1500
    }
    
    // Count occurrences of each value
    var counts = [Int: Int]()
    for die in roll {
        counts[die, default: 0] += 1
    }
    
    // Check for five dice in sequence
    let hasSequence1to5 = [1, 2, 3, 4, 5].allSatisfy { counts[$0, default: 0] >= 1 }
    let hasSequence2to6 = [2, 3, 4, 5, 6].allSatisfy { counts[$0, default: 0] >= 1 }
    
    if hasSequence1to5 || hasSequence2to6 {
        var score = hasSequence1to5 ? 500 : 750
        
        // Temporarily modify the counts to reflect using dice in the sequence
        var tempCounts = counts
        for value in hasSequence1to5 ? 1...5 : 2...6 {
            tempCounts[value]! -= 1
        }
        
        // Score any remaining dice
        for (value, count) in tempCounts {
            if count > 0 {
                if value == 1 {
                    score += count * 100
                } else if value == 5 {
                    score += count * 50
                }
            }
        }
        
        return score
    }
    
    // No straights, score sets and individual dice
    var score = 0
    
    // Score sets of three or more
    for value in 1...6 {
        let count = counts[value, default: 0]
        
        if count >= 3 {
            // Calculate base score
            let baseScore = (value == 1) ? 1000 : value * 100
            
            // Apply scaling for 4, 5, or 6 of a kind
            let multiplier: Int
            switch count {
            case 3: multiplier = 1
            case 4: multiplier = 2
            case 5: multiplier = 4
            case 6: multiplier = 8
            default: multiplier = 0 // Should never happen
            }
            
            score += baseScore * multiplier
            
            // Remove the scored dice
            counts[value] = 0
        }
    }
    
    // Score individual 1s and 5s
    score += counts[1, default: 0] * 100
    score += counts[5, default: 0] * 50
    
    return score
}

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

func simulateDiePerformance(die: Die, numSimulations: Int = 1000, numDice: Int = 6) -> Double {
    var totalScore = 0
    
    for _ in 0..<numSimulations {
        var roll = [Int]()
        for _ in 0..<numDice {
            roll.append(die.roll())
        }
        
        let score = scoreRoll(roll)
        totalScore += score
    }
    
    return Double(totalScore) / Double(numSimulations)
}

func main() {
    let dice = parseDice()
    var diePerformance: [(name: String, avgScore: Double)] = []
    
    for die in dice {
        let avgScore = simulateDiePerformance(die: die)
        diePerformance.append((name: die.name, avgScore: avgScore))
    }
    
    // Sort by average score in descending order
    diePerformance.sort { $0.avgScore > $1.avgScore }
    
    // Print results
    print("Average Scores After 1000 Simulations (6 Dice):")
    print("----------------------------------------------")
    for (index, result) in diePerformance.enumerated() {
        print("\(index + 1). \(result.name): \(Int(result.avgScore.rounded()))")
    }
}

// main() // Removed to prevent issues when not part of an executable target