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
        // Use recipe parameters
        self.totalTime = TimeInterval(recipe.parameters.totalBrewTimeSeconds)
        self.bloomTime = TimeInterval(recipe.parameters.bloomTimeSeconds)
        
        // Generate steps from recipe
        self.generateSteps(from: recipe)
    }
    
    private func generateSteps(from recipe: Recipe) {
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
            brewSteps.append((time: totalTime, instruction: "Enjoy your coffee!"))
        }
        
        self.brewingSteps = brewSteps.sorted { $0.time < $1.time }
        
        // Set initial step
        if !preparationSteps.isEmpty {
            currentStep = preparationSteps[0]
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
        }
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.elapsedTime < self.totalTime {
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
        let currentIndex = preparationSteps.firstIndex(of: currentStep) ?? 0
        return Double(currentIndex) / Double(preparationSteps.count)
    }
    
    var currentPreparationStepIndex: Int {
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
        return elapsedTime < bloomTime
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
        
        for (index, (time, instruction)) in brewingSteps.enumerated() {
            if elapsedTime >= time {
                currentBrewingStep = instruction
                stepStartTime = time
                
                // Calculate step duration (time until next step or total time)
                if index + 1 < brewingSteps.count {
                    stepDuration = brewingSteps[index + 1].time - time
                } else {
                    stepDuration = totalTime - time
                }
            } else {
                break
            }
        }
        
        currentStep = currentBrewingStep
        currentStepStartTime = stepStartTime
        currentStepDuration = stepDuration
    }
}
