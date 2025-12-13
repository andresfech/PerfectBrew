import Foundation

class BrewingRuleEngine {
    static let shared = BrewingRuleEngine()
    private let knowledgeBase = KnowledgeBaseService.shared
    
    // MARK: - Public API
    
    func computeTargetProfile(for coffee: Coffee) -> ExtractionCharacteristics {
        // 1. Start with a neutral baseline
        var target = ExtractionCharacteristics() // Default 0.5s and Mediums
        
        // 2. Apply Variety Rules (The "Soul" of the coffee)
        if !coffee.variety.isEmpty, let varietyProfile = knowledgeBase.getVarietyProfile(for: coffee.variety) {
            print("🧬 Rule Engine: Applying Variety Profile for \(varietyProfile.variety)")
            apply(varietyProfile, to: &target)
        }
        
        // 3. Apply Process Rules (The "Body" mechanics)
        // Process is an Enum in Coffee, converted to string for lookup
        if let processProfile = knowledgeBase.getProcessProfile(for: coffee.process.rawValue) {
            print("⚗️ Rule Engine: Applying Process Profile for \(processProfile.process)")
            apply(processProfile, to: &target)
        }
        
        // 4. Apply Physical Rules (Roast, Altitude)
        applyPhysicalRules(for: coffee, to: &target)
        
        // 5. Apply Flavor Tags (Fine-tuning)
        applyFlavorTags(for: coffee, to: &target)
        
        // 6. Clamp values to 0.0 - 1.0
        clamp(&target)
        
        return target
    }
    
    // MARK: - Rule Applicators
    
    private func apply(_ profile: VarietyProfile, to target: inout ExtractionCharacteristics) {
        // Variety sets the "Goal" mostly, essentially overriding defaults significantly
        // We use a weighted average approach: (Current + Target) / 2 to blend? 
        // Or strictly set? 
        // "Geisha" SHOULD be High Clarity.
        // Let's set the bias closer to the profile.
        
        target.clarity = (target.clarity + profile.extractionBias.clarity) / 2
        target.acidity = (target.acidity + profile.extractionBias.acidity) / 2
        target.sweetness = (target.sweetness + profile.extractionBias.sweetness) / 2
        target.body = (target.body + profile.extractionBias.body) / 2
        
        // Parameters are strict constraints from variety
        target.agitation = profile.brewingParameters.agitationTolerance
        target.thermal = profile.brewingParameters.thermalMassNeed
    }
    
    private func apply(_ profile: ProcessProfile, to target: inout ExtractionCharacteristics) {
        // Process acts as a modifier (+/-)
        target.clarity += profile.extractionModifier.clarity
        target.acidity += profile.extractionModifier.acidity
        target.sweetness += profile.extractionModifier.sweetness
        target.body += profile.extractionModifier.body
        
        // Process constraints override Variety constraints usually (e.g. Natural Geisha -> Low Agitation due to fines, even if Geisha tolerates some)
        // We take the more conservative (lower) agitation
        if profile.brewingParameters.agitationTolerance.value < target.agitation.value {
            target.agitation = profile.brewingParameters.agitationTolerance
        }
    }
    
    private func applyPhysicalRules(for coffee: Coffee, to target: inout ExtractionCharacteristics) {
        // Roast Level Rules
        switch coffee.roastLevel {
        case .light:
            // Needs high energy
            if target.thermal != .high { target.thermal = .high }
            target.acidity += 0.1
        case .medium:
            // Balanced
            target.sweetness += 0.1
        case .dark:
            // Low energy required to avoid bitterness
            target.thermal = .low
            target.body += 0.2
            target.clarity -= 0.1
        }
        
        // Altitude Rules (if available)
        // "1800m" -> extract int
        let altitude = Int(coffee.altitude.filter { "0123456789".contains($0) }) ?? 0
        if altitude > 1700 {
            // High density -> Needs thermal mass
            target.thermal = .high
            target.acidity += 0.1
        } else if altitude < 1000 && altitude > 0 {
            // Low density -> Gentle
            target.thermal = .medium // Cap at medium if it was high
        }
    }
    
    private func applyFlavorTags(for coffee: Coffee, to target: inout ExtractionCharacteristics) {
        for tag in coffee.flavorTags {
            switch tag {
            // Fruity/Acidic profiles
            case .fruity, .berry, .citrus, .stoneFruit, .tropical, .acidity, .bright, .vibrant, .juicy, .crisp:
                target.acidity += 0.05
                target.clarity += 0.05
            // Delicate/Floral profiles
            case .floral, .tea, .herbaceous, .delicate, .elegant, .clean, .clarityFocused, .lightBodied:
                target.clarity += 0.1
                target.body -= 0.05
            // Sweet/Rich profiles
            case .nutty, .chocolate, .caramel, .vanilla, .sweet, .roasted, .rich, .syrupy, .creamy:
                target.sweetness += 0.05
                target.body += 0.05
            // Fermented profiles
            case .fermented, .winey, .complex:
                target.body += 0.05
                target.sweetness += 0.05
                target.acidity += 0.05
            // Bold/Heavy profiles
            case .spicy, .savory, .earthy, .bold, .intense, .strong, .fullBodied, .punchy, .espressoLike:
                target.body += 0.05
                target.acidity -= 0.05
            // Balanced/Neutral profiles - no adjustment
            case .balanced, .smooth, .mellow, .refined, .structured, .nuanced, .aromatic, .silky, .lowAcidity,
                 .reliable, .round, .classic, .consistent, .artisan, .sustainable:
                break // Balanced tags don't shift extraction
            // Heavy/Thick profiles
            case .thick, .deep, .layered:
                target.body += 0.1
            // Clarity profiles
            case .clarified, .highAcidity:
                target.clarity += 0.1
                target.acidity += 0.05
            }
        }
    }
    
    private func clamp(_ target: inout ExtractionCharacteristics) {
        target.clarity = max(0, min(1, target.clarity))
        target.acidity = max(0, min(1, target.acidity))
        target.sweetness = max(0, min(1, target.sweetness))
        target.body = max(0, min(1, target.body))
    }
}

