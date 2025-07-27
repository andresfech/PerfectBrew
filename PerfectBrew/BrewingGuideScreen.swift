import SwiftUI

struct BrewingGuideScreen: View {
    @StateObject private var viewModel = BrewingGuideViewModel()
    
    let coffeeDose: Double
    let waterAmount: Double
    let waterTemperature: Double
    let grindSize: Int
    let brewTime: TimeInterval

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
                
                // Current Step Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Current Step")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                            
                            Text(viewModel.currentStep)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
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
            brewTime: 180
        )
    }
}
