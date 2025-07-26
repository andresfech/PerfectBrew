import Foundation
import Combine

class BrewingGuideViewModel: ObservableObject {
    @Published var totalTime: TimeInterval = 180
    @Published var elapsedTime: TimeInterval = 0
    @Published var bloomTime: TimeInterval = 45
    @Published var isTimerRunning = false
    @Published var currentStep = "Prepare"

    private var timer: AnyCancellable?

    let steps = [
        (time: 0, instruction: "Start"),
        (time: 5, instruction: "Bloom: Pour 50g of water"),
        (time: 45, instruction: "First Pour: Add 100g of water"),
        (time: 90, instruction: "Second Pour: Add 100g of water"),
        (time: 135, instruction: "Final Pour: Add 90g of water"),
        (time: 180, instruction: "Enjoy your coffee!")
    ]

    func startTimer() {
        isTimerRunning = true
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
        currentStep = "Prepare"
    }

    private func updateStep() {
        for (time, instruction) in steps.reversed() {
            if elapsedTime >= TimeInterval(time) {
                currentStep = instruction
                break
            }
        }
    }
}
