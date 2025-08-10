import Foundation
import Combine

class BrewingGuideViewModel: ObservableObject {
    @Published var totalTime: TimeInterval
    @Published var elapsedTime: TimeInterval = 0
    @Published var bloomTime: TimeInterval
    @Published var isTimerRunning = false
    @Published var currentStep = "Prepare"
    @Published var isPreparationPhase = true
    @Published var currentStepStartTime: TimeInterval = 0
    @Published var currentStepDuration: TimeInterval = 0
    
    private var timer: AnyCancellable?
    var preparationSteps: [String] = []
    private var brewingSteps: [(time: TimeInterval, instruction: String)] = []

    init(recipe: Recipe) {
        print("DEBUG: BrewingGuideViewModel init with recipe '\(recipe.title)' with \(recipe.parameters.coffeeGrams)g coffee, \(recipe.servings) servings")
        
        // Use recipe parameters
        self.totalTime = TimeInterval(recipe.parameters.totalBrewTimeSeconds)
        self.bloomTime = TimeInterval(recipe.parameters.bloomTimeSeconds)
        
        // Generate steps from recipe
        self.generateSteps(from: recipe)
        
        // Debug: Print initial brewing steps
        print("DEBUG: Initial brewing steps:")
        for (i, step) in brewingSteps.enumerated() {
            print("  Step \(i+1): \(step.time)s - \(step.instruction)")
        }
    }
    
    private func generateSteps(from recipe: Recipe) {
        print("DEBUG: generateSteps for recipe '\(recipe.title)' with \(recipe.parameters.coffeeGrams)g coffee")
        print("DEBUG: Preparation steps count: \(recipe.preparationSteps.count)")
        print("DEBUG: First preparation step: \(recipe.preparationSteps.first ?? "none")")
        
        // Use the new structure with separate preparation and brewing steps
        self.preparationSteps = recipe.preparationSteps
        
        // Convert brewing steps to the format we need
        var brewSteps: [(time: TimeInterval, instruction: String)] = []
        
        for brewingStep in recipe.brewingSteps {
            brewSteps.append((
                time: TimeInterval(brewingStep.timeSeconds),
                instruction: brewingStep.instruction
            ))
        }
        
        // Add final step if not present
        if !brewSteps.contains(where: { $0.instruction.contains("Enjoy") || $0.instruction.contains("Finish") }) {
            brewSteps.append((time: 10, instruction: "Enjoy your coffee!"))
        }
        
        // Keep original order - don't sort by time
        self.brewingSteps = brewSteps
        
        // Set initial step
        if !preparationSteps.isEmpty {
            currentStep = preparationSteps[0]
            print("DEBUG: Set initial step: \(currentStep)")
        }
    }

    func startTimer() {
        isTimerRunning = true
        isPreparationPhase = false
        
        // Start with first brewing step
        if !brewingSteps.isEmpty {
            currentStep = brewingSteps[0].instruction
            currentStepStartTime = 0
            currentStepDuration = brewingSteps[0].time
            print("DEBUG: Started timer - First step: \(currentStep), Duration: \(currentStepDuration)s")
        }
        
        // Calculate actual total time from brewing steps
        let actualTotalTime = brewingSteps.reduce(0) { $0 + $1.time }
        print("DEBUG: Actual total time from steps: \(actualTotalTime)s, Recipe total: \(totalTime)s")
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.elapsedTime < actualTotalTime {
                    self.elapsedTime += 1
                    self.updateStep()
                } else {
                    self.stopTimer()
                }
            }
    }

    func stopTimer() {
        isTimerRunning = false
        timer?.cancel()
    }
    
    func resetTimer() {
        stopTimer()
        elapsedTime = 0
        isPreparationPhase = true
        
        // Reset to first preparation step
        if !preparationSteps.isEmpty {
            currentStep = preparationSteps[0]
        }
    }
    
    func resetPreparation() {
        isPreparationPhase = true
        if !preparationSteps.isEmpty {
            currentStep = preparationSteps[0]
        }
    }
    
    func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    func finishBrewing() {
        stopTimer()
        // Navigate to feedback screen or completion
    }
    
    // Computed properties for progress calculations
    var preparationProgress: Double {
        guard !preparationSteps.isEmpty else { return 0 }
        
        // If we're at "Ready to start brewing!" step, show 100% completion
        if currentStep == "Ready to start brewing!" {
            return 1.0
        }
        
        let currentIndex = preparationSteps.firstIndex(of: currentStep) ?? 0
        return Double(currentIndex + 1) / Double(preparationSteps.count)
    }
    
    var currentPreparationStepIndex: Int {
        // If we're at "Ready to start brewing!" step, return the last index
        if currentStep == "Ready to start brewing!" {
            return preparationSteps.count - 1
        }
        return preparationSteps.firstIndex(of: currentStep) ?? 0
    }
    
    var totalProgress: Double {
        return elapsedTime / totalTime
    }
    
    var bloomProgress: Double {
        return elapsedTime / bloomTime
    }
    
    // Step timer properties
    var currentStepElapsedTime: TimeInterval {
        return elapsedTime - currentStepStartTime
    }
    
    var currentStepRemainingTime: TimeInterval {
        return max(0, currentStepDuration - currentStepElapsedTime)
    }
    
    var currentStepProgress: Double {
        guard currentStepDuration > 0 else { return 0 }
        return currentStepElapsedTime / currentStepDuration
    }
    
    var isInBloomPhase: Bool {
        // Only show bloom phase if we're in the first brewing step and it's actually a bloom step
        guard !brewingSteps.isEmpty else { return false }
        let firstStep = brewingSteps[0]
        return elapsedTime < firstStep.time && 
               firstStep.instruction.lowercased().contains("bloom") &&
               bloomTime > 0
    }
    
    func nextPreparationStep() {
        guard isPreparationPhase else { return }
        
        if let currentIndex = preparationSteps.firstIndex(of: currentStep) {
            let nextIndex = currentIndex + 1
            if nextIndex < preparationSteps.count {
                currentStep = preparationSteps[nextIndex]
            } else {
                // All preparation steps completed, ready to start brewing
                currentStep = "Ready to start brewing!"
            }
        }
    }

    private func updateStep() {
        // Find the current brewing step based on elapsed time
        var currentBrewingStep = brewingSteps.first?.instruction ?? "Brewing..."
        var stepStartTime: TimeInterval = 0
        var stepDuration: TimeInterval = 0
        var currentStepIndex = 0
        
        // Calculate cumulative time for each step
        var cumulativeTime: TimeInterval = 0
        
        for (index, (time, instruction)) in brewingSteps.enumerated() {
            let stepEndTime = cumulativeTime + time
            
            if elapsedTime >= cumulativeTime && elapsedTime < stepEndTime {
                // We're in this step
                currentBrewingStep = instruction
                stepStartTime = cumulativeTime
                stepDuration = time
                currentStepIndex = index
                print("DEBUG: Found step \(index + 1) at time \(elapsedTime)s (range: \(cumulativeTime)s to \(stepEndTime)s)")
                break
            }
            
            cumulativeTime = stepEndTime
        }
        
        // If we've passed all steps, show the last step
        if elapsedTime >= cumulativeTime && !brewingSteps.isEmpty && currentStepIndex == 0 {
            // Only show last step if we've actually completed all steps
            let totalStepsTime = brewingSteps.reduce(0) { $0 + $1.time }
            if elapsedTime >= totalStepsTime {
                let lastStep = brewingSteps.last!
                currentBrewingStep = lastStep.instruction
                stepStartTime = cumulativeTime - lastStep.time
                stepDuration = lastStep.time
                currentStepIndex = brewingSteps.count - 1
                print("DEBUG: Reached end, showing last step: \(currentStepIndex + 1)")
            }
        }
        
        currentStep = currentBrewingStep
        currentStepStartTime = stepStartTime
        currentStepDuration = stepDuration
        
        print("DEBUG: Step update - Elapsed: \(elapsedTime)s, Current step: \(currentStepIndex + 1), Duration: \(stepDuration)s, Remaining: \(currentStepRemainingTime)s")
        print("DEBUG: Current step instruction: \(currentBrewingStep)")
        print("DEBUG: isPreparationPhase: \(isPreparationPhase), currentStepDuration: \(currentStepDuration)")
    }
}

