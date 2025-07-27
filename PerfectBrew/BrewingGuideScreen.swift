import SwiftUI

struct BrewingGuideScreen: View {
    @StateObject private var viewModel: BrewingGuideViewModel
    
    let coffeeDose: Double
    let waterAmount: Double
    let waterTemperature: Double
    let grindSize: Int
    let brewTime: TimeInterval
    let recipe: Recipe

    init(coffeeDose: Double, waterAmount: Double, waterTemperature: Double, grindSize: Int, brewTime: TimeInterval, recipe: Recipe) {
        self.coffeeDose = coffeeDose
        self.waterAmount = waterAmount
        self.waterTemperature = waterTemperature
        self.grindSize = grindSize
        self.brewTime = brewTime
        self.recipe = recipe
        
        // Initialize view model with recipe
        let viewModel = BrewingGuideViewModel(recipe: recipe)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header - Fixed at top
                VStack(spacing: 4) {
                    Text("Perfect Brew")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Brewing Guide")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)
                .padding(.bottom, 8)
                
                // Main Content - Compact layout
                VStack(spacing: 12) {
                    // Timer Section
                    if viewModel.isPreparationPhase {
                        // Preparation Progress
                        VStack(spacing: 8) {
                            Text("Preparation Progress")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: viewModel.preparationProgress)
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 0.3), value: viewModel.preparationProgress)
                                
                                VStack(spacing: 0) {
                                    Text("\(viewModel.currentPreparationStepIndex + 1)/\(viewModel.preparationSteps.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("steps")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        // Brewing Timers
                        VStack(spacing: 8) {
                            // Total Time Progress
                            VStack(spacing: 6) {
                                Text("Time Remaining")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                                        .frame(width: 80, height: 80)
                                    
                                    Circle()
                                        .trim(from: 0, to: viewModel.totalProgress)
                                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                        .frame(width: 80, height: 80)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.easeInOut(duration: 0.3), value: viewModel.totalProgress)
                                    
                                    VStack(spacing: 0) {
                                        Text("\(Int(viewModel.totalTime - viewModel.elapsedTime))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Text("seconds")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // Step Timer (for current brewing step)
                            if !viewModel.isInBloomPhase && viewModel.currentStepDuration > 0 {
                                VStack(spacing: 6) {
                                    Text("Step Remaining")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                                            .frame(width: 60, height: 60)
                                        
                                        Circle()
                                            .trim(from: 0, to: viewModel.currentStepProgress)
                                            .stroke(Color.purple, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                            .frame(width: 60, height: 60)
                                            .rotationEffect(.degrees(-90))
                                            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStepProgress)
                                        
                                        VStack(spacing: 0) {
                                            Text("\(Int(viewModel.currentStepRemainingTime))")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                            Text("s")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            // Bloom Timer (if applicable)
                            if viewModel.isInBloomPhase {
                                VStack(spacing: 6) {
                                    Text("Bloom Remaining")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                                            .frame(width: 60, height: 60)
                                        
                                        Circle()
                                            .trim(from: 0, to: viewModel.bloomProgress)
                                            .stroke(Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                            .frame(width: 60, height: 60)
                                            .rotationEffect(.degrees(-90))
                                            .animation(.easeInOut(duration: 0.3), value: viewModel.bloomProgress)
                                        
                                        VStack(spacing: 0) {
                                            Text("\(Int(viewModel.bloomTime - viewModel.elapsedTime))")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                            Text("s")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Current Step Section - Compact
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.isPreparationPhase ? "Preparation Step" : "Current Step")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: viewModel.isPreparationPhase ? "checklist" : "cup.and.saucer.fill")
                                .font(.title3)
                                .foregroundColor(viewModel.isPreparationPhase ? .blue : .orange)
                                .frame(width: 20)
                            
                            Text(viewModel.currentStep)
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Control Buttons - Fixed at bottom
                VStack(spacing: 12) {
                    if viewModel.isPreparationPhase {
                        // Preparation phase buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                viewModel.nextPreparationStep()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right")
                                        .font(.headline)
                                    Text("Next Step")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                viewModel.resetPreparation()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.headline)
                                    Text("Reset")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
                            }
                        }
                        
                        Button(action: {
                            viewModel.startTimer()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.headline)
                                Text("Start Brewing")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                    } else {
                        // Brewing phase buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                viewModel.toggleTimer()
                            }) {
                                HStack {
                                    Image(systemName: viewModel.isTimerRunning ? "pause.fill" : "play.fill")
                                        .font(.headline)
                                    Text(viewModel.isTimerRunning ? "Pause" : "Resume")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(viewModel.isTimerRunning ? Color.red : Color.green)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                viewModel.finishBrewing()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .font(.headline)
                                    Text("Finish Brewing")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
    
    // Computed properties for animations
    private var progress: Double {
        let remaining = max(0, viewModel.totalTime - viewModel.elapsedTime)
        return 1 - (remaining / viewModel.totalTime)
    }
    
    private var bloomProgress: Double {
        let remaining = max(0, viewModel.bloomTime - viewModel.elapsedTime)
        return 1 - (remaining / viewModel.bloomTime)
    }
    
    private var preparationProgress: Double {
        guard !viewModel.preparationSteps.isEmpty else { return 0 }
        let currentIndex = viewModel.preparationSteps.firstIndex(of: viewModel.currentStep) ?? 0
        return Double(currentIndex) / Double(viewModel.preparationSteps.count)
    }
    
    private var timeString: String {
        let remaining = max(0, viewModel.totalTime - viewModel.elapsedTime)
        return String(format: "%.0f", remaining)
    }
    
    private var bloomTimeString: String {
        let remaining = max(0, viewModel.bloomTime - viewModel.elapsedTime)
        return String(format: "%.0f", remaining)
    }
}

struct BrewingGuideScreen_Previews: PreviewProvider {
    static var previews: some View {
        BrewingGuideScreen(
            coffeeDose: 15,
            waterAmount: 250,
            waterTemperature: 95,
            grindSize: 5,
            brewTime: 180,
            recipe: Recipe(
                title: "Sample Recipe",
                brewingMethod: "V60",
                skillLevel: "Beginner",
                rating: 4.5,
                parameters: BrewParameters(
                    coffeeGrams: 15,
                    waterGrams: 250,
                    ratio: "1:16.7",
                    grindSize: "Medium-fine",
                    temperatureCelsius: 95,
                    bloomWaterGrams: 30,
                    bloomTimeSeconds: 45,
                    totalBrewTimeSeconds: 180
                ),
                preparationSteps: ["Heat water to 95°C", "Place filter and rinse", "Add 15g coffee"],
                brewingSteps: [
                    BrewingStep(timeSeconds: 0, instruction: "Pour 30g water for bloom"),
                    BrewingStep(timeSeconds: 45, instruction: "Pour to 120g total"),
                    BrewingStep(timeSeconds: 90, instruction: "Pour to 200g total")
                ],
                equipment: ["V60", "Scale", "Kettle"],
                notes: "Sample notes"
            )
        )
    }
}
