import SwiftUI

struct BrewDetailScreen: View {
    let recipe: Recipe
    var coffee: Coffee? = nil // AEC-11
    @StateObject private var audioService = AudioService()
    @StateObject private var grinderService = GrinderService.shared
    @AppStorage("selectedGrinder") private var selectedGrinder: String = "None"
    @State private var isStepsExpanded: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Overview Badge
                HStack {
                    Image(systemName: "eye.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("recipe_overview".localized)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("review_before_brewing".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Header (AEC-13: localized title)
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.localizedTitle)
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
                    print("DEBUG: BrewDetailScreen coffee: \(coffee?.name ?? "nil")")
                }
                
                // Parameters Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("brew_parameters".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    // First row - Coffee and Water
                    HStack(spacing: 16) {
                        ParameterRow(
                            icon: "drop.fill",
                            title: "coffee".localized.uppercased(),
                            value: "\(recipe.parameters.coffeeGrams)g",
                            color: .brown
                        )
                        ParameterRow(
                            icon: "drop.fill",
                            title: "water".localized.uppercased(),
                            value: "\(recipe.parameters.waterGrams)g",
                            color: .blue
                        )
                    }
                    
                    // Second row - Ratio and Temperature
                    HStack(spacing: 16) {
                        ParameterRow(
                            icon: "arrow.left.arrow.right",
                            title: "ratio".localized.uppercased(),
                            value: recipe.parameters.ratio,
                            color: .green
                        )
                        ParameterRow(
                            icon: "thermometer",
                            title: "temperature".localized.uppercased(),
                            value: "\(Int(recipe.parameters.temperatureCelsius))°C",
                            color: .red
                        )
                    }
                    
                    // Third row - Brew Time
                    HStack(spacing: 16) {
                        ParameterRow(
                            icon: "clock.fill",
                            title: "brew_time".localized.uppercased(),
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
                            Text("grind_size".localized.uppercased())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            // Grinder Selector
                            Menu {
                                Button("None (Description)", action: { selectedGrinder = "None" })
                                ForEach(grinderService.availableGrinders, id: \.self) { grinder in
                                    Button(grinder, action: { selectedGrinder = grinder })
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedGrinder == "None" ? "grinder_brand".localized : selectedGrinder)
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
                
                // Steps Preview Card (Combined Preparation + Brewing Steps)
                StepsPreviewCardView(
                    preparationSteps: recipe.localizedPreparationSteps,
                    brewingSteps: recipe.brewingSteps,
                    totalTime: recipe.parameters.totalBrewTimeSeconds,
                    isExpanded: $isStepsExpanded
                )
                
                // Equipment
                VStack(alignment: .leading, spacing: 12) {
                    Text("equipment_needed".localized)
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
                
                // Notes (AEC-13: localized)
                if !recipe.localizedNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("notes".localized)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                // AEC-13: Pass both English and Spanish audio filenames
                                audioService.toggleNotesAudio(
                                    for: recipe.title,
                                    audioFileName: recipe.whatToExpect?.audioFileName,
                                    audioFileNameEs: recipe.whatToExpect?.audioFileNameEs
                                )
                            }) {
                                // AEC-13: Use localized audio filename for state check
                                let notesFileName = recipe.whatToExpect?.localizedAudioFileName ?? audioService.getNotesFileName(for: recipe.title)
                                let isCurrentAudio = audioService.currentAudioFile == notesFileName
                                let isPlaying = isCurrentAudio && audioService.isPlaying
                                
                                HStack(spacing: 6) {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(isPlaying ? "pause".localized : (isCurrentAudio ? "resume".localized : "listen".localized))
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
                        
                        Text(recipe.localizedNotes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Visual Separator
                Divider()
                    .padding(.vertical, 8)
                
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
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.title3)
                            Text("start_step_by_step_guide".localized)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        Text("follow_guided_steps".localized)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .background(Color.orange)
                    .cornerRadius(16)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("recipe_details".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Steps Preview Card Component
struct StepsPreviewCardView: View {
    let preparationSteps: [String]
    let brewingSteps: [BrewingStep]
    let totalTime: Int
    @Binding var isExpanded: Bool
    
    private var totalStepsCount: Int {
        return preparationSteps.count + brewingSteps.count
    }
    
    private var previewSteps: [(index: Int, text: String)] {
        let combined: [(Int, String)] = preparationSteps.enumerated().map { (index, step) in
            (index + 1, step)
        } + brewingSteps.enumerated().map { (index, step) in
            (preparationSteps.count + index + 1, step.localizedInstruction)
        }
        return isExpanded ? combined : Array(combined.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("brewing_steps_preview".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Preview badge
                Text("PREVIEW")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(6)
            }
            
            // Steps summary
            HStack {
                Text("\(totalStepsCount) \(totalStepsCount == 1 ? "step".localized : "steps".localized) • \(totalTime)s \("total".localized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.bottom, 4)
            
            // Preview steps (muted styling)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(previewSteps.enumerated()), id: \.offset) { _, stepItem in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(stepItem.index)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                        
                        Text(stepItem.text)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
            }
            
            // Expand/Collapse Button
            if totalStepsCount > 3 {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(isExpanded ? "collapse_steps".localized : "view_all_steps".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
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
