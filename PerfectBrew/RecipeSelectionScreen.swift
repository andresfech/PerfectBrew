import SwiftUI

struct RecipeSelectionScreen: View {
    let selectedMethod: HomeScreen.BrewMethod
    @State private var recipes: [Recipe] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Perfect Brew")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Craft the perfect cup")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Recipes Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("\(selectedMethod.rawValue) Recipes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    // Recipe Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(recipes) { recipe in
                            RecipeCard(recipe: recipe)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Select Recipe Button
                Button(action: {
                    // TODO: Navigate to recipe detail or brew setup
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.title3)
                        Text("Select a Recipe")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Brew History Section
                VStack(spacing: 16) {
                    Text("Brew History")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    NavigationLink(destination: BrewHistoryScreen()) {
                        Text("View History")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
            .onAppear {
                loadRecipes()
            }
        }
    }
    
    private func loadRecipes() {
        switch selectedMethod {
        case .v60:
            recipes = Recipe.v60Recipes
        case .chemex:
            recipes = [] // TODO: Add Chemex recipes
        case .frenchPress:
            recipes = [] // TODO: Add French Press recipes
        case .aeroPress:
            recipes = [] // TODO: Add AeroPress recipes
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(spacing: 12) {
            // V60 Icon
            VStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                Text("V60")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(height: 40)
            
            // Recipe Name
            Text(recipe.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
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
            Text(recipe.difficulty.rawValue)
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
        switch recipe.difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        }
    }
}

struct RecipeSelectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        RecipeSelectionScreen(selectedMethod: .v60)
    }
}
