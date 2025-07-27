import SwiftUI

struct BrewDetailScreen: View {
    let recipe: Recipe
    @State private var showingBrewSetup = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(recipe.brewingMethod)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(recipe.rating) ? "star.fill" : 
                                      star == Int(recipe.rating) + 1 && recipe.rating.truncatingRemainder(dividingBy: 1) > 0 ? "star.leadinghalf.filled" : "star")
                                    .foregroundColor(.yellow)
                            }
                            Text(String(format: "%.1f", recipe.rating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Parameters Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Brew Parameters")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ParameterRow(title: "Coffee", value: "\(recipe.parameters.coffeeGrams)g")
                        ParameterRow(title: "Water", value: "\(recipe.parameters.waterGrams)g")
                        ParameterRow(title: "Ratio", value: recipe.parameters.ratio)
                        ParameterRow(title: "Grind Size", value: recipe.parameters.grindSize)
                        ParameterRow(title: "Temperature", value: "\(Int(recipe.parameters.temperatureCelsius))°C")
                        ParameterRow(title: "Brew Time", value: "\(recipe.parameters.totalBrewTimeSeconds)s")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Steps
                VStack(alignment: .leading, spacing: 16) {
                    Text("Brewing Steps")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.orange)
                                .clipShape(Circle())
                            
                            Text(step)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                }
                
                // Equipment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Equipment Needed")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(recipe.equipment, id: \.self) { item in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(item)
                                .font(.body)
                            Spacer()
                        }
                    }
                }
                
                // Notes
                if !recipe.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(recipe.notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Start Brewing Button
                Button(action: {
                    showingBrewSetup = true
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
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingBrewSetup) {
            BrewSetupScreen(recipe: recipe)
        }
    }
}

struct ParameterRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct BrewDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrewDetailScreen(recipe: Recipe(
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
                steps: ["Step 1", "Step 2", "Step 3"],
                equipment: ["V60", "Scale", "Kettle"],
                notes: "Sample notes"
            ))
        }
    }
}
