import SwiftUI

struct BrewSetupScreen: View {
    @StateObject private var viewModel = BrewSetupViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Coffee")) {
                    VStack(alignment: .leading) {
                        Text("Dose: \(viewModel.coffeeDose, specifier: "%.1f")g")
                        Slider(value: $viewModel.coffeeDose, in: 10...40, step: 0.5)
                    }
                }
                
                Section(header: Text("Water")) {
                    VStack(alignment: .leading) {
                        Text("Amount: \(viewModel.waterAmount, specifier: "%.0f")ml")
                        Slider(value: $viewModel.waterAmount, in: 100...600, step: 10)
                    }
                    VStack(alignment: .leading) {
                        Text("Temperature: \(viewModel.waterTemperature, specifier: "%.0f")°C")
                        Slider(value: $viewModel.waterTemperature, in: 80...100, step: 1)
                    }
                }

                Section(header: Text("Grind")) {
                    Stepper("Grind Size: \(viewModel.grindSize)", value: $viewModel.grindSize, in: 1...10)
                }

                Section(header: Text("Time")) {
                    Text("Brew Time: \(viewModel.brewTime, specifier: "%.0f")s")
                }
                
                NavigationLink(destination: BrewingGuideScreen(
                    coffeeDose: viewModel.coffeeDose,
                    waterAmount: viewModel.waterAmount,
                    waterTemperature: viewModel.waterTemperature,
                    grindSize: viewModel.grindSize,
                    brewTime: viewModel.brewTime
                )) {
                    Text("Start Brewing")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Brew Setup")
        }
    }
}
