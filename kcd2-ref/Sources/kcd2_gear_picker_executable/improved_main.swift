import Foundation
import Dispatch
import Atomics

// MARK: - Core Data Structures and Simulation code remains unchanged...

// MARK: - Safe Combination Generation Functions

// Calculate binomial coefficient using an iterative approach with overflow protection
// This computes C(n,k) = n! / (k! * (n-k)!)
func binomialCoefficient(_ n: Int, _ k: Int) -> Int {
    // Handle edge cases
    if k < 0 || k > n {
        return 0
    }
    if k == 0 || k == n {
        return 1
    }
    
    // Use symmetry to minimize number of operations
    let k = min(k, n - k)
    
    // Use a more efficient algorithm that avoids computing factorials
    var result = 1
    for i in 0..<k {
        // Check for potential overflow before performing multiplication
        let nextMultiplier = n - i
        let nextDivisor = i + 1
        
        // Avoid integer overflow with careful ordering of operations
        if result > Int.max / nextMultiplier {
            // Handle overflow by using Double for intermediate calculation
            return Int(Double(result) * Double(nextMultiplier) / Double(nextDivisor))
        }
        
        result = result * nextMultiplier
        
        // Integer division is safe after multiplication
        result /= nextDivisor
    }
    
    return result
}

// Calculate multiset coefficient (n multichoose k) = C(n+k-1,k)
// This is for selecting k items from n types with repetition allowed
func multisetCoefficient(_ n: Int, _ k: Int) -> Int {
    // Handle edge cases
    if n <= 0 || k < 0 {
        return 0
    }
    if k == 0 {
        return 1
    }
    
    // Calculate C(n+k-1,k) for multiset combination count
    return binomialCoefficient(n + k - 1, k)
}

// Calculate the number of combinations with repetition that start with a specific value
// Efficiently implemented using the multisetCoefficient formula
func countCombinationsStartingWith(startVal: Int, remainingPositions: Int, maxVal: Int) -> Int {
    // This calculates how many valid combinations start with the given value
    // We must select (remainingPositions) items from values [startVal...maxVal]
    
    // If we have no more positions to fill, there's exactly 1 way to do it (empty selection)
    if remainingPositions == 0 {
        return 1
    }
    
    // If startVal exceeds maxVal, there are no valid combinations
    if startVal > maxVal {
        return 0
    }
    
    // Calculate multiset coefficient - how many ways to select (remainingPositions) items 
    // from (maxVal-startVal+1) possible values with repetition allowed
    let possibleValues = maxVal - startVal + 1
    return multisetCoefficient(possibleValues, remainingPositions)
}

// Iteratively generate the nth combination without recursion or binary search
// This implementation is fully iterative and handles bounds checking
func generateNthCombination(n: Int, k: Int, maxVal: Int) -> [Int] {
    // Ensure n is within valid range
    let totalCombinations = multisetCoefficient(maxVal + 1, k)
    let safeN = min(max(0, n), totalCombinations - 1)
    
    // Initialize result array with proper capacity
    var combination = [Int](repeating: 0, count: k)
    
    // Iteratively build the combination
    var remainingIndex = safeN
    var currentPosition = 0
    
    while currentPosition < k {
        // Start with the smallest possible value for this position
        // (which is at least the value in the previous position)
        let minValue = currentPosition > 0 ? combination[currentPosition - 1] : 0
        
        // Try each value from minValue to maxVal
        for value in minValue...maxVal {
            // Calculate how many combinations start with this value at this position
            let combinationsWithCurrentValue = countCombinationsStartingWith(
                startVal: value,
                remainingPositions: k - currentPosition - 1,
                maxVal: maxVal
            )
            
            // If remaining combinations count is enough to include our target index
            if remainingIndex < combinationsWithCurrentValue {
                combination[currentPosition] = value
                break
            }
            
            // Otherwise, skip these combinations and adjust the index
            remainingIndex -= combinationsWithCurrentValue
        }
        
        currentPosition += 1
    }
    
    return combination
}

// MARK: - Main Execution

func main() {
    let allDice = parseDice()
    let n = allDice.count  // Number of dice types
    let k = 6  // Number of dice in a combination

    // Calculate total combination count (multiset combination)
    let totalCombinations = multisetCoefficient(n, k)
    
    print("Generating all possible 6-dice combinations from all dice...")
    print("Total combinations to test: \(totalCombinations)")
    print("Simulating 1000 turns for each combination...")

    // Start timing
    startTime = Date()
    lastUpdateTime = startTime

    // Create atomic counter for work distribution
    let nextCombinationIndex = ManagedAtomic<Int>(0)
    let completedCount = ManagedAtomic<Int>(0)
    
    // Results array with proper allocation
    // Use a thread-safe way to grow the results array
    let resultsQueue = DispatchQueue(label: "com.diceSim.resultsQueue")
    let resultsStorage = UnsafeMutablePointer<DiceCombination>.allocate(capacity: totalCombinations)
    
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
        // Thread-local buffer for efficient storage of results
        var localResults: [(index: Int, combination: DiceCombination)] = []
        localResults.reserveCapacity(100)  // Reasonable buffer size
        
        while true {
            // Get next combination index atomically
            let index = nextCombinationIndex.loadThenWrappingIncrement(ordering: .relaxed)
            if index >= totalCombinations {
                break
            }
            
            // Generate the specific combination for this index with bounds checking
            let combo = generateNthCombination(n: index, k: k, maxVal: n-1)
            
            // Simulate performance for this combination
            let avgScore = simulateCombinationPerformance(
                diceIndices: combo, 
                allDice: allDice,
                using: &rng
            )
            
            // Store result locally with its index
            localResults.append((index: index, 
                                 combination: DiceCombination(diceIndices: combo, avgScore: avgScore)))
            
            // Update completed count
            completedCount.wrappingIncrement(ordering: .relaxed)
            
            // Periodically flush results to reduce lock contention
            if localResults.count >= 50 {
                let resultsToFlush = localResults
                resultsQueue.async {
                    // Directly write to specific indices in the pre-allocated array
                    for result in resultsToFlush {
                        // Ensure index is in bounds
                        if result.index >= 0 && result.index < totalCombinations {
                            resultsStorage[result.index] = result.combination
                        }
                    }
                }
                localResults.removeAll(keepingCapacity: true)
            }
        }
        
        // Flush any remaining local results
        if !localResults.isEmpty {
            resultsQueue.async {
                for result in localResults {
                    // Ensure index is in bounds
                    if result.index >= 0 && result.index < totalCombinations {
                        resultsStorage[result.index] = result.combination
                    }
                }
            }
        }
    }
    
    // Cancel the progress timer
    progressTimer.cancel()

    // Clear the progress line
    print("\r\u{1B}[K", terminator: "")
    
    // Convert the raw storage to a Swift array
    var results: [DiceCombination] = []
    results.reserveCapacity(totalCombinations)
    
    resultsQueue.sync {
        // Convert UnsafeMutablePointer to Swift array
        for i in 0..<totalCombinations {
            results.append(resultsStorage[i])
        }
        
        // Free the memory
        resultsStorage.deallocate()
    }
    
    // Sort results by average score in descending order
    results.sort { $0.avgScore > $1.avgScore }

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