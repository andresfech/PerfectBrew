import XCTest
@testable import PerfectBrew

class BrewingRuleEngineTests: XCTestCase {
    
    var engine: BrewingRuleEngine!
    
    override func setUp() {
        super.setUp()
        engine = BrewingRuleEngine.shared
        // Ensure KB is loaded (it loads in init, but sync)
        _ = KnowledgeBaseService.shared
    }
    
    func testGeishaWashedProfile() {
        let coffee = Coffee(
            name: "Panama Geisha",
            roastLevel: .light,
            process: .washed,
            variety: "Geisha"
        )
        
        let profile = engine.computeTargetProfile(for: coffee)
        
        // Geisha = Clarity 0.9. Washed = +0.1. Avg with 0.5 baseline -> High.
        // Approx: Baseline 0.5. Apply Geisha -> (0.5+0.9)/2 = 0.7. Apply Washed -> 0.7+0.1 = 0.8.
        XCTAssertGreaterThan(profile.clarity, 0.75, "Geisha should have high clarity")
        
        // Agitation: Geisha = Low. Washed = High. Process overrides if lower? 
        // Logic: if process.tolerance < target.tolerance. 
        // Geisha set target to Low. Washed has High tolerance. High is NOT < Low. 
        // So it stays Low (Variety constraint).
        // Wait, "Washed" description says "Tolerates higher agitation".
        // Geisha requires Low.
        // My logic: `if profile.brewingParameters.agitationTolerance.value < target.agitation.value`
        // Washed agitation is High (0.8). Target is Low (0.2). 0.8 < 0.2 is False.
        // So target remains Low. Correct. Delicate bean dictates.
        XCTAssertEqual(profile.agitation, .low, "Geisha requires gentle agitation despite being washed")
        
        XCTAssertEqual(profile.thermal, .high, "Light roast Geisha needs high thermal energy")
    }
    
    func testNaturalBourbonProfile() {
        let coffee = Coffee(
            name: "Brazil Bourbon",
            roastLevel: .medium,
            process: .natural,
            variety: "Bourbon"
        )
        
        let profile = engine.computeTargetProfile(for: coffee)
        
        // Bourbon: Sweetness 0.8. Baseline 0.5 -> (0.5+0.8)/2 = 0.65.
        // Natural: Sweetness +0.2. -> 0.85.
        // Roast Medium: Sweetness +0.1 -> 0.95.
        XCTAssertGreaterThan(profile.sweetness, 0.8, "Natural Bourbon should be very sweet")
        
        // Agitation: Bourbon = Med. Natural = Low.
        // Natural Low (0.2) < Bourbon Med (0.5).
        // Should become Low due to fines.
        XCTAssertEqual(profile.agitation, .low, "Natural process should force low agitation constraint")
    }
    
    func testDarkRoastPhysicalRule() {
        let coffee = Coffee(
            name: "Italian Roast",
            roastLevel: .dark,
            process: .washed
        )
        
        let profile = engine.computeTargetProfile(for: coffee)
        
        XCTAssertEqual(profile.thermal, .low, "Dark roast must strictly use low thermal energy")
        XCTAssertGreaterThan(profile.body, 0.6, "Dark roast should favor body")
    }
}

