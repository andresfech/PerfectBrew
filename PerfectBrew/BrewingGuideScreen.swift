import SwiftUI

struct BrewingGuideScreen: View {
    @StateObject private var viewModel = BrewingGuideViewModel()
    
    let coffeeDose: Double
    let waterAmount: Double
    let waterTemperature: Double
    let grindSize: Int
    let brewTime: TimeInterval

    var body: some View {
        VStack {
            Text("Time Remaining")
                .font(.headline)
            Text(String(format: "%.0f", viewModel.totalTime - viewModel.elapsedTime))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Bloom Remaining")
                .font(.headline)
            Text(String(format: "%.0f", max(0, viewModel.bloomTime - viewModel.elapsedTime)))
                .font(.title2)
                .padding(.bottom)

            Text("Current Step:")
                .font(.headline)
            Text(viewModel.currentStep)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()

            HStack {
                if !viewModel.isTimerRunning {
                    Button(action: {
                        viewModel.startTimer()
                    }) {
                        Text("Start")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        viewModel.resetTimer()
                    }) {
                        Text("Reset")
                            .font(.title)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        viewModel.stopTimer()
                    }) {
                        Text("Pause")
                            .font(.title)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            
            Spacer()

            NavigationLink(destination: FeedbackScreen(
                coffeeDose: coffeeDose,
                waterAmount: waterAmount,
                waterTemperature: waterTemperature,
                grindSize: grindSize,
                brewTime: brewTime
            )) {
                Text("Finish Brewing")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Brewing Guide")
        .onDisappear {
            viewModel.stopTimer()
        }
    }
}
