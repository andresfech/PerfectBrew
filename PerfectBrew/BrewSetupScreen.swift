import SwiftUI
import Lottie

struct BrewSetupScreen: View {
    let recipe: Recipe
    @StateObject private var viewModel: BrewSetupViewModel

    init(recipe: Recipe) {
        self.recipe = recipe
        self._viewModel = StateObject(wrappedValue: BrewSetupViewModel(recipe: recipe))
    }

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
                        
                        HStack {
                            Text("Servings:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(recipe.servings) person\(recipe.servings > 1 ? "s" : "")")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                .onAppear {
                    print("DEBUG: BrewSetupScreen received recipe '\(recipe.title)' with \(recipe.parameters.coffeeGrams)g coffee, \(recipe.servings) servings")
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
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Temperature: \(viewModel.waterTemperature, specifier: "%.0f")°C")
                            Slider(value: $viewModel.waterTemperature, in: 80...100, step: 1)
                        }
                        
                        // Thermometer animation
                        LottieView(name: "Thermometer Hot", loopMode: .loop, speed: 1.0, isPlaying: true)
                            .frame(width: 60, height: 60)
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
}
