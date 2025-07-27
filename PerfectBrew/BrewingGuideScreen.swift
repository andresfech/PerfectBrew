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
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("Perfect Brew")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Brewing Guide")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Main Timer Section
                VStack(spacing: 24) {
                    if viewModel.isPreparationPhase {
                        // Preparation Progress
                        VStack(spacing: 16) {
                            Text("Preparation Progress")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            ZStack {
                                // Background circle
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                                    .frame(width: 200, height: 200)
                                
                                // Progress circle
                                Circle()
                                    .trim(from: 0, to: preparationProgress)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.blue, .cyan]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                    )
                                    .frame(width: 200, height: 200)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 1), value: preparationProgress)
                                
                                // Progress display
                                VStack(spacing: 4) {
                                    Text("\(viewModel.preparationSteps.firstIndex(of: viewModel.currentStep) ?? 0 + 1)/\(viewModel.preparationSteps.count)")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("steps")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        // Total Time Progress
                        VStack(spacing: 16) {
                            Text("Time Remaining")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            ZStack {
                                // Background circle
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                                    .frame(width: 200, height: 200)
                                
                                // Progress circle
                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.orange, .red]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                    )
                                    .frame(width: 200, height: 200)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 1), value: progress)
                                
                                // Time display
                                VStack(spacing: 4) {
                                    Text(timeString)
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("seconds")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Bloom Timer (if applicable)
                        if viewModel.elapsedTime < viewModel.bloomTime {
                            VStack(spacing: 16) {
                                Text("Bloom Remaining")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                ZStack {
                                    // Background circle
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                        .frame(width: 120, height: 120)
                                    
                                    // Progress circle
                                    Circle()
                                        .trim(from: 0, to: bloomProgress)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.green, .blue]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                        )
                                        .frame(width: 120, height: 120)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.easeInOut(duration: 1), value: bloomProgress)
                                    
                                    // Time display
                                    VStack(spacing: 2) {
                                        Text(bloomTimeString)
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text("seconds")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Current Step Section
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.isPreparationPhase ? "Preparation Step" : "Current Step")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            Image(systemName: viewModel.isPreparationPhase ? "checklist" : "cup.and.saucer.fill")
                                .font(.title2)
                                .foregroundColor(viewModel.isPreparationPhase ? .blue : .orange)
                                .frame(width: 30)
                            
                            Text(viewModel.currentStep)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Control Buttons
                VStack(spacing: 16) {
                    if viewModel.isPreparationPhase {
                        // Preparation phase buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                viewModel.nextPreparationStep()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right")
                                        .font(.title3)
                                    Text("Next Step")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                viewModel.resetTimer()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.title3)
                                    Text("Reset")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Start Brewing button (only when ready)
                        if viewModel.currentStep == "Ready to start brewing!" {
                            Button(action: {
                                viewModel.startTimer()
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                        .font(.title3)
                                    Text("Start Brewing")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                            }
                        }
                    } else {
                        // Brewing phase buttons
                        if !viewModel.isTimerRunning {
                            HStack(spacing: 16) {
                                Button(action: {
                                    viewModel.startTimer()
                                }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                            .font(.title3)
                                        Text("Start Brewing")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    viewModel.resetTimer()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.title3)
                                        Text("Reset")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                }
                            }
                        } else {
                            Button(action: {
                                viewModel.stopTimer()
                            }) {
                                HStack {
                                    Image(systemName: "pause.fill")
                                        .font(.title3)
                                    Text("Pause")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Finish Brewing Button
                    NavigationLink(destination: FeedbackScreen(
                        coffeeDose: coffeeDose,
                        waterAmount: waterAmount,
                        waterTemperature: waterTemperature,
                        grindSize: grindSize,
                        brewTime: brewTime
                    )) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("Finish Brewing")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
        .onDisappear {
            viewModel.stopTimer()
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
