import SwiftUI

struct BrewDetailScreen: View {
    let recipe: Recipe
    var coffee: Coffee? = nil // AEC-11
    @StateObject private var audioService = AudioService()
    @StateObject private var grinderService = GrinderService.shared
    @AppStorage("selectedGrinder") private var selectedGrinder: String = "None"
    
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
                .onAppear {
                    print("DEBUG: BrewDetailScreen received recipe '\(recipe.title)' with \(recipe.parameters.coffeeGrams)g coffee, \(recipe.servings) servings")
                }
                
                // Parameters Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("Brew Parameters")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    // First row - Coffee and Water
                    HStack(spacing: 16) {
                        ParameterRow(
                            icon: "drop.fill",
                            title: "Coffee",
                            value: "\(recipe.parameters.coffeeGrams)g",
                            color: .brown
                        )
                        ParameterRow(
                            icon: "drop.fill",
                            title: "Water",
                            value: "\(recipe.parameters.waterGrams)g",
                            color: .blue
                        )
                    }
                    
                    // Second row - Ratio and Temperature
                    HStack(spacing: 16) {
                        ParameterRow(
                            icon: "arrow.left.arrow.right",
                            title: "Ratio",
                            value: recipe.parameters.ratio,
                            color: .green
                        )
                        ParameterRow(
                            icon: "thermometer",
                            title: "Temperature",
                            value: "\(Int(recipe.parameters.temperatureCelsius))°C",
                            color: .red
                        )
                    }
                    
                    // Third row - Brew Time
                    HStack(spacing: 16) {
                        ParameterRow(
                            icon: "clock.fill",
                            title: "Brew Time",
                            value: "\(recipe.parameters.totalBrewTimeSeconds)s",
                            color: .orange
                        )
                        Spacer()
                    }
                    
                    // Fourth row - Grind Size (full width)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "circle.grid.2x2.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                                .frame(width: 24, height: 24)
                            Text("GRIND SIZE")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Spacer()
                            
                            // Grinder Selector
                            Menu {
                                Button("None (Description)", action: { selectedGrinder = "None" })
                                ForEach(grinderService.availableGrinders, id: \.self) { grinder in
                                    Button(grinder, action: { selectedGrinder = grinder })
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedGrinder == "None" ? "Grinder Brand" : selectedGrinder)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                }
                                .foregroundColor(.purple)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        if selectedGrinder != "None" {
                            Text(grinderService.getSetting(for: selectedGrinder, recipe: recipe))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(recipe.parameters.grindSize)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text(recipe.parameters.grindSize)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                )
                
                // Preparation Steps
                if !recipe.preparationSteps.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Preparation Steps")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(Array(recipe.preparationSteps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                
                                Text(step)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                // Brewing Steps
                VStack(alignment: .leading, spacing: 16) {
                    Text("Brewing Steps")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(Array(recipe.brewingSteps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.orange)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.instruction)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                
                                Text("\(step.timeSeconds)s")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
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
                        HStack {
                            Text("Notes")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                audioService.toggleNotesAudio(for: recipe.title, audioFileName: recipe.whatToExpect?.audioFileName)
                            }) {
                                let notesFileName = recipe.whatToExpect?.audioFileName ?? audioService.getNotesFileName(for: recipe.title)
                                let isCurrentAudio = audioService.currentAudioFile == notesFileName
                                let isPlaying = isCurrentAudio && audioService.isPlaying
                                
                                HStack(spacing: 6) {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(isPlaying ? "Pause" : (isCurrentAudio ? "Resume" : "Listen"))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(isCurrentAudio ? .white : .orange)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(isCurrentAudio ? Color.orange : Color.clear)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.orange, lineWidth: 1.5)
                                )
                            }
                        }
                        
                        Text(recipe.notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Start Brewing Button
                NavigationLink(destination: BrewingGuideScreen(
                    coffeeDose: recipe.parameters.coffeeGrams,
                    waterAmount: recipe.parameters.waterGrams,
                    waterTemperature: recipe.parameters.temperatureCelsius,
                    grindSize: 5, // Default grind size
                    brewTime: TimeInterval(recipe.parameters.totalBrewTimeSeconds),
                    recipe: recipe,
                    coffee: coffee
                )) {
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
    }
}

struct ParameterRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
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
                parameters: RecipeBrewParameters(
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
            ))
        }
    }
}
