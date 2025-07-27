import SwiftUI

struct BrewSetupScreen: View {
    let recipe: Recipe
    @StateObject private var viewModel = BrewSetupViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.brewingMethod)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Difficulty:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(recipe.skillLevel)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(difficultyColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(difficultyColor.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                
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
                    brewTime: viewModel.brewTime,
                    recipe: recipe
                )) {
                    Text("Start Brewing")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Brew Setup")
            .onAppear {
                // Pre-populate with recipe values
                viewModel.coffeeDose = recipe.parameters.coffeeGrams
                viewModel.waterAmount = recipe.parameters.waterGrams
                viewModel.waterTemperature = recipe.parameters.temperatureCelsius
                viewModel.brewTime = Double(recipe.parameters.totalBrewTimeSeconds)
                
                // Convert grind size string to number (approximate)
                viewModel.grindSize = grindSizeToNumber(recipe.parameters.grindSize)
            }
        }
    }
    
    private var difficultyColor: Color {
        switch recipe.skillLevel.lowercased() {
        case "beginner":
            return .green
        case "intermediate":
            return .orange
        case "advanced":
            return .red
        default:
            return .gray
        }
    }
    
    private func grindSizeToNumber(_ grindSize: String) -> Int {
        switch grindSize.lowercased() {
        case "extra fine", "espresso":
            return 1
        case "fine":
            return 2
        case "medium-fine":
            return 3
        case "medium":
            return 5
        case "medium-coarse":
            return 7
        case "coarse":
            return 9
        case "extra coarse":
            return 10
        default:
            return 5
        }
    }
}
