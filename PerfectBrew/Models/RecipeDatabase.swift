import Foundation

class RecipeDatabase: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var recipesByMethod: [String: [Recipe]] = [:]
    
    init() {
        print("🔧 RecipeDatabase: Initializing...")
        loadAllRecipes()
        
        // Asynchronously fetch remote recipes
        // Disabled temporarily for build fix
        /*
        Task {
            await fetchRemoteRecipes()
        }
        */
        print("🔧 RecipeDatabase: Initialization complete. Total recipes: \(recipes.count)")
    }
    
    private func loadAllRecipes() {
        print("🔧 RecipeDatabase: loadAllRecipes() called")
        // Load recipes from hierarchical structure under Resources/Recipes
        loadRecipesFromHierarchicalStructure()
        print("🔧 RecipeDatabase: loadAllRecipes() completed. Total recipes: \(recipes.count)")
    }
    
    // MARK: - Supabase Integration
    func fetchRemoteRecipes() async {
        // Disabled temporarily for build fix
        /*
        print("🌍 Fetching remote recipes from Supabase...")
        do {
            let remoteRecipes = try await SupabaseManager.shared.fetchRecipes()
            print("✅ Fetched \(remoteRecipes.count) recipes from cloud")
            
            DispatchQueue.main.async {
                self.mergeRecipes(remoteRecipes)
            }
        } catch {
            print("❌ Error fetching remote recipes: \(error)")
        }
        */
    }
    
    private func mergeRecipes(_ remoteRecipes: [Recipe]) {
        var currentRecipes = self.recipes
        var updatedCount = 0
        var newCount = 0
        
        for remote in remoteRecipes {
            if let index = currentRecipes.firstIndex(where: { $0.title == remote.title }) {
                // Update existing recipe logic
                // For now, we assume cloud is source of truth if titles match
                // In a robust system, we'd check 'version' or 'updated_at'
                currentRecipes[index] = remote
                updatedCount += 1
            } else {
                // Append new recipe
                currentRecipes.append(remote)
                newCount += 1
            }
        }
        
        if updatedCount > 0 || newCount > 0 {
            print("🔄 Merge complete: Updated \(updatedCount), Added \(newCount) recipes")
            self.recipes = currentRecipes
            
            // Re-group by method
            var grouped: [String: [Recipe]] = [:]
            for recipe in currentRecipes {
                let method = recipe.brewingMethod
                if grouped[method] == nil { grouped[method] = [] }
                grouped[method]?.append(recipe)
            }
            self.recipesByMethod = grouped
        } else {
            print("✅ Local recipes match cloud recipes. No changes needed.")
        }
    }

    // MARK: - Hierarchical loader
    private func loadRecipesFromHierarchicalStructure() {
        print("🔧 RecipeDatabase: loadRecipesFromHierarchicalStructure() called")
        var allRecipes: [Recipe] = []
        var grouped: [String: [Recipe]] = [:]
        
        // Locate Recipes directory in bundle (Xcode flattens the structure)
        guard let bundlePath = Bundle.main.resourcePath else {
            print("❌ Bundle resource path not found")
            return
        }
        
        let recipesRootUrl = URL(fileURLWithPath: bundlePath)
        print("✅ Using bundle root as recipes directory: \(recipesRootUrl.path)")
        
        print("✅ Found Recipes directory at: \(recipesRootUrl.path)")
        
        do {
            // Look for JSON files recursively in the bundle
            var jsonFiles = try findJSONFilesRecursively(in: recipesRootUrl)
            
            print("Found \(jsonFiles.count) JSON files in bundle")
            
            // Also check for root-level recipe files
            let rootRecipeFiles = ["recipes_aeropress.json", "recipes_v60.json", "recipes_chemex.json", "recipes_frenchpress.json"]
            for fileName in rootRecipeFiles {
                let fileUrl = recipesRootUrl.appendingPathComponent(fileName)
                if FileManager.default.fileExists(atPath: fileUrl.path) {
                    print("Found root recipe file: \(fileName)")
                    jsonFiles.append(fileUrl)
                }
            }
            
            print("Total files to process: \(jsonFiles.count)")
            
            for fileUrl in jsonFiles {
                let fileName = fileUrl.lastPathComponent
                print("🔍 Processing file: \(fileName)")
                
                // Skip non-recipe JSON files
                if fileName.contains("Coffee Beans Loader") || 
                   fileName.contains("Thermometer") || 
                   fileName.contains("Water Bubble") ||
                   fileName.contains("aeropress_minimal_zen_lottie") {
                    print("⏭️ Skipping non-recipe file: \(fileName)")
                    continue
                }
                
                print("✅ Processing recipe file: \(fileName)")
                
                do {
                    let data = try Data(contentsOf: fileUrl)
                    let decoded = try JSONDecoder().decode([Recipe].self, from: data)
                    
                    for recipe in decoded {
                        let method = recipe.brewingMethod
                        if grouped[method] == nil {
                            grouped[method] = []
                        }
                        grouped[method]?.append(recipe)
                        allRecipes.append(recipe)
                    }
                    
                    print("✅ Loaded \(decoded.count) recipes from \(fileName)")
                } catch {
                    print("❌ Error decoding recipes at \(fileName): \(error)")
                }
            }
        } catch {
            print("Error reading bundle directory: \(error)")
            return
        }
        
        guard !allRecipes.isEmpty else {
            print("No recipes found in bundle")
            return
        }
        
        self.recipes = allRecipes
        self.recipesByMethod = grouped
        print("Total recipes loaded: \(allRecipes.count)")
        print("Recipes by method: \(grouped.keys.joined(separator: ", "))")
    }
    
    private func methodDisplayName(_ folderName: String) -> String {
        // Map folder names to display names used elsewhere
        switch folderName {
        case "French_Press": return "French Press"
        default: return folderName
        }
    }
    
    private func findJSONFilesRecursively(in directory: URL) throws -> [URL] {
        var jsonFiles: [URL] = []
        
        print("🔍 Searching for JSON files in: \(directory.path)")
        
        let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )
        
        while let fileURL = enumerator?.nextObject() as? URL {
            if fileURL.pathExtension.lowercased() == "json" {
                print("📄 Found JSON file: \(fileURL.path)")
                jsonFiles.append(fileURL)
            }
        }
        
        print("📊 Total JSON files found: \(jsonFiles.count)")
        return jsonFiles
    }
    
    
    func getRecipes(for method: HomeScreen.BrewMethod) -> [Recipe] {
        let methodString = method.rawValue
        return recipesByMethod[methodString] ?? []
    }
    
    func getRecipes(for method: HomeScreen.BrewMethod, servings: Int = 1) -> [Recipe] {
        // NOTE: 'servings' parameter is now ignored for loading, as we only have single-serve recipes.
        // It will be replaced by dynamic scaling in the View layer.
        
        let methodRecipes = getRecipes(for: method)
        
        if methodRecipes.isEmpty {
            print("No recipes found for method: \(method.rawValue)")
            return []
        }
        
        // Since we deleted multi-serving recipes, we just return the base recipes.
        // Scaling happens in the UI layer via Recipe.scaled(to:)
        print("Found \(methodRecipes.count) base recipes for \(method.rawValue)")
        return methodRecipes
    }
    
    // Helper function to extract base title from recipe title
    private func getBaseTitle(from title: String) -> String {
        // Remove common serving suffixes
        let servingSuffixes = [
            " - Single Serve",
            " - Two People", 
            " - Three People",
            " - Four People",
            " - Single",
            " - Two",
            " - Three",
            " - Four"
        ]
        
        var baseTitle = title
        for suffix in servingSuffixes {
            if baseTitle.hasSuffix(suffix) {
                baseTitle = String(baseTitle.dropLast(suffix.count))
                break
            }
        }
        
        return baseTitle
    }
    
    // Helper function to find the closest recipe to the target servings
    private func findClosestRecipe(_ recipes: [Recipe], targetServings: Int) -> Recipe {
        // Prefer recipes with 1 serving as they're easier to scale
        if let singleServing = recipes.first(where: { $0.servings == 1 }) {
            return singleServing
        }
        
        // Otherwise, find the recipe with servings closest to target
        return recipes.min { recipe1, recipe2 in
            abs(recipe1.servings - targetServings) < abs(recipe2.servings - targetServings)
        } ?? recipes.first!
    }
    
    func getAllRecipes() -> [Recipe] {
        return recipes
    }
    
    func searchRecipes(query: String) -> [Recipe] {
        let lowercasedQuery = query.lowercased()
        return recipes.filter { recipe in
            recipe.title.lowercased().contains(lowercasedQuery) ||
            recipe.brewingMethod.lowercased().contains(lowercasedQuery) ||
            recipe.skillLevel.lowercased().contains(lowercasedQuery)
        }
    }
}
