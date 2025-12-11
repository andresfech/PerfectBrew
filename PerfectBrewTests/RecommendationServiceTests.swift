import XCTest
@testable import PerfectBrew

class RecommendationServiceTests: XCTestCase {
    
    var service: RecommendationService!
    
    override func setUp() {
        super.setUp()
        service = RecommendationService.shared
    }
    
    func testPerfectMatch() {
        // Arrange
        let coffee = Coffee(
            name: "Test Coffee",
            roastLevel: .light,
            process: .washed,
            flavorTags: [.citrus, .floral]
        )
        
        let profile = RecipeProfile(
            recommendedRoastLevels: [.light],
            recommendedProcesses: [.washed],
            recommendedFlavorTags: [.citrus, .floral],
            recommendedOrigins: nil,
            recommendedVarieties: nil
        )
        
        let matchingRecipe = Recipe(
            title: "Perfect Match V60",
            brewingMethod: "V60",
            skillLevel: "Beginner",
            rating: 5.0,
            parameters: Recipe.sampleRecipe.parameters,
            preparationSteps: [],
            brewingSteps: [],
            equipment: [],
            notes: "",
            whatToExpect: nil,
            recipeProfile: profile
        )
        
        // Act
        let recommendations = service.getRecommendations(for: coffee, from: [matchingRecipe])
        let rec = recommendations.first!
        
        // Assert
        // 50 (Roast) + 30 (Process) + 20 (2 tags * 10 capped at 20) = 100
        XCTAssertEqual(rec.score, 100)
        XCTAssertTrue(rec.reasons.contains("Matches Light roast"))
        XCTAssertTrue(rec.reasons.contains("Best for Washed process"))
        XCTAssertTrue(rec.reasons.contains { $0.contains("Highlights: Citrus, Floral") || $0.contains("Highlights: Floral, Citrus") })
    }
    
    func testPartialMatch() {
        // Arrange
        let coffee = Coffee(
            name: "Medium Natural",
            roastLevel: .medium,
            process: .natural,
            flavorTags: [.berry]
        )
        
        let profile = RecipeProfile(
            recommendedRoastLevels: [.medium], // Match (50)
            recommendedProcesses: [.washed],   // Mismatch (0)
            recommendedFlavorTags: [.nutty],    // Mismatch (0)
            recommendedOrigins: nil,
            recommendedVarieties: nil
        )
        
        let partialRecipe = Recipe(
            title: "Partial Match",
            brewingMethod: "French Press",
            skillLevel: "Any",
            rating: 4.0,
            parameters: Recipe.sampleRecipe.parameters,
            preparationSteps: [],
            brewingSteps: [],
            equipment: [],
            notes: "",
            whatToExpect: nil,
            recipeProfile: profile
        )
        
        // Act
        let recommendations = service.getRecommendations(for: coffee, from: [partialRecipe])
        let rec = recommendations.first!
        
        // Assert
        // 50 (Roast) + 0 (Process) + 0 (Tags) = 50
        XCTAssertEqual(rec.score, 50)
        XCTAssertTrue(rec.reasons.contains("Matches Medium roast"))
    }
    
    func testOriginMatch() {
        // Arrange
        let coffee = Coffee(
            name: "Yirgacheffe",
            roastLevel: .light,
            process: .washed,
            country: "Ethiopia"
        )
        
        let profile = RecipeProfile(
            recommendedRoastLevels: [.light],
            recommendedProcesses: [.washed],
            recommendedFlavorTags: [],
            recommendedOrigins: ["Ethiopia", "Kenya"],
            recommendedVarieties: nil
        )
        
        let originRecipe = Recipe(
            title: "African Coffee Method",
            brewingMethod: "V60",
            skillLevel: "Any",
            rating: 5.0,
            parameters: Recipe.sampleRecipe.parameters,
            preparationSteps: [],
            brewingSteps: [],
            equipment: [],
            notes: "",
            whatToExpect: nil,
            recipeProfile: profile
        )
        
        // Act
        let recommendations = service.getRecommendations(for: coffee, from: [originRecipe])
        let rec = recommendations.first!
        
        // Assert
        // 50 (Roast) + 30 (Process) + 15 (Origin) = 95
        XCTAssertEqual(rec.score, 95)
        XCTAssertTrue(rec.reasons.contains("Best for Ethiopia coffee"))
    }
    
    func testVarietyMatch() {
        // Arrange
        let coffee = Coffee(
            name: "Panama Geisha",
            roastLevel: .light,
            process: .natural,
            variety: "Geisha"
        )
        
        let profile = RecipeProfile(
            recommendedRoastLevels: [.light],
            recommendedProcesses: [.natural],
            recommendedFlavorTags: [],
            recommendedOrigins: nil,
            recommendedVarieties: ["Geisha"]
        )
        
        let varietyRecipe = Recipe(
            title: "Competition V60",
            brewingMethod: "V60",
            skillLevel: "Expert",
            rating: 5.0,
            parameters: Recipe.sampleRecipe.parameters,
            preparationSteps: [],
            brewingSteps: [],
            equipment: [],
            notes: "",
            whatToExpect: nil,
            recipeProfile: profile
        )
        
        // Act
        let recommendations = service.getRecommendations(for: coffee, from: [varietyRecipe])
        let rec = recommendations.first!
        
        // Assert
        // 50 (Roast) + 30 (Process) + 10 (Variety) = 90
        XCTAssertEqual(rec.score, 90)
        XCTAssertTrue(rec.reasons.contains("Perfect for Geisha"))
    }
    
    func testNoProfileFallback() {
        // Arrange
        let coffee = Coffee(name: "Any Coffee")
        
        let legacyRecipe = Recipe(
            title: "Legacy Recipe",
            brewingMethod: "AeroPress",
            skillLevel: "Any",
            rating: 4.0,
            parameters: Recipe.sampleRecipe.parameters,
            preparationSteps: [],
            brewingSteps: [],
            equipment: [],
            notes: "",
            whatToExpect: nil,
            recipeProfile: nil // No profile
        )
        
        // Act
        let recommendations = service.getRecommendations(for: coffee, from: [legacyRecipe])
        
        // Assert
        XCTAssertEqual(recommendations.first?.score, 30)
    }
}
