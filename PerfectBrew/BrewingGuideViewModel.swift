import Foundation
import Combine

class BrewingGuideViewModel: ObservableObject {
    @Published var totalTime: TimeInterval
    @Published var elapsedTime: TimeInterval = 0
    @Published var isTimerRunning = false
    @Published var currentStep = "Prepare"
    @Published var isPreparationPhase = true
    @Published var currentStepStartTime: TimeInterval = 0
    @Published var currentStepDuration: TimeInterval = 0
    @Published var isAudioEnabled = true // Control for auto-play audio
    
    private var timer: AnyCancellable?
    var preparationSteps: [String] = []
    private var brewingSteps: [(time: TimeInterval, instruction: String)] = []
    
    // Audio service for playing step instructions
    let audioService = AudioService()
    private var recipe: Recipe

    init(recipe: Recipe) {
        self.recipe = recipe
        print("DEBUG: BrewingGuideViewModel init with recipe '\(recipe.title)' with \(recipe.parameters.coffeeGrams)g coffee, \(recipe.servings) servings")
        
        // Use recipe parameters
        self.totalTime = TimeInterval(recipe.parameters.totalBrewTimeSeconds)
        
        // Generate steps from recipe
        self.generateSteps(from: recipe)
        
        // Debug: Print initial brewing steps
        print("DEBUG: Initial brewing steps:")
        for (i, step) in brewingSteps.enumerated() {
            print("  Step \(i+1): \(step.time)s - \(step.instruction)")
        }
        
        // Debug: Print step durations calculation
        print("DEBUG: Step durations calculation:")
        for (i, step) in brewingSteps.enumerated() {
            let duration: TimeInterval
            if i == 0 {
                duration = step.time
            } else if i + 1 < brewingSteps.count {
                duration = step.time - brewingSteps[i - 1].time
            } else {
                duration = totalTime - brewingSteps[i - 1].time
            }
            print("  Step \(i+1): duration = \(duration)s (from \(i == 0 ? 0 : brewingSteps[i-1].time)s to \(step.time)s)")
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
            
            // Calculate first step duration correctly
            // First step duration is from 0 to first step time
            currentStepDuration = brewingSteps[0].time
            
            print("DEBUG: Started timer - First step: \(currentStep), Duration: \(currentStepDuration)s")
            print("DEBUG: startTimer - isPreparationPhase: \(isPreparationPhase), currentStepDuration: \(currentStepDuration)")
            print("DEBUG: startTimer - brewingSteps[0].time: \(brewingSteps[0].time), brewingSteps[1].time: \(brewingSteps[1].time)")
            
            // Force update step to ensure proper initialization
            updateStep()
            
            // Auto-play audio for the first step if audio is enabled
            if isAudioEnabled && hasAudioForCurrentStep() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.playCurrentStepAudio()
                }
            }
        }
        
        // Use recipe total time
        print("DEBUG: Using recipe total time: \(totalTime)s")
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.elapsedTime < self.totalTime {
                    self.elapsedTime += 1
                    print("DEBUG: Timer tick - elapsedTime: \(self.elapsedTime)s")
                    self.updateStep()
                } else {
                    print("DEBUG: Timer completed - elapsedTime: \(self.elapsedTime)s, totalTime: \(self.totalTime)s")
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
        // Stop any playing audio
        audioService.stopAudio()
        // Navigate to feedback screen or completion
    }
    
    // MARK: - Audio Functions
    
    func playCurrentStepAudio() {
        guard !isPreparationPhase else { return }
        
        // Find the current brewing step
        let currentStepIndex = getCurrentBrewingStepIndex()
        guard currentStepIndex >= 0 && currentStepIndex < recipe.brewingSteps.count else { return }
        
        let currentBrewingStep = recipe.brewingSteps[currentStepIndex]
        
        // Play audio for the current step
        audioService.playAudio(for: currentBrewingStep, recipeTitle: recipe.title)
    }
    
    func stopAudio() {
        audioService.stopAudio()
    }
    
    private func getCurrentBrewingStepIndex() -> Int {
        // Find which brewing step we're currently in
        for (index, (time, _)) in brewingSteps.enumerated() {
            if elapsedTime < time {
                return index
            }
        }
        return brewingSteps.count - 1
    }
    
    func hasAudioForCurrentStep() -> Bool {
        guard !isPreparationPhase else { return false }
        
        let currentStepIndex = getCurrentBrewingStepIndex()
        guard currentStepIndex >= 0 && currentStepIndex < recipe.brewingSteps.count else { return false }
        
        let currentBrewingStep = recipe.brewingSteps[currentStepIndex]
        return audioService.hasAudio(for: currentBrewingStep)
    }
    
    // MARK: - Audio Control Methods
    
    func toggleAudio() {
        isAudioEnabled.toggle()
        
        // If audio is disabled, stop any currently playing audio
        if !isAudioEnabled {
            audioService.stopAudio()
        }
    }
    
    func pauseAudio() {
        audioService.stopAudio()
    }
    
    func resumeAudio() {
        if isAudioEnabled && hasAudioForCurrentStep() {
            playCurrentStepAudio()
        }
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
        // If brewing is complete, return 1.0 (100%)
        if elapsedTime >= totalTime {
            return 1.0
        }
        return elapsedTime / totalTime
    }
    

    
    // Step timer properties
    var currentStepElapsedTime: TimeInterval {
        // If brewing is complete, return 0
        if elapsedTime >= totalTime {
            return 0
        }
        return elapsedTime - currentStepStartTime
    }
    
    var currentStepRemainingTime: TimeInterval {
        // If brewing is complete, return 0
        if elapsedTime >= totalTime {
            return 0
        }
        return max(0, currentStepDuration - currentStepElapsedTime)
    }
    
    var currentStepProgress: Double {
        // If brewing is complete, return 1.0 (100%)
        if elapsedTime >= totalTime {
            return 1.0
        }
        guard currentStepDuration > 0 else { return 0 }
        return currentStepElapsedTime / currentStepDuration
    }
    
    // MARK: - Time Display Properties
    
    var elapsedTimeFormatted: String {
        let totalSeconds = Int(elapsedTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "\(seconds)s"
        }
    }
    
    var elapsedTimeUnit: String {
        let totalSeconds = Int(elapsedTime)
        let minutes = totalSeconds / 60
        
        if minutes > 0 {
            return "min"
        } else {
            return "seconds"
        }
    }
    

    
    var isBrewingComplete: Bool {
        return elapsedTime >= totalTime
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
        
        // Check if brewing has finished - only show completion when we've truly passed all steps
        if elapsedTime >= totalTime && elapsedTime >= (brewingSteps.last?.time ?? 0) {
            // Brewing is complete, show completion message
            currentBrewingStep = "Enjoy your coffee!"
            stepStartTime = totalTime
            stepDuration = 0  // No remaining time for the step
            currentStepIndex = -1  // Indicates completion
            print("DEBUG: Brewing completed at time \(elapsedTime)s")
            
            // Update the step immediately and return
            currentStep = currentBrewingStep
            currentStepStartTime = stepStartTime
            currentStepDuration = stepDuration
            return
        }
        
        // Find the current step based on absolute timing
        var foundStep = false
        
        print("DEBUG: updateStep - elapsedTime: \(elapsedTime)s, totalTime: \(totalTime)s")
        print("DEBUG: updateStep - brewingSteps count: \(brewingSteps.count)")
        
                // Simplified logic: find the current step based on elapsed time
        for (index, (time, instruction)) in brewingSteps.enumerated() {
            let stepTime = time
            
            // Calculate step duration correctly
            var stepDuration: TimeInterval
            if index == 0 {
                // First step: duration is from 0 to stepTime
                stepDuration = stepTime
            } else if index + 1 < brewingSteps.count {
                // Middle step: duration is from previous step time to current step time
                stepDuration = stepTime - brewingSteps[index - 1].time
            } else {
                // Last step: duration is from previous step time to total time
                stepDuration = totalTime - brewingSteps[index - 1].time
            }
            
            print("DEBUG: Step \(index + 1): time=\(stepTime)s, duration=\(stepDuration)s, instruction=\(instruction)")
            
            // Check if we're in this step
            if index == 0 {
                // First step: check if elapsedTime < stepTime
                if elapsedTime < stepTime {
                    currentBrewingStep = instruction
                    stepStartTime = 0
                    stepDuration = stepTime
                    currentStepIndex = 0
                    foundStep = true
                    print("DEBUG: In first step at time \(elapsedTime)s (duration: \(stepDuration)s)")
                    break
                }
            } else {
                // Other steps: check if elapsedTime is between previous step and current step
                let prevStepTime = brewingSteps[index - 1].time
                if elapsedTime >= prevStepTime && elapsedTime < stepTime {
                    currentBrewingStep = instruction
                    stepStartTime = prevStepTime
                    stepDuration = stepTime - prevStepTime
                    currentStepIndex = index
                    foundStep = true
                    print("DEBUG: In step \(index + 1) at time \(elapsedTime)s (from \(prevStepTime)s to \(stepTime)s, duration: \(stepDuration)s)")
                    break
                }
            }
        }
        
        // If we've passed all steps but haven't reached total time, show the last step
        if !foundStep && !brewingSteps.isEmpty {
            let lastStep = brewingSteps.last!
            let lastStepDuration = totalTime - lastStep.time
            let lastStepEndTime = lastStep.time + lastStepDuration
            
            if elapsedTime >= lastStep.time && elapsedTime < lastStepEndTime {
                // We're in the last step
                currentBrewingStep = lastStep.instruction
                stepStartTime = lastStep.time
                stepDuration = lastStepDuration
                currentStepIndex = brewingSteps.count - 1
                print("DEBUG: In last step at time \(elapsedTime)s (step time: \(lastStep.time)s, duration: \(lastStepDuration)s)")
            } else if elapsedTime >= lastStepEndTime {
                // We've passed the last step, show completion
                currentBrewingStep = "Enjoy your coffee!"
                stepStartTime = totalTime
                stepDuration = 0
                currentStepIndex = -1
                print("DEBUG: Past last step, showing completion")
            }
        }
        
        // Check if we've changed to a new step
        let previousStep = currentStep
        currentStep = currentBrewingStep
        currentStepStartTime = stepStartTime
        currentStepDuration = stepDuration
        
        // Auto-play audio for new brewing steps (if audio is enabled and step changed)
        if !isPreparationPhase && 
           currentStep != previousStep && 
           hasAudioForCurrentStep() && 
           !audioService.isPlaying &&
           isAudioEnabled {
            // Small delay to ensure UI is updated before playing audio
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.playCurrentStepAudio()
            }
        }
        
        // Ensure we have valid step timing even if no step was found
        if !foundStep && !brewingSteps.isEmpty {
            // Default to first step if we haven't found any step yet
            let firstStep = brewingSteps[0]
            currentStep = firstStep.instruction
            currentStepStartTime = 0
            
            // Calculate first step duration correctly
            // First step duration is from 0 to first step time
            currentStepDuration = firstStep.time
            
            currentStepIndex = 0
            print("DEBUG: No step found, defaulting to first step with duration: \(currentStepDuration)s")
        } else if foundStep {
            print("DEBUG: Step found successfully, using calculated values")
        }
        
        // Final safety check - ensure currentStepDuration is never 0 for active steps
        if currentStepDuration == 0 && currentStepIndex >= 0 && !brewingSteps.isEmpty {
            print("DEBUG: WARNING - currentStepDuration is 0, fixing...")
            if currentStepIndex == 0 {
                // First step: duration is from 0 to stepTime
                currentStepDuration = brewingSteps[0].time
            } else if currentStepIndex < brewingSteps.count - 1 {
                // Middle step: duration is from previous step time to current step time
                currentStepDuration = brewingSteps[currentStepIndex].time - brewingSteps[currentStepIndex - 1].time
            } else {
                // Last step: duration is from previous step time to total time
                currentStepDuration = totalTime - brewingSteps[currentStepIndex - 1].time
            }
            print("DEBUG: Fixed currentStepDuration to: \(currentStepDuration)s")
        }
        
        // Additional debug info
        print("DEBUG: UI Check - isPreparationPhase: \(isPreparationPhase), currentStepDuration: \(currentStepDuration)")
        print("DEBUG: UI Check - Step Timer should show: \(!isPreparationPhase && currentStepDuration > 0)")
        
        print("DEBUG: Step update - Elapsed: \(elapsedTime)s, Current step: \(currentStepIndex + 1), Duration: \(currentStepDuration)s, Remaining: \(currentStepRemainingTime)s")
        print("DEBUG: Current step instruction: \(currentBrewingStep)")
        print("DEBUG: isPreparationPhase: \(isPreparationPhase), currentStepDuration: \(currentStepDuration)")
        print("DEBUG: Step Timer should show: \(!isPreparationPhase && currentStepDuration > 0)")
        print("DEBUG: currentStepStartTime: \(currentStepStartTime), currentStepIndex: \(currentStepIndex)")
        print("DEBUG: Final values - stepDuration: \(stepDuration), foundStep: \(foundStep)")
    }
}

