import SwiftUI

struct RecipeSelectionScreen: View {
    let selectedMethod: HomeScreen.BrewMethod
    @StateObject private var recipeDatabase = RecipeDatabase()
    @State private var selectedDifficulty: Difficulty? = nil
    @State private var selectedServings: Int = 1 // Default a 1 persona
    @State private var searchText = ""
    
    var filteredRecipes: [Recipe] {
        var recipes = recipeDatabase.getRecipes(for: selectedMethod, servings: selectedServings)
        
        if let difficulty = selectedDifficulty {
            recipes = recipes.filter { $0.difficulty == difficulty }
        }
        
        if !searchText.isEmpty {
            recipes = recipes.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.skillLevel.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return recipes
    }
    
    var body: some View {
        NavigationView {
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
                
                // Servings Filter
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cantidad de personas")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(1...4, id: \.self) { servings in
                                ServingsChip(
                                    servings: servings,
                                    isSelected: selectedServings == servings,
                                    action: { selectedServings = servings }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
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

struct ServingsChip: View {
    let servings: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: servings == 1 ? "person.fill" : "person.2.fill")
                    .font(.caption)
                Text("\(servings)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .cornerRadius(16)
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
            
            // Servings indicator
            if recipe.servings > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(recipe.servings) personas")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
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
