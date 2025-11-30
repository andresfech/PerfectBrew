import SwiftUI

struct RecipeSelectionScreen: View {
    let selectedMethod: HomeScreen.BrewMethod
    @StateObject private var recipeDatabase = RecipeDatabase()
    @State private var selectedDifficulty: Difficulty? = nil
    @State private var selectedDoseRange: DoseRange = .medium // Default to 15-20g
    @State private var searchText = ""
    
    enum DoseRange: String, CaseIterable {
        case small = "< 15g"
        case medium = "15 - 20g"
        case large = "> 20g"
        
        func matches(_ grams: Double) -> Bool {
            switch self {
            case .small: return grams < 15
            case .medium: return grams >= 15 && grams <= 20
            case .large: return grams > 20
            }
        }
    }
    
    var filteredRecipes: [Recipe] {
        // 1. Load base recipes for the method
        var recipes = recipeDatabase.getRecipes(for: selectedMethod)
        
        print("RecipeSelectionScreen: Base recipes: \(recipes.count)")
        
        // 2. Filter by dose range
        recipes = recipes.filter { selectedDoseRange.matches($0.parameters.coffeeGrams) }
        print("RecipeSelectionScreen: After dose filter (\(selectedDoseRange.rawValue)): \(recipes.count)")
        
        // 3. Filter by difficulty if selected
        if let difficulty = selectedDifficulty {
            recipes = recipes.filter { $0.difficulty == difficulty }
        }
        
        // 4. Filter by search text
        if !searchText.isEmpty {
            recipes = recipes.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.skillLevel.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return recipes
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Perfect Brew")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(selectedMethod.rawValue) Recipes")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search recipes...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            // Difficulty Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All",
                        isSelected: selectedDifficulty == nil,
                        action: { selectedDifficulty = nil }
                    )
                    
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        FilterChip(
                            title: difficulty.rawValue,
                            isSelected: selectedDifficulty == difficulty,
                            action: { selectedDifficulty = difficulty }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Coffee Dose Filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount of Coffee (grams)")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    ForEach(DoseRange.allCases, id: \.self) { range in
                        DoseRangeChip(
                            title: range.rawValue,
                            isSelected: selectedDoseRange == range,
                            action: { selectedDoseRange = range }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Debug info
            VStack(alignment: .leading, spacing: 4) {
                Text("Debug Info:")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Total recipes in DB: \(recipeDatabase.recipes.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Recipes for \(selectedMethod.rawValue): \(recipeDatabase.getRecipes(for: selectedMethod).count)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Filtered recipes: \(filteredRecipes.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Recipes Section
            if filteredRecipes.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No recipes found")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Try adjusting your search or filters")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // Additional debug info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Debug: Why no recipes?")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("Selected method: \(selectedMethod.rawValue)")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("Selected dose range: \(selectedDoseRange.rawValue)")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("All recipes in DB: \(recipeDatabase.recipes.count)")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("Recipes by method: \(recipeDatabase.recipesByMethod.keys.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(filteredRecipes) { recipe in
                            NavigationLink(destination: BrewDetailScreen(recipe: recipe)) {
                                RecipeCard(recipe: recipe)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                print("DEBUG: Recipe card for '\(recipe.title)' with \(recipe.parameters.coffeeGrams)g coffee, \(recipe.servings) servings")
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .onAppear {
            print("RecipeSelectionScreen: Appeared for method: \(selectedMethod.rawValue)")
            
            print("RecipeSelectionScreen: Recipe database has \(recipeDatabase.recipes.count) total recipes")
            print("RecipeSelectionScreen: Recipes for \(selectedMethod.rawValue): \(recipeDatabase.getRecipes(for: selectedMethod).count)")
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color.gray.opacity(0.2))
                .cornerRadius(16)
        }
    }
}

struct DoseRangeChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline) // Slightly larger for touch target
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity) // Make them equal width if in a grid, or flexible
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(isSelected ? Color.brown : Color.gray.opacity(0.1)) // Brown for coffee context
                .cornerRadius(8) // More squared like the screenshot
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(spacing: 12) {
            // Brewing Method Icon
            VStack(spacing: 4) {
                Image(systemName: brewingMethodIcon)
                    .font(.system(size: 24))
                    .foregroundColor(brewingMethodColor)
                Text(recipe.brewingMethod)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(height: 40)
            
            // Recipe Name
            Text(recipe.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Dose indicator
            HStack(spacing: 4) {
                Image(systemName: "scalemass.fill")
                    .font(.caption2)
                    .foregroundColor(.blue)
                Text("\(Int(recipe.parameters.coffeeGrams))g")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            
            // Rating Stars
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= Int(recipe.rating) ? "star.fill" : 
                          star == Int(recipe.rating) + 1 && recipe.rating.truncatingRemainder(dividingBy: 1) > 0 ? "star.leadinghalf.filled" : "star")
                        .font(.caption)
                        .foregroundColor(star <= Int(recipe.rating) || (star == Int(recipe.rating) + 1 && recipe.rating.truncatingRemainder(dividingBy: 1) > 0) ? .yellow : .gray)
                }
            }
            
            // Difficulty Tag
            Text(recipe.skillLevel)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(difficultyColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(difficultyColor.opacity(0.2))
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
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
    
    private var brewingMethodIcon: String {
        switch recipe.brewingMethod.lowercased() {
        case "v60":
            return "drop.fill"
        case "chemex":
            return "hourglass"
        case "french press":
            return "cylinder.fill"
        case "aeropress":
            return "bolt.fill"
        default:
            return "cup.and.saucer"
        }
    }
    
    private var brewingMethodColor: Color {
        switch recipe.brewingMethod.lowercased() {
        case "v60":
            return .orange
        case "chemex":
            return .gray
        case "french press":
            return .red
        case "aeropress":
            return .yellow
        default:
            return .blue
        }
    }
}

struct RecipeSelectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        RecipeSelectionScreen(selectedMethod: .v60)
    }
}
