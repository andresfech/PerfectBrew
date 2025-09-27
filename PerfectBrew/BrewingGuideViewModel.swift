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
    @Published var showTotalTimer = false // Toggle between step and total timer
    
    private var timer: AnyCancellable?
    var preparationSteps: [String] = []
    private var brewingSteps: [BrewingStep] = []
    
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
            print("  Step \(i+1): \(step.timeSeconds)s - \(step.instruction)")
        }
        
        // Debug: Print step durations calculation
        print("DEBUG: Step durations calculation:")
        for (i, step) in brewingSteps.enumerated() {
            let duration: TimeInterval
            if i == 0 {
                duration = TimeInterval(step.timeSeconds)
            } else if i + 1 < brewingSteps.count {
                duration = TimeInterval(step.timeSeconds - brewingSteps[i - 1].timeSeconds)
            } else {
                duration = totalTime - TimeInterval(brewingSteps[i - 1].timeSeconds)
            }
            print("  Step \(i+1): duration = \(duration)s (from \(i == 0 ? 0 : brewingSteps[i-1].timeSeconds)s to \(step.timeSeconds)s)")
        }
    }
    
    private func generateSteps(from recipe: Recipe) {
        print("DEBUG: generateSteps for recipe '\(recipe.title)' with \(recipe.parameters.coffeeGrams)g coffee")
        print("DEBUG: Preparation steps count: \(recipe.preparationSteps.count)")
        print("DEBUG: First preparation step: \(recipe.preparationSteps.first ?? "none")")
        
        // Use the new structure with separate preparation and brewing steps
        self.preparationSteps = recipe.preparationSteps
        
        // Keep the original BrewingStep objects to access all properties
        self.brewingSteps = recipe.brewingSteps
        
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
            currentStepDuration = TimeInterval(brewingSteps[0].timeSeconds)
            
            print("DEBUG: Started timer - First step: \(currentStep), Duration: \(currentStepDuration)s")
            print("DEBUG: startTimer - isPreparationPhase: \(isPreparationPhase), currentStepDuration: \(currentStepDuration)")
            print("DEBUG: startTimer - brewingSteps[0].timeSeconds: \(brewingSteps[0].timeSeconds), brewingSteps[1].timeSeconds: \(brewingSteps[1].timeSeconds)")
            
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
        print("DEBUG: playCurrentStepAudio called")
        print("DEBUG: isPreparationPhase: \(isPreparationPhase)")
        
        guard !isPreparationPhase else { 
            print("DEBUG: playCurrentStepAudio - isPreparationPhase is true, returning")
            return 
        }
        
        // Find the current brewing step
        let currentStepIndex = getCurrentBrewingStepIndex()
        print("DEBUG: playCurrentStepAudio - currentStepIndex: \(currentStepIndex)")
        
        // If no current step (completion or before start), don't play audio
        guard currentStepIndex >= 0 && currentStepIndex < recipe.brewingSteps.count else { 
            print("DEBUG: playCurrentStepAudio - no current step (completion or before start), returning")
            return 
        }
        
        let currentBrewingStep = recipe.brewingSteps[currentStepIndex]
        print("DEBUG: playCurrentStepAudio - currentBrewingStep.audioFileName: \(currentBrewingStep.audioFileName ?? "nil")")
        print("DEBUG: playCurrentStepAudio - recipe.title: '\(recipe.title)'")
        
        // Play audio for the current step
        audioService.playAudio(for: currentBrewingStep, recipeTitle: recipe.title)
    }
    
    func stopAudio() {
        audioService.stopAudio()
    }
    
    private func getCurrentBrewingStepIndex() -> Int {
        // Find which brewing step we're currently in
        // Each step's time_seconds represents when that step should start
        var currentStepIndex = -1
        
        for (index, brewingStep) in brewingSteps.enumerated() {
            let stepTime = TimeInterval(brewingStep.timeSeconds)
            
            // If we've reached or passed this step's start time, this is our current step
            if elapsedTime >= stepTime {
                currentStepIndex = index
            } else {
                // If we haven't reached this step yet, we're done
                break
            }
        }
        
        return currentStepIndex
    }
    
    func hasAudioForCurrentStep() -> Bool {
        guard !isPreparationPhase else { 
            print("DEBUG: hasAudioForCurrentStep - isPreparationPhase is true, returning false")
            return false 
        }
        
        let currentStepIndex = getCurrentBrewingStepIndex()
        print("DEBUG: hasAudioForCurrentStep - currentStepIndex: \(currentStepIndex), brewingSteps.count: \(recipe.brewingSteps.count)")
        
        // If no current step (completion or before start), no audio
        guard currentStepIndex >= 0 && currentStepIndex < recipe.brewingSteps.count else { 
            print("DEBUG: hasAudioForCurrentStep - no current step (completion or before start), returning false")
            return false 
        }
        
        let currentBrewingStep = recipe.brewingSteps[currentStepIndex]
        print("DEBUG: hasAudioForCurrentStep - currentBrewingStep.audioFileName: \(currentBrewingStep.audioFileName ?? "nil")")
        
        let result = audioService.hasAudio(for: currentBrewingStep)
        print("DEBUG: hasAudioForCurrentStep - final result: \(result)")
        return result
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
    
    func toggleTimerDisplay() {
        showTotalTimer.toggle()
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
    
    // MARK: - New Timer UI Properties
    
    var totalTimeFormatted: String {
        let totalSeconds = Int(totalTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "\(seconds)s"
        }
    }
    
    var currentStepCountdown: String {
        let remaining = max(0, currentStepDuration - currentStepElapsedTime)
        return "\(Int(remaining))s"
    }
    
    var nextStepPreview: String? {
        guard !isPreparationPhase && !brewingSteps.isEmpty else { return nil }
        
        let currentIndex = getCurrentBrewingStepIndex()
        if currentIndex >= 0 && currentIndex + 1 < brewingSteps.count {
            let nextStep = brewingSteps[currentIndex + 1]
            let nextStepTime = TimeInterval(nextStep.timeSeconds)
            let nextStepTimeFormatted = formatTime(nextStepTime)
            
            // Use short instruction from JSON if available, otherwise fallback to auto-generated
            let shortInstruction = nextStep.shortInstruction ?? createShortInstruction(from: nextStep.instruction)
            return "Next at \(nextStepTimeFormatted): \(shortInstruction)"
        }
        return nil
    }
    
    var currentStepShort: String {
        guard !isPreparationPhase else { return currentStep }
        
        let currentIndex = getCurrentBrewingStepIndex()
        if currentIndex >= 0 && currentIndex < brewingSteps.count {
            let currentBrewingStep = brewingSteps[currentIndex]
            
            // Use short instruction from JSON if available, otherwise fallback to auto-generated
            let shortInstruction = currentBrewingStep.shortInstruction ?? createShortInstruction(from: currentBrewingStep.instruction)
            return shortInstruction
        }
        return currentStep
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        
        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", secs))"
        } else {
            return "\(secs)s"
        }
    }
    
    private func createShortInstruction(from instruction: String) -> String {
        // Convert long instructions to short, imperative commands
        let lowercased = instruction.lowercased()
        
        // Water pouring instructions
        if lowercased.contains("pour") && lowercased.contains("water") {
            if lowercased.contains("50 g") {
                return "Pour 50g water"
            } else if lowercased.contains("100 g") {
                return "Pour 100g water"
            } else if lowercased.contains("94 ml") {
                return "Pour 94ml water"
            } else {
                return "Pour water"
            }
        }
        
        // Bloom and initial steps
        if lowercased.contains("bloom") {
            if lowercased.contains("50 g") {
                return "Bloom 50g • 30s"
            } else {
                return "Bloom coffee"
            }
        }
        
        // Stirring instructions
        if lowercased.contains("stir") {
            if lowercased.contains("north") || lowercased.contains("nsew") {
                return "Stir NSEW pattern"
            } else if lowercased.contains("35 times") {
                return "Stir 35 times"
            } else if lowercased.contains("5 s") || lowercased.contains("5s") {
                return "Stir for 5s"
            } else {
                return "Stir gently"
            }
        }
        
        // Pressing and plunger actions
        if lowercased.contains("press") {
            if lowercased.contains("slow") || lowercased.contains("30") {
                return "Press slowly • 30s"
            } else if lowercased.contains("excess air") {
                return "Press out air"
            } else {
                return "Press plunger"
            }
        }
        
        // Swirling and positioning
        if lowercased.contains("swirl") {
            return "Swirl gently"
        }
        
        if lowercased.contains("place") && lowercased.contains("vessel") {
            return "Place on vessel"
        }
        
        // Cap and filter actions
        if lowercased.contains("cap") {
            if lowercased.contains("screw") {
                return "Screw on cap"
            } else if lowercased.contains("rinse") {
                return "Rinse filter cap"
            } else {
                return "Attach cap"
            }
        }
        
        if lowercased.contains("filter") {
            return "Rinse filter"
        }
        
        // Flipping AeroPress
        if lowercased.contains("flip") {
            return "Flip AeroPress"
        }
        
        // Bypass water additions
        if lowercased.contains("bypass") {
            if lowercased.contains("warm") {
                return "Add warm bypass water"
            } else if lowercased.contains("room") {
                return "Add room temp water"
            } else {
                return "Add bypass water"
            }
        }
        
        // Ice additions
        if lowercased.contains("ice") {
            if lowercased.contains("ball") {
                return "Add ice balls"
            } else {
                return "Add ice"
            }
        }
        
        // Late coffee additions
        if lowercased.contains("late addition") {
            return "Add late coffee"
        }
        
        // Melodrip specific
        if lowercased.contains("melodrip") {
            return "Use Melodrip pour"
        }
        
        // Temperature specific
        if lowercased.contains("96 °c") || lowercased.contains("96°c") {
            return "Pour 96°C water"
        }
        
        if lowercased.contains("89 °c") || lowercased.contains("89°c") {
            return "Pour 89°C water"
        }
        
        if lowercased.contains("92 °c") || lowercased.contains("92°c") {
            return "Pour 92°C water"
        }
        
        // Fallback: create a smart short version
        let firstSentence = instruction.components(separatedBy: ".").first ?? instruction
        let words = firstSentence.components(separatedBy: " ")
        
        // Take key action words (usually first 3-4 words)
        let keyWords = Array(words.prefix(4))
        let shortVersion = keyWords.joined(separator: " ")
        
        // Ensure it's not too long
        if shortVersion.count > 25 {
            return String(shortVersion.prefix(25)) + "..."
        }
        
        return shortVersion
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
        if elapsedTime >= totalTime && elapsedTime >= (TimeInterval(brewingSteps.last?.timeSeconds ?? 0)) {
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
        
                // Use the same logic as getCurrentBrewingStepIndex for consistency
        let currentIndex = getCurrentBrewingStepIndex()
        
        if currentIndex >= 0 && currentIndex < brewingSteps.count {
            let currentBrewingStepData = brewingSteps[currentIndex]
            currentBrewingStep = currentBrewingStepData.instruction
            currentStepIndex = currentIndex
            
            // Calculate step timing
            let stepTime = TimeInterval(currentBrewingStepData.timeSeconds)
            stepStartTime = stepTime
            
            // Calculate step duration: from current step start to next step start
            if currentIndex + 1 < brewingSteps.count {
                let nextStepTime = TimeInterval(brewingSteps[currentIndex + 1].timeSeconds)
                stepDuration = nextStepTime - stepTime
            } else {
                // Last step: duration until total time
                stepDuration = totalTime - stepTime
            }
            
            foundStep = true
            print("DEBUG: Using getCurrentBrewingStepIndex - currentIndex: \(currentIndex), instruction: \(currentBrewingStep)")
        }
        
        // If we've passed all steps but haven't reached total time, show the last step
        if !foundStep && !brewingSteps.isEmpty {
            let lastStep = brewingSteps.last!
            let lastStepDuration = totalTime - TimeInterval(lastStep.timeSeconds)
            let lastStepEndTime = TimeInterval(lastStep.timeSeconds) + lastStepDuration
            
            if elapsedTime >= TimeInterval(lastStep.timeSeconds) && elapsedTime < lastStepEndTime {
                // We're in the last step
                currentBrewingStep = lastStep.instruction
                stepStartTime = TimeInterval(lastStep.timeSeconds)
                stepDuration = lastStepDuration
                currentStepIndex = brewingSteps.count - 1
                print("DEBUG: In last step at time \(elapsedTime)s (step time: \(TimeInterval(lastStep.timeSeconds))s, duration: \(lastStepDuration)s)")
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
            
            print("DEBUG: Auto-play conditions met:")
            print("DEBUG: - !isPreparationPhase: \(!isPreparationPhase)")
            print("DEBUG: - currentStep != previousStep: \(currentStep != previousStep)")
            print("DEBUG: - hasAudioForCurrentStep(): \(hasAudioForCurrentStep())")
            print("DEBUG: - !audioService.isPlaying: \(!audioService.isPlaying)")
            print("DEBUG: - isAudioEnabled: \(isAudioEnabled)")
            print("DEBUG: - Current step: '\(currentStep)'")
            print("DEBUG: - Previous step: '\(previousStep)'")
            print("DEBUG: - Current step index: \(currentStepIndex)")
            
            // Small delay to ensure UI is updated before playing audio
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("DEBUG: Executing auto-play for step \(currentStepIndex + 1)")
                self.playCurrentStepAudio()
            }
        } else {
            print("DEBUG: Auto-play conditions NOT met:")
            print("DEBUG: - !isPreparationPhase: \(!isPreparationPhase)")
            print("DEBUG: - currentStep != previousStep: \(currentStep != previousStep)")
            print("DEBUG: - hasAudioForCurrentStep(): \(hasAudioForCurrentStep())")
            print("DEBUG: - !audioService.isPlaying: \(!audioService.isPlaying)")
            print("DEBUG: - isAudioEnabled: \(isAudioEnabled)")
        }
        
        // Ensure we have valid step timing even if no step was found
        if !foundStep && !brewingSteps.isEmpty {
            // Default to first step if we haven't found any step yet
            let firstStep = brewingSteps[0]
            currentStep = firstStep.instruction
            currentStepStartTime = 0
            
            // Calculate first step duration correctly
            // First step duration is from 0 to first step time
            currentStepDuration = TimeInterval(firstStep.timeSeconds)
            
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
                currentStepDuration = TimeInterval(brewingSteps[0].timeSeconds)
            } else if currentStepIndex < brewingSteps.count - 1 {
                // Middle step: duration is from previous step time to current step time
                currentStepDuration = TimeInterval(brewingSteps[currentStepIndex].timeSeconds - brewingSteps[currentStepIndex - 1].timeSeconds)
            } else {
                // Last step: duration is from previous step time to total time
                currentStepDuration = totalTime - TimeInterval(brewingSteps[currentStepIndex - 1].timeSeconds)
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

