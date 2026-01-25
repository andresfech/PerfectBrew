import Foundation

/// Smart Diagnostic Service (AEC-12 v2)
/// Generates UNIFIED, coherent brew recommendations - no contradictions
class SmartDiagnosticService {
    static let shared = SmartDiagnosticService()
    
    private let ruleEngine = BrewingRuleEngine.shared
    
    // MARK: - Public API
    
    /// Generate comprehensive diagnostic result with unified direction
    func diagnose(
        coffee: Coffee?,
        recipe: Recipe,
        feedback: FeedbackData
    ) -> BrewDiagnosticResult {
        let actualProfile = ActualTasteProfile.from(feedback: feedback)
        let method = recipe.brewingMethod
        
        // If we have coffee context, do full comparison
        if let coffee = coffee {
            let expectedProfile = ruleEngine.computeTargetProfile(for: coffee)
            return diagnoseWithContext(
                expected: expectedProfile,
                actual: actualProfile,
                coffee: coffee,
                method: method,
                feedback: feedback
            )
        }
        
        // No coffee context - use generic defect-based diagnosis
        return diagnoseWithoutContext(
            actual: actualProfile,
            method: method,
            feedback: feedback
        )
    }
    
    // MARK: - Context-Aware Diagnosis
    
    private func diagnoseWithContext(
        expected: ExtractionCharacteristics,
        actual: ActualTasteProfile,
        coffee: Coffee,
        method: String,
        feedback: FeedbackData
    ) -> BrewDiagnosticResult {
        // Step 1: Calculate all gaps
        let gaps = calculateGaps(expected: expected, actual: actual)
        
        // Step 2: Determine SINGLE direction via weighted voting
        let baseConfidence = determineDirection(gaps: gaps, feedback: feedback).1
        let adjustedConfidence = adjustConfidenceForExecution(baseConfidence: baseConfidence, feedback: feedback)
        let direction = determineDirection(gaps: gaps, feedback: feedback).0
        let confidence = adjustedConfidence
        
        // Step 3: Determine assessment from direction
        let assessment = assessmentFromDirection(direction)
        
        // Step 4: Generate ALIGNED adjustments (all follow the direction)
        var adjustments = generateAlignedAdjustments(
            direction: direction,
            method: method,
            gaps: gaps,
            coffee: coffee
        )
        
        // Step 4.5: Adjust based on brew execution
        adjustments = adjustAdjustmentsForExecution(adjustments, feedback: feedback, method: method)
        
        // Step 5: Create unified adjustment
        let unified = UnifiedBrewAdjustment(
            direction: direction,
            confidence: confidence,
            summary: generateSummary(direction: direction, coffee: coffee),
            adjustments: adjustments
        )
        
        // Step 6: Generate dimension-specific recommendations
        var dimensionRecs = generateDimensionSpecificRecommendations(
            gaps: gaps,
            method: method,
            coffee: coffee
        )
        
        // Step 6.5: Add flavor tag recommendations
        let flavorTagRecs = generateFlavorTagRecommendations(
            coffee: coffee,
            experiencedTags: feedback.experiencedFlavorTags,
            method: method
        )
        dimensionRecs.append(contentsOf: flavorTagRecs)
        
        // Step 7: Convert to legacy format for backward compat
        let legacyRecs = adjustments.enumerated().map { index, item in
            BrewRecommendation(
                priority: index + 1,
                category: item.category,
                action: item.suggestedChange,
                reason: item.explanation,
                expectedVsActual: nil,
                impact: "\(item.impactPercent)% impact on your brew"
            )
        }
        
        return BrewDiagnosticResult(
            overallAssessment: assessment,
            assessmentConfidence: confidence,
            expectedProfile: expected,
            actualProfile: actual,
            hasCoffeeContext: true,
            unifiedAdjustment: unified,
            dimensionRecommendations: dimensionRecs,
            recommendations: legacyRecs
        )
    }
    
    // MARK: - Generic Diagnosis (No Coffee)
    
    private func diagnoseWithoutContext(
        actual: ActualTasteProfile,
        method: String,
        feedback: FeedbackData
    ) -> BrewDiagnosticResult {
        // Use defect or infer from taste profile
        let (direction, confidence) = determineDirectionWithoutContext(actual: actual, feedback: feedback)
        let assessment = assessmentFromDirection(direction)
        
        // Generate adjustments based on direction alone
        var adjustments = generateGenericAdjustments(direction: direction, method: method)
        
        // Adjust based on brew execution
        adjustments = adjustAdjustmentsForExecution(adjustments, feedback: feedback, method: method)
        
        // Adjust confidence based on execution
        let baseConfidence = confidence
        let adjustedConfidence = adjustConfidenceForExecution(baseConfidence: baseConfidence, feedback: feedback)
        let finalConfidence = adjustedConfidence
        
        let unified = UnifiedBrewAdjustment(
            direction: direction,
            confidence: finalConfidence,
            summary: "Based on your feedback, try \(direction.actionVerb)",
            adjustments: adjustments
        )
        
        // Generate dimension-specific recommendations from actual profile
        let dimensionRecs = generateDimensionRecommendationsFromActual(
            actual: actual,
            method: method
        )
        
        let legacyRecs = adjustments.enumerated().map { index, item in
            BrewRecommendation(
                priority: index + 1,
                category: item.category,
                action: item.suggestedChange,
                reason: item.explanation,
                expectedVsActual: nil,
                impact: "\(item.impactPercent)% impact on your brew"
            )
        }
        
        return BrewDiagnosticResult(
            overallAssessment: assessment,
            assessmentConfidence: confidence,
            expectedProfile: nil,
            actualProfile: actual,
            hasCoffeeContext: false,
            unifiedAdjustment: unified,
            dimensionRecommendations: dimensionRecs,
            recommendations: legacyRecs
        )
    }
    
    // MARK: - Direction Determination (Weighted Voting)
    
    private func determineDirection(gaps: [TasteGap], feedback: FeedbackData) -> (ExtractionDirection, Double) {
        // Check explicit defect first (user knows best)
        if let defect = feedback.defect, !FeedbackData.isNoDefect(defect) {
            return directionFromDefect(defect)
        }
        
        // Weighted voting from gaps
        // Weights: Bitterness has highest signal (users hate bitter), then acidity, then sweetness
        let weights: [String: Double] = [
            "bitterness": 3.0,
            "acidity": 2.0,
            "sweetness": 1.5,
            "body": 1.0
        ]
        
        var increaseVotes: Double = 0  // Under-extracted signals
        var decreaseVotes: Double = 0  // Over-extracted signals
        
        for gap in gaps where gap.significance != .negligible {
            let weight = weights[gap.dimension] ?? 1.0
            let signalStrength = Double(gap.significance.weight) * weight
            
            switch gap.dimension {
            case "bitterness":
                // High bitterness = over-extraction → decrease
                if gap.isOver { decreaseVotes += signalStrength }
            case "acidity":
                // Low acidity = under-extraction → increase
                if gap.isUnder { increaseVotes += signalStrength }
                // High acidity with low sweetness = also under → increase
                if gap.isOver { decreaseVotes += signalStrength * 0.5 }
            case "sweetness":
                // Low sweetness = under-extraction → increase
                if gap.isUnder { increaseVotes += signalStrength }
            case "body":
                // Body is more about strength than extraction
                if gap.isUnder { increaseVotes += signalStrength * 0.3 }
                if gap.isOver { decreaseVotes += signalStrength * 0.3 }
            default:
                break
            }
        }
        
        // Determine winner
        let totalVotes = increaseVotes + decreaseVotes
        
        if totalVotes < 1.0 {
            // No significant signals
            return (.balanced, 0.5)
        }
        
        let confidence = min(1.0, abs(increaseVotes - decreaseVotes) / totalVotes + 0.4)
        
        if increaseVotes > decreaseVotes * 1.2 {
            return (.increase, confidence)
        } else if decreaseVotes > increaseVotes * 1.2 {
            return (.decrease, confidence)
        } else {
            // Close call - use bitterness as tie-breaker (users hate bitter more)
            let bitternessGap = gaps.first { $0.dimension == "bitterness" }
            if let bg = bitternessGap, bg.isOver && bg.significance.weight >= 2 {
                return (.decrease, confidence * 0.8)
            }
            return (.balanced, 0.5)
        }
    }
    
    private func determineDirectionWithoutContext(actual: ActualTasteProfile, feedback: FeedbackData) -> (ExtractionDirection, Double) {
        // Check explicit defect
        if let defect = feedback.defect, !FeedbackData.isNoDefect(defect) {
            return directionFromDefect(defect)
        }
        
        // Infer from absolute taste values
        if actual.bitterness > 0.6 && actual.acidity < 0.4 {
            return (.decrease, 0.7)
        }
        if actual.acidity > 0.6 && actual.sweetness < 0.3 {
            return (.increase, 0.7)
        }
        if actual.acidity < 0.3 && actual.sweetness < 0.3 && actual.bitterness < 0.3 {
            return (.adjustStrength, 0.6)
        }
        
        return (.balanced, 0.5)
    }
    
    private func directionFromDefect(_ defect: String) -> (ExtractionDirection, Double) {
        switch defect {
        case "Sour/Tart": return (.increase, 0.85)
        case "Bitter/Dry": return (.decrease, 0.85)
        case "Weak/Watery": return (.adjustStrength, 0.8)
        case "Strong/Heavy": return (.adjustStrength, 0.8)
        case "Hollow": return (.improveTechnique, 0.75)
        default: return (.balanced, 0.5)
        }
    }
    
    // MARK: - Aligned Adjustment Generation
    
    private func generateAlignedAdjustments(
        direction: ExtractionDirection,
        method: String,
        gaps: [TasteGap],
        coffee: Coffee
    ) -> [AdjustmentItem] {
        var items: [AdjustmentItem] = []
        
        switch direction {
        case .increase:
            items = generateIncreaseExtractionAdjustments(method: method, coffee: coffee)
        case .decrease:
            items = generateDecreaseExtractionAdjustments(method: method, coffee: coffee)
        case .adjustStrength:
            items = generateStrengthAdjustments(method: method)
        case .improveTechnique:
            items = generateTechniqueAdjustments(method: method)
        case .balanced:
            items = generateBalancedAdjustments(method: method, gaps: gaps)
        }
        
        // Sort by impact (based on method rankings)
        return items.sorted { $0.rank < $1.rank }
    }
    
    private func generateGenericAdjustments(direction: ExtractionDirection, method: String) -> [AdjustmentItem] {
        switch direction {
        case .increase:
            return generateIncreaseExtractionAdjustments(method: method, coffee: nil)
        case .decrease:
            return generateDecreaseExtractionAdjustments(method: method, coffee: nil)
        case .adjustStrength:
            return generateStrengthAdjustments(method: method)
        case .improveTechnique:
            return generateTechniqueAdjustments(method: method)
        case .balanced:
            return []
        }
    }
    
    // MARK: - Direction-Specific Adjustments
    
    private func generateIncreaseExtractionAdjustments(method: String, coffee: Coffee?) -> [AdjustmentItem] {
        let grindRank = MethodImpactRankings.getRank(for: .grind, method: method)
        let tempRank = MethodImpactRankings.getRank(for: .temperature, method: method)
        let timeRank = MethodImpactRankings.getRank(for: .time, method: method)
        let techniqueRank = MethodImpactRankings.getRank(for: .technique, method: method)
        
        var items: [AdjustmentItem] = []
        
        // Grind finer - always included for under-extraction
        items.append(AdjustmentItem(
            rank: grindRank,
            category: .grind,
            parameter: "Grind Size",
            suggestedChange: "Grind 2 clicks finer",
            impactPercent: MethodImpactRankings.rankToImpactPercent(grindRank),
            explanation: "Finer grind increases surface area, allowing more extraction"
        ))
        
        // Temperature - especially important for light roasts
        let tempChange = coffee?.roastLevel == .light ? "Increase to 96-98°C" : "Increase by 2-3°C"
        items.append(AdjustmentItem(
            rank: tempRank,
            category: .temperature,
            parameter: "Water Temperature",
            suggestedChange: tempChange,
            impactPercent: MethodImpactRankings.rankToImpactPercent(tempRank),
            explanation: "Hotter water extracts compounds faster and more completely"
        ))
        
        // Time - method specific
        let timeChange: String
        if method.contains("AeroPress") {
            timeChange = "Steep 30 seconds longer"
        } else if method.contains("French") {
            timeChange = "Steep 1-2 minutes longer"
        } else {
            timeChange = "Extend total brew time"
        }
        items.append(AdjustmentItem(
            rank: timeRank,
            category: .time,
            parameter: "Brew Time",
            suggestedChange: timeChange,
            impactPercent: MethodImpactRankings.rankToImpactPercent(timeRank),
            explanation: "More time allows more flavor compounds to dissolve"
        ))
        
        // Technique - pour-over specific
        if method.contains("V60") || method.contains("Chemex") {
            items.append(AdjustmentItem(
                rank: techniqueRank,
                category: .technique,
                parameter: "Pour Technique",
                suggestedChange: "Pour slower and more deliberately",
                impactPercent: MethodImpactRankings.rankToImpactPercent(techniqueRank),
                explanation: "Slower pours increase contact time with the coffee bed"
            ))
        }
        
        return items
    }
    
    private func generateDecreaseExtractionAdjustments(method: String, coffee: Coffee?) -> [AdjustmentItem] {
        let grindRank = MethodImpactRankings.getRank(for: .grind, method: method)
        let tempRank = MethodImpactRankings.getRank(for: .temperature, method: method)
        let timeRank = MethodImpactRankings.getRank(for: .time, method: method)
        let techniqueRank = MethodImpactRankings.getRank(for: .technique, method: method)
        
        var items: [AdjustmentItem] = []
        
        // Grind coarser
        items.append(AdjustmentItem(
            rank: grindRank,
            category: .grind,
            parameter: "Grind Size",
            suggestedChange: "Grind 2 clicks coarser",
            impactPercent: MethodImpactRankings.rankToImpactPercent(grindRank),
            explanation: "Coarser grind reduces surface area, preventing over-extraction"
        ))
        
        // Lower temperature
        let tempChange = coffee?.roastLevel == .dark ? "Lower to 88-90°C" : "Lower by 3-4°C"
        items.append(AdjustmentItem(
            rank: tempRank,
            category: .temperature,
            parameter: "Water Temperature",
            suggestedChange: tempChange,
            impactPercent: MethodImpactRankings.rankToImpactPercent(tempRank),
            explanation: "Cooler water extracts more gently, avoiding bitter compounds"
        ))
        
        // Reduce time
        let timeChange: String
        if method.contains("AeroPress") {
            timeChange = "Reduce steep time by 30 seconds"
        } else if method.contains("French") {
            timeChange = "Steep 1 minute less"
        } else {
            timeChange = "Reduce total brew time"
        }
        items.append(AdjustmentItem(
            rank: timeRank,
            category: .time,
            parameter: "Brew Time",
            suggestedChange: timeChange,
            impactPercent: MethodImpactRankings.rankToImpactPercent(timeRank),
            explanation: "Less time stops extraction before bitter compounds release"
        ))
        
        // Technique - pour-over specific
        if method.contains("V60") || method.contains("Chemex") {
            items.append(AdjustmentItem(
                rank: techniqueRank,
                category: .technique,
                parameter: "Pour Technique",
                suggestedChange: "Pour faster with less agitation",
                impactPercent: MethodImpactRankings.rankToImpactPercent(techniqueRank),
                explanation: "Faster pours reduce contact time and extraction"
            ))
        }
        
        return items
    }
    
    private func generateStrengthAdjustments(method: String) -> [AdjustmentItem] {
        let doseRank = MethodImpactRankings.getRank(for: .dose, method: method)
        let ratioRank = MethodImpactRankings.getRank(for: .ratio, method: method)
        
        return [
            AdjustmentItem(
                rank: min(doseRank, ratioRank),
                category: .dose,
                parameter: "Coffee Dose",
                suggestedChange: "Adjust dose by 1-2 grams",
                impactPercent: MethodImpactRankings.rankToImpactPercent(doseRank),
                explanation: "More coffee = stronger, less = lighter. Ratio is key."
            ),
            AdjustmentItem(
                rank: max(doseRank, ratioRank),
                category: .ratio,
                parameter: "Brew Ratio",
                suggestedChange: "Try 1:15 for stronger, 1:17 for lighter",
                impactPercent: MethodImpactRankings.rankToImpactPercent(ratioRank),
                explanation: "Ratio controls final cup strength without changing extraction"
            )
        ]
    }
    
    private func generateTechniqueAdjustments(method: String) -> [AdjustmentItem] {
        let techniqueRank = MethodImpactRankings.getRank(for: .technique, method: method)
        
        var items: [AdjustmentItem] = []
        
        if method.contains("V60") || method.contains("Chemex") {
            items.append(AdjustmentItem(
                rank: techniqueRank,
                category: .technique,
                parameter: "Distribution",
                suggestedChange: "Swirl during bloom for even saturation",
                impactPercent: 80,
                explanation: "Even saturation prevents channeling and hollow cups"
            ))
            items.append(AdjustmentItem(
                rank: techniqueRank + 1,
                category: .technique,
                parameter: "Pour Pattern",
                suggestedChange: "Pour in concentric circles, center to edge",
                impactPercent: 70,
                explanation: "Consistent pattern ensures all grounds extract equally"
            ))
        } else if method.contains("AeroPress") {
            items.append(AdjustmentItem(
                rank: techniqueRank,
                category: .technique,
                parameter: "Stirring",
                suggestedChange: "Stir more thoroughly after adding water",
                impactPercent: 75,
                explanation: "Even saturation prevents dry pockets and channeling"
            ))
        } else if method.contains("French") {
            items.append(AdjustmentItem(
                rank: techniqueRank,
                category: .technique,
                parameter: "Initial Stir",
                suggestedChange: "Break crust and stir at 4 minutes",
                impactPercent: 70,
                explanation: "Breaking crust ensures all grounds participate in extraction"
            ))
        }
        
        return items
    }
    
    private func generateBalancedAdjustments(method: String, gaps: [TasteGap]) -> [AdjustmentItem] {
        // Minor tweaks only - find the single largest gap and address it
        let largestGap = gaps.filter { $0.significance != .negligible }
            .max { $0.significance.weight < $1.significance.weight }
        
        guard let gap = largestGap else { return [] }
        
        let rank = MethodImpactRankings.getRank(for: .grind, method: method)
        
        if gap.dimension == "bitterness" && gap.isOver {
            return [AdjustmentItem(
                rank: rank,
                category: .grind,
                parameter: "Grind Size",
                suggestedChange: "Grind 1 click coarser for less bitterness",
                impactPercent: 50,
                explanation: "Small adjustment to reduce slight over-extraction"
            )]
        } else if gap.dimension == "acidity" && gap.isUnder {
            return [AdjustmentItem(
                rank: rank,
                category: .grind,
                parameter: "Grind Size",
                suggestedChange: "Grind 1 click finer for more brightness",
                impactPercent: 50,
                explanation: "Small adjustment to increase slight under-extraction"
            )]
        }
        
        return []
    }
    
    // MARK: - Brew Execution Integration
    
    /// Adjust confidence based on how closely the user followed the recipe
    private func adjustConfidenceForExecution(baseConfidence: Double, feedback: FeedbackData) -> Double {
        var multiplier: Double = 1.0
        
        // Adjust based on whether recipe was followed
        if let followed = feedback.followedRecipe {
            switch followed.lowercased() {
            case "yes": multiplier *= 1.0
            case "mostly": multiplier *= 0.9
            case "no": multiplier *= 0.7
            default: break
            }
        }
        
        return min(1.0, baseConfidence * multiplier)
    }
    
    /// Adjust adjustments based on brew execution issues
    private func adjustAdjustmentsForExecution(
        _ adjustments: [AdjustmentItem],
        feedback: FeedbackData,
        method: String
    ) -> [AdjustmentItem] {
        var adjusted = adjustments
        
        // If brew time was too long, prioritize reducing time adjustments
        if feedback.brewTimeMatch == "Too long" {
            // Boost time reduction adjustments
            adjusted = adjusted.map { item in
                if item.category == .time && item.suggestedChange.lowercased().contains("reduce") {
                    return AdjustmentItem(
                        rank: max(1, item.rank - 1),  // Higher priority
                        category: item.category,
                        parameter: item.parameter,
                        currentValue: item.currentValue,
                        suggestedChange: item.suggestedChange,
                        impactPercent: min(100, item.impactPercent + 10),
                        explanation: item.explanation + " (Your brew time was too long)"
                    )
                }
                return item
            }
        }
        
        // If brew time was too short, prioritize increasing time adjustments
        if feedback.brewTimeMatch == "A bit short" {
            adjusted = adjusted.map { item in
                if item.category == .time && item.suggestedChange.lowercased().contains("extend") {
                    return AdjustmentItem(
                        rank: max(1, item.rank - 1),
                        category: item.category,
                        parameter: item.parameter,
                        currentValue: item.currentValue,
                        suggestedChange: item.suggestedChange,
                        impactPercent: min(100, item.impactPercent + 10),
                        explanation: item.explanation + " (Your brew time was a bit short)"
                    )
                }
                return item
            }
        }
        
        // If flow rate was too fast (pour-over methods), add technique suggestion
        if feedback.flowRate == "Too fast" && (method.contains("V60") || method.contains("Chemex")) {
            let techniqueItem = AdjustmentItem(
                rank: adjustments.count + 1,
                category: .technique,
                parameter: "Pour Technique",
                suggestedChange: "Pour slower and more deliberately",
                impactPercent: 60,
                explanation: "Your flow rate was too fast - slower pours increase extraction"
            )
            adjusted.append(techniqueItem)
        }
        
        // If flow rate was too slow, suggest coarser grind
        if feedback.flowRate == "Too slow" {
            adjusted = adjusted.map { item in
                if item.category == .grind && item.suggestedChange.lowercased().contains("coarser") {
                    return AdjustmentItem(
                        rank: max(1, item.rank - 1),
                        category: item.category,
                        parameter: item.parameter,
                        currentValue: item.currentValue,
                        suggestedChange: item.suggestedChange,
                        impactPercent: min(100, item.impactPercent + 10),
                        explanation: item.explanation + " (Your flow rate was too slow)"
                    )
                }
                return item
            }
        }
        
        // Re-sort by rank after adjustments
        return adjusted.sorted { $0.rank < $1.rank }
    }
    
    // MARK: - Helper Methods
    
    private func calculateGaps(expected: ExtractionCharacteristics, actual: ActualTasteProfile) -> [TasteGap] {
        return [
            TasteGap(dimension: "acidity", expected: expected.acidity, actual: actual.acidity),
            TasteGap(dimension: "sweetness", expected: expected.sweetness, actual: actual.sweetness),
            TasteGap(dimension: "body", expected: expected.body, actual: actual.body),
            TasteGap(dimension: "bitterness", expected: 1.0 - expected.clarity, actual: actual.bitterness)
        ]
    }
    
    private func assessmentFromDirection(_ direction: ExtractionDirection) -> ExtractionAssessment {
        switch direction {
        case .increase: return .underExtracted
        case .decrease: return .overExtracted
        case .adjustStrength: return .lowStrength
        case .improveTechnique: return .channeling
        case .balanced: return .balanced
        }
    }
    
    // MARK: - Flavor Tag Analysis
    
    /// Analyze which expected flavor tags were missing
    private func analyzeFlavorTagGaps(coffee: Coffee, experienced: Set<FlavorTag>) -> [FlavorTag] {
        let expectedSet = Set(coffee.flavorTags)
        let missingTags = expectedSet.subtracting(experienced)
        return Array(missingTags)
    }
    
    /// Generate recommendations for missing flavor tags
    private func generateFlavorTagRecommendations(
        coffee: Coffee,
        experiencedTags: Set<FlavorTag>,
        method: String
    ) -> [DimensionSpecificRecommendation] {
        guard !experiencedTags.isEmpty || !coffee.flavorTags.isEmpty else {
            return []
        }
        
        let missingTags = analyzeFlavorTagGaps(coffee: coffee, experienced: experiencedTags)
        guard !missingTags.isEmpty else {
            return []
        }
        
        var recommendations: [DimensionSpecificRecommendation] = []
        
        for tag in missingTags {
            let advice = getFlavorTagAdvice(for: tag, method: method)
            let adjustments = getFlavorTagAdjustments(for: tag, method: method)
            
            recommendations.append(DimensionSpecificRecommendation(
                dimension: "Flavor: \(tag.rawValue)",
                currentLevel: "Not experienced",
                targetLevel: "Expected",
                advice: advice,
                specificAdjustments: adjustments
            ))
        }
        
        return recommendations
    }
    
    private func getFlavorTagAdvice(for tag: FlavorTag, method: String) -> String {
        switch tag {
        // Acidic/Fruity tags need higher extraction
        case .fruity, .berry, .citrus, .stoneFruit, .tropical, .acidity, .bright, .vibrant, .juicy, .crisp:
            return "To bring out \(tag.rawValue.lowercased()) notes, you need more extraction. These bright, acidic compounds extract first."
        
        // Floral/Delicate tags need careful extraction
        case .floral, .tea, .herbaceous, .delicate, .elegant, .clean, .clarityFocused, .lightBodied:
            return "\(tag.rawValue) notes require careful extraction with high clarity. Ensure even extraction and proper grind."
        
        // Sweet/Rich tags need optimal extraction window
        case .nutty, .chocolate, .caramel, .vanilla, .sweet, .roasted, .rich, .syrupy, .creamy:
            return "To enhance \(tag.rawValue.lowercased()) notes, optimize your extraction window. Sweetness peaks in the middle extraction phase."
        
        // Fermented/Complex tags need balanced extraction
        case .fermented, .winey, .complex:
            return "\(tag.rawValue) notes require balanced extraction across all phases. Aim for medium-high extraction."
        
        // Bold/Heavy tags need controlled extraction
        case .spicy, .savory, .earthy, .bold, .intense, .strong, .fullBodied, .punchy, .espressoLike:
            return "\(tag.rawValue) notes need controlled extraction to avoid bitterness. Slightly coarser grind may help."
        
        // Body-focused tags
        case .thick, .deep, .layered:
            return "To achieve \(tag.rawValue.lowercased()) body, focus on longer extraction times and proper technique."
        
        default:
            return "To bring out \(tag.rawValue.lowercased()) notes, adjust your extraction parameters."
        }
    }
    
    private func getFlavorTagAdjustments(for tag: FlavorTag, method: String) -> [String] {
        var adjustments: [String] = []
        
        switch tag {
        // Acidic/Fruity tags
        case .fruity, .berry, .citrus, .stoneFruit, .tropical, .acidity, .bright, .vibrant, .juicy, .crisp:
            adjustments = [
                "Grind finer to increase surface area",
                "Increase water temperature by 2-3°C",
                "Extend brew time slightly"
            ]
            if method.contains("V60") || method.contains("Chemex") {
                adjustments.append("Pour slower for more contact time")
            }
        
        // Floral/Delicate tags
        case .floral, .tea, .herbaceous, .delicate, .elegant, .clean, .clarityFocused, .lightBodied:
            adjustments = [
                "Use slightly finer grind",
                "Maintain optimal water temperature (92-94°C)",
                "Ensure even extraction (proper agitation)"
            ]
            if method.contains("V60") || method.contains("Chemex") {
                adjustments.append("Use gentle, circular pours")
            }
        
        // Sweet/Rich tags
        case .nutty, .chocolate, .caramel, .vanilla, .sweet, .roasted, .rich, .syrupy, .creamy:
            adjustments = [
                "Optimize extraction window (not too fast, not too slow)",
                "Ensure even extraction throughout",
                "Maintain consistent water temperature"
            ]
        
        // Fermented/Complex tags
        case .fermented, .winey, .complex:
            adjustments = [
                "Use medium-fine grind",
                "Maintain steady extraction (consistent pours)",
                "Allow full brew time for complete extraction"
            ]
        
        // Bold/Heavy tags
        case .spicy, .savory, .earthy, .bold, .intense, .strong, .fullBodied, .punchy, .espressoLike:
            adjustments = [
                "Use slightly coarser grind",
                "Reduce water temperature by 2-3°C",
                "Monitor brew time to avoid over-extraction"
            ]
        
        // Body-focused tags
        case .thick, .deep, .layered:
            if method.contains("AeroPress") {
                adjustments = ["Steep 30-60 seconds longer", "Use slightly finer grind"]
            } else if method.contains("French") {
                adjustments = ["Extend steep time by 1-2 minutes", "Use medium-coarse grind"]
            } else {
                adjustments = ["Extend total brew time", "Use slightly finer grind"]
            }
        
        default:
            adjustments = [
                "Adjust grind size based on extraction needs",
                "Optimize water temperature",
                "Fine-tune brew time"
            ]
        }
        
        return adjustments
    }
    
    // MARK: - Dimension-Specific Recommendations
    
    private func generateDimensionSpecificRecommendations(
        gaps: [TasteGap],
        method: String,
        coffee: Coffee?
    ) -> [DimensionSpecificRecommendation] {
        var recommendations: [DimensionSpecificRecommendation] = []
        
        for gap in gaps where gap.significance != .negligible {
            let currentLabel = valueToComparativeLabel(gap.actual)
            let targetLabel = valueToComparativeLabel(gap.expected)
            
            // Only generate recommendation if there's a meaningful gap
            if currentLabel != targetLabel {
                let advice = getDimensionAdvice(for: gap.dimension, gap: gap, method: method)
                let adjustments = getSpecificAdjustments(for: gap.dimension, gap: gap, method: method)
                
                recommendations.append(DimensionSpecificRecommendation(
                    dimension: gap.dimension.capitalized,
                    currentLevel: currentLabel,
                    targetLevel: targetLabel,
                    advice: advice,
                    specificAdjustments: adjustments
                ))
            }
        }
        
        return recommendations
    }
    
    private func generateDimensionRecommendationsFromActual(
        actual: ActualTasteProfile,
        method: String
    ) -> [DimensionSpecificRecommendation] {
        var recommendations: [DimensionSpecificRecommendation] = []
        
        // Check each dimension - if extreme (very low or very high), suggest improvements
        let dimensions: [(name: String, value: Double)] = [
            ("acidity", actual.acidity),
            ("sweetness", actual.sweetness),
            ("bitterness", actual.bitterness)
        ]
        
        for dim in dimensions {
            let currentLabel = valueToComparativeLabel(dim.value)
            // If not "Perfect", suggest adjustments
            if currentLabel != "Perfect" {
                let advice = getDimensionAdviceWithoutContext(for: dim.name, value: dim.value, method: method)
                let adjustments = getSpecificAdjustmentsWithoutContext(for: dim.name, value: dim.value, method: method)
                
                recommendations.append(DimensionSpecificRecommendation(
                    dimension: dim.name.capitalized,
                    currentLevel: currentLabel,
                    targetLevel: "Perfect",
                    advice: advice,
                    specificAdjustments: adjustments
                ))
            }
        }
        
        return recommendations
    }
    
    private func valueToComparativeLabel(_ value: Double) -> String {
        // Normalized 0-1 value to comparative label
        if value <= 0.25 {
            return "Not enough"
        } else if value >= 0.75 {
            return "Too much"
        } else {
            return "Perfect"
        }
    }
    
    private func getDimensionAdvice(for dimension: String, gap: TasteGap, method: String) -> String {
        let isUnder = gap.isUnder
        switch dimension {
        case "acidity":
            return isUnder ? "To increase acidity, you need more extraction. Acidity comes from lighter compounds that extract first." : "To reduce acidity, decrease extraction. The coffee is extracting too quickly or aggressively."
        case "sweetness":
            return isUnder ? "To increase sweetness, optimize your extraction window. Sweetness peaks in the middle extraction phase." : "Sweetness is overpowering - slightly decrease extraction to balance."
        case "bitterness":
            return isUnder ? "Bitterness is low, which is generally good. Maintain your current approach." : "To reduce bitterness, decrease extraction. Bitterness comes from over-extraction of harsh compounds."
        default:
            return "Adjust your brewing parameters to improve this dimension."
        }
    }
    
    private func getSpecificAdjustments(for dimension: String, gap: TasteGap, method: String) -> [String] {
        let isUnder = gap.isUnder
        var adjustments: [String] = []
        
        switch dimension {
        case "acidity":
            if isUnder {
                adjustments = ["Grind finer to increase surface area", "Increase water temperature by 2-3°C", "Extend brew time slightly"]
            } else {
                adjustments = ["Grind coarser", "Lower water temperature by 2-3°C", "Reduce brew time"]
            }
        case "sweetness":
            if isUnder {
                adjustments = ["Ensure even extraction (proper agitation)", "Use slightly finer grind", "Maintain optimal water temperature"]
            } else {
                adjustments = ["Slightly coarser grind", "Reduce brew time by 15-30 seconds"]
            }
        case "bitterness":
            if isUnder {
                adjustments = ["Maintain current parameters - bitterness is well-controlled"]
            } else {
                adjustments = ["Grind coarser to reduce extraction", "Lower temperature by 3-5°C", "Reduce brew time significantly"]
            }
        default:
            break
        }
        
        // Method-specific adjustments
        if method.contains("V60") || method.contains("Chemex") {
            if isUnder && dimension == "acidity" {
                adjustments.append("Pour slower for more contact time")
            }
        } else if method.contains("AeroPress") {
            if isUnder {
                adjustments.append("Steep 30-60 seconds longer")
            }
        }
        
        return adjustments
    }
    
    private func getDimensionAdviceWithoutContext(for dimension: String, value: Double, method: String) -> String {
        let isLow = value <= 0.25
        switch dimension {
        case "acidity":
            return isLow ? "Your coffee could use more acidity. Increase extraction to bring out brighter notes." : "The acidity is too strong. Decrease extraction to balance."
        case "sweetness":
            return isLow ? "To enhance sweetness, optimize your extraction window for balanced flavor." : "Sweetness is overpowering - slightly reduce extraction."
        case "bitterness":
            return isLow ? "Bitterness is well-controlled. Keep doing what you're doing!" : "Bitterness is too high. Decrease extraction to avoid harsh flavors."
        default:
            return "Adjust your brewing parameters."
        }
    }
    
    private func getSpecificAdjustmentsWithoutContext(for dimension: String, value: Double, method: String) -> [String] {
        let isLow = value <= 0.25
        // Create a temporary gap for the helper function
        // Expected is what we want (opposite of current if low, or lower if high)
        let expected = isLow ? 0.75 : 0.25
        let gap = TasteGap(dimension: dimension, expected: expected, actual: value)
        return getSpecificAdjustments(for: dimension, gap: gap, method: method)
    }
    
    private func generateSummary(direction: ExtractionDirection, coffee: Coffee) -> String {
        switch direction {
        case .increase:
            return "Your \(coffee.name) needs more extraction to bring out its full potential"
        case .decrease:
            return "Your \(coffee.name) is over-extracted - dial back for a cleaner cup"
        case .adjustStrength:
            return "Extraction looks good - adjust your ratio for better strength"
        case .improveTechnique:
            return "Focus on even water distribution for more balanced extraction"
        case .balanced:
            return "Your brew is well-balanced! Only minor tweaks suggested"
        }
    }
}
