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
        
        let recipe = Recipe.sampleRecipe
        // Override sample recipe profile to match perfectly
        // Assuming we can't easily mutate the let property in the test without creating a new instance
        // But we can create a new Recipe instance
        
        let profile = RecipeProfile(
            recommendedRoastLevels: [.light],
            recommendedProcesses: [.washed],
            recommendedFlavorTags: [.citrus, .floral]
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
            recommendedFlavorTags: [.nutty]    // Mismatch (0)
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

