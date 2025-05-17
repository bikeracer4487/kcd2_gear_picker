# Decision Tree for Dice Game AI

## 1. Dice Selection Decision Tree

```
function selectDiceToKeep(currentRoll, bankedPoints):
    # 1. Identify all possible scoring combinations
    scoringCombinations = findAllScoringCombinations(currentRoll)
    
    # 2. Generate all valid ways to group these combinations
    validSelections = generateValidSelections(scoringCombinations)
    
    # 3. Evaluate each selection's expected value
    bestSelection = null
    highestEV = -Infinity
    
    for each selection in validSelections:
        remainingDice = currentRoll - selection
        expectedValue = calculateExpectedValue(selection, remainingDice, bankedPoints)
        
        if expectedValue > highestEV:
            highestEV = expectedValue
            bestSelection = selection
            
    return bestSelection
```

### Key Selection Functions

```
function findAllScoringCombinations(dice):
    combinations = []
    
    # Check for straights
    if containsSequence(dice, 6): # 1-2-3-4-5-6
        combinations.add(Straight6)
    elif containsSequence(dice, [2,3,4,5,6]):
        combinations.add(Straight5_High)
    elif containsSequence(dice, [1,2,3,4,5]):
        combinations.add(Straight5_Low)
        
    # Check for N-of-a-kind (prioritize larger sets)
    for value in [1,2,3,4,5,6]:
        count = countOccurrences(dice, value)
        if count >= 3:
            combinations.add(NOfAKind(value, count))
            
    # Check for individual scoring dice (only if not used in other combinations)
    for each die in dice:
        if die == 1 && notUsedInOtherCombinations(die):
            combinations.add(SingleOne)
        if die == 5 && notUsedInOtherCombinations(die):
            combinations.add(SingleFive)
            
    return combinations
```

## 2. Continue or Stop Decision Tree

```
function decideToRollAgain(currentScore, remainingDice, gameState):
    # If all dice scored, always roll again (no risk)
    if remainingDice.count == 0:
        return ROLL_AGAIN
        
    # Calculate probability of scoring on next roll
    probScoring = calculateProbabilityOfScoring(remainingDice.count)
    
    # Calculate probability of busting
    probBusting = 1 - probScoring
    
    # Calculate expected additional points from another roll
    expectedAdditionalPoints = calculateExpectedPoints(remainingDice.count)
    
    # Calculate expected value of rolling again
    expectedValue = (probScoring * expectedAdditionalPoints) - (probBusting * currentScore)
    
    # Adjust based on game state
    adjustedEV = adjustForGameState(expectedValue, gameState)
    
    if adjustedEV > 0:
        return ROLL_AGAIN
    else:
        return END_TURN
```

### Probability Tables

For optimal decisions, the AI would use pre-calculated probability tables:

```
# Probability of scoring with N dice
SCORING_PROBABILITY = {
    1: 0.333,  # Only 1s and 5s score (2/6)
    2: 0.556,  # 1-(4/6)²
    3: 0.704,  # 1-(4/6)³
    4: 0.802,  # Includes probability of 3-of-a-kind
    5: 0.873,  # Includes straights
    6: 0.916   # High probability of scoring something
}

# Expected points from rolling N dice (simplified)
EXPECTED_POINTS = {
    1: 25,     # (100+50)/6
    2: 65,     # More chances for 1s and 5s
    3: 150,    # Possibility of three-of-a-kind
    4: 280,    # Higher chance of three-of-a-kind
    5: 450,    # Chance of straights/four-of-a-kind
    6: 650     # All possibilities
}
```

## 3. Advanced Considerations

```
function adjustForGameState(expectedValue, gameState):
    # Conservative when close to winning
    if gameState.myScore + currentScore > gameState.targetScore - 500:
        return expectedValue * 0.8
        
    # Take more risks when behind
    if gameState.myScore < gameState.opponentScore - 1000:
        return expectedValue * 1.2
        
    # More conservative with high current score
    if currentScore > 1000:
        return expectedValue * (1 - (currentScore / 10000))
        
    return expectedValue
```

This decision tree could be implemented with reinforcement learning to optimize the probability and expected value tables based on millions of simulated games, leading to increasingly optimal play decisions.