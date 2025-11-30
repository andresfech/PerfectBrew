import Foundation

struct WhatToExpect: Codable {
    let description: String
    let audioFileName: String?
    let audioScript: String?
    
    enum CodingKeys: String, CodingKey {
        case description
        case audioFileName = "audio_file_name"
        case audioScript = "audio_script"
    }
}

struct Recipe: Codable, Identifiable {
    var id = UUID()
    let title: String
    let brewingMethod: String
    let skillLevel: String
    let rating: Double
    let parameters: RecipeBrewParameters
    let preparationSteps: [String]
    let brewingSteps: [BrewingStep]
    let equipment: [String]
    let notes: String
    let servings: Int
    let whatToExpect: WhatToExpect?
    
    enum CodingKeys: String, CodingKey {
        case title
        case brewingMethod = "brewing_method"
        case skillLevel = "skill_level"
        case rating
        case parameters
        case preparationSteps = "preparation_steps"
        case brewingSteps = "brewing_steps"
        case steps // For backward compatibility in decoding only
        case equipment
        case notes
        case servings
        case whatToExpect = "what_to_expect"
    }
    
    // Backward compatibility - if only 'steps' is provided, treat them as brewing steps
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        brewingMethod = try container.decode(String.self, forKey: .brewingMethod)
        skillLevel = try container.decode(String.self, forKey: .skillLevel)
        rating = try container.decode(Double.self, forKey: .rating)
        parameters = try container.decode(RecipeBrewParameters.self, forKey: .parameters)
        equipment = try container.decodeIfPresent([String].self, forKey: .equipment) ?? []
        servings = try container.decodeIfPresent(Int.self, forKey: .servings) ?? 1
        
        // Decode what_to_expect first
        whatToExpect = try container.decodeIfPresent(WhatToExpect.self, forKey: .whatToExpect)
        
        // Use whatToExpect description for notes if available, otherwise fallback to notes field
        if let wte = whatToExpect {
            notes = wte.description
        } else {
            notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        }
        
        // Try to decode new structure first
        if let prepSteps = try? container.decode([String].self, forKey: .preparationSteps),
           let brewSteps = try? container.decode([BrewingStep].self, forKey: .brewingSteps) {
            preparationSteps = prepSteps
            brewingSteps = brewSteps
        } else {
            // Fallback to old structure - treat all steps as brewing steps
            let oldSteps = try container.decode([String].self, forKey: .steps)
            preparationSteps = []
            brewingSteps = oldSteps.enumerated().map { index, step in
                BrewingStep(
                    timeSeconds: index * 30, // Estimate timing
                    instruction: step
                )
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(brewingMethod, forKey: .brewingMethod)
        try container.encode(skillLevel, forKey: .skillLevel)
        try container.encode(rating, forKey: .rating)
        try container.encode(parameters, forKey: .parameters)
        try container.encode(preparationSteps, forKey: .preparationSteps)
        try container.encode(brewingSteps, forKey: .brewingSteps)
        try container.encode(equipment, forKey: .equipment)
        try container.encode(notes, forKey: .notes)
        try container.encode(servings, forKey: .servings)
        try container.encodeIfPresent(whatToExpect, forKey: .whatToExpect)
    }
    
    // Regular initializer for creating instances in previews and tests
    init(title: String, brewingMethod: String, skillLevel: String, rating: Double, parameters: RecipeBrewParameters, preparationSteps: [String], brewingSteps: [BrewingStep], equipment: [String], notes: String, servings: Int = 1, whatToExpect: WhatToExpect? = nil) {
        self.title = title
        self.brewingMethod = brewingMethod
        self.skillLevel = skillLevel
        self.rating = rating
        self.parameters = parameters
        self.preparationSteps = preparationSteps
        self.brewingSteps = brewingSteps
        self.equipment = equipment
        self.notes = notes
        self.servings = servings
        self.whatToExpect = whatToExpect
    }
    
    // MARK: - Dynamic Scaling Logic
    
    /// Scales the recipe parameters and instructions to match a target coffee dose.
    /// - Parameter targetCoffeeGrams: The desired amount of coffee in grams.
    /// - Returns: A new Recipe instance with scaled parameters and instructions.
    func scaled(to targetCoffeeGrams: Double) -> Recipe {
        // Avoid scaling if the target is the same (with small epsilon for float comparison)
        if abs(targetCoffeeGrams - parameters.coffeeGrams) < 0.1 {
            print("DEBUG: Target dose \(targetCoffeeGrams)g matches base recipe, returning as-is")
            return self
        }
        
        // Avoid scaling to unrealistic values
        let safeTarget = max(5.0, min(100.0, targetCoffeeGrams))
        let scaleFactor = safeTarget / parameters.coffeeGrams
        
        print("DEBUG: Scaling recipe '\(title)' from \(parameters.coffeeGrams)g to \(safeTarget)g (Factor: \(String(format: "%.2f", scaleFactor)))")
        
        // Scale numeric parameters
        let scaledParameters = RecipeBrewParameters(
            coffeeGrams: safeTarget,
            waterGrams: parameters.waterGrams * scaleFactor,
            ratio: parameters.ratio,
            grindSize: parameters.grindSize, // Keep grind size description static for now, or consider dynamic adjustment logic later
            temperatureCelsius: parameters.temperatureCelsius,
            bloomWaterGrams: parameters.bloomWaterGrams * scaleFactor,
            bloomTimeSeconds: parameters.bloomTimeSeconds, // Keep timing static for simplicity in this phase
            totalBrewTimeSeconds: parameters.totalBrewTimeSeconds // Keep timing static for simplicity in this phase
        )
        
        // Scale preparation steps text
        let scaledPreparationSteps = preparationSteps.map { step in
            scaleText(step, scaleFactor: scaleFactor, originalCoffee: parameters.coffeeGrams, originalWater: parameters.waterGrams)
        }
        
        // Scale brewing steps instructions
        let scaledBrewingSteps = brewingSteps.map { step in
            BrewingStep(
                timeSeconds: step.timeSeconds, // Keep timing static
                instruction: scaleText(step.instruction, scaleFactor: scaleFactor, originalCoffee: parameters.coffeeGrams, originalWater: parameters.waterGrams),
                shortInstruction: step.shortInstruction.map { scaleText($0, scaleFactor: scaleFactor, originalCoffee: parameters.coffeeGrams, originalWater: parameters.waterGrams) },
                audioFileName: step.audioFileName,
                audioScript: step.audioScript
            )
        }
        
        return Recipe(
            title: title,
            brewingMethod: brewingMethod,
            skillLevel: skillLevel,
            rating: rating,
            parameters: scaledParameters,
            preparationSteps: scaledPreparationSteps,
            brewingSteps: scaledBrewingSteps,
            equipment: equipment,
            notes: notes,
            servings: servings, // Deprecated concept, but keeping for model compatibility
            whatToExpect: whatToExpect
        )
    }
    
    /// Helper to scale numeric values found within instruction text.
    private func scaleText(_ text: String, scaleFactor: Double, originalCoffee: Double, originalWater: Double) -> String {
        var scaledText = text
        
        // Detect and scale coffee amounts (e.g., "15g", "15 g", "15 grams")
        // Using a heuristic: match numbers close to originalCoffee
        let coffeeInt = Int(originalCoffee)
        let coffeePattern = "\\b\(coffeeInt)\\s*(?:g|grams?)\\b"
        
        if let regex = try? NSRegularExpression(pattern: coffeePattern, options: .caseInsensitive) {
            let matches = regex.matches(in: scaledText, range: NSRange(scaledText.startIndex..., in: scaledText))
            // Iterate backwards to avoid range invalidation
            for match in matches.reversed() {
                if let range = Range(match.range, in: scaledText) {
                    let newAmount = Int(round(originalCoffee * scaleFactor))
                    // Replace only the number part, keep the unit
                    let originalString = String(scaledText[range])
                    let replacedString = originalString.replacingOccurrences(of: "\(coffeeInt)", with: "\(newAmount)")
                    scaledText.replaceSubrange(range, with: replacedString)
                }
            }
        }
        
        // Detect and scale water amounts (e.g., "250g", "250ml", "250 ml")
        // Using a heuristic: match numbers close to originalWater
        let waterInt = Int(originalWater)
        let waterPattern = "\\b\(waterInt)\\s*(?:g|ml|grams?|milliliters?)\\b"
        
        if let regex = try? NSRegularExpression(pattern: waterPattern, options: .caseInsensitive) {
            let matches = regex.matches(in: scaledText, range: NSRange(scaledText.startIndex..., in: scaledText))
            for match in matches.reversed() {
                if let range = Range(match.range, in: scaledText) {
                    let newAmount = Int(round(originalWater * scaleFactor))
                    let originalString = String(scaledText[range])
                    let replacedString = originalString.replacingOccurrences(of: "\(waterInt)", with: "\(newAmount)")
                    scaledText.replaceSubrange(range, with: replacedString)
                }
            }
        }
        
        // Also detect bloom water if distinct (e.g., "pour 30g for bloom")
        // This is a bit riskier if bloom amount == coffee amount, but acceptable for heuristic
        // Note: The previous implementation had specific patterns. We can keep using general pattern matching for numbers
        // but centered around known parameter values to reduce false positives.
        
        return scaledText
    }

    // DEPRECATED: Legacy scaling by servings count
    // Keeping temporarily to avoid breaking existing calls during migration
    func scaledForServings(_ newServings: Int) -> Recipe {
       // ... legacy logic ... 
       // For now, just return self or simple logic, as we are moving to gram-based scaling.
       // Ideally, we should map servings to grams (e.g. 1 -> base, 2 -> 2*base) and call scaled(to:)
       let targetGrams = parameters.coffeeGrams * Double(newServings) / Double(servings)
       return scaled(to: targetGrams)
    }
    
    /* Old implementation commented out for reference or deletion in cleanup phase
    func scaledForServings(_ newServings: Int) -> Recipe {
        guard newServings > 0 && newServings <= 4 else { return self }
        // ... (rest of old code)
    }
    */
    
    var difficulty: Difficulty {
        switch skillLevel.lowercased() {
        case "beginner":
            return .beginner
        case "intermediate":
            return .intermediate
        case "advanced":
            return .advanced
        default:
            return .beginner
        }
    }
    
    var difficultyColor: String {
        switch difficulty {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

struct BrewingStep: Codable {
    let timeSeconds: Int
    let instruction: String
    let shortInstruction: String? // Optional short, imperative instruction
    let audioFileName: String? // Optional audio file name for this step
    let audioScript: String? // Optional detailed narration text for TTS generation
    
    enum CodingKeys: String, CodingKey {
        case timeSeconds = "time_seconds"
        case instruction
        case shortInstruction = "short_instruction"
        case audioFileName = "audio_file_name"
        case audioScript = "audio_script"
    }
    
    // Backward compatibility - if no short instruction, audio file, or audio script is specified, they will be nil
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeSeconds = try container.decode(Int.self, forKey: .timeSeconds)
        instruction = try container.decode(String.self, forKey: .instruction)
        shortInstruction = try container.decodeIfPresent(String.self, forKey: .shortInstruction)
        audioFileName = try container.decodeIfPresent(String.self, forKey: .audioFileName)
        audioScript = try container.decodeIfPresent(String.self, forKey: .audioScript)
    }
    
    // Convenience initializer for creating steps
    init(timeSeconds: Int, instruction: String, shortInstruction: String? = nil, audioFileName: String? = nil, audioScript: String? = nil) {
        self.timeSeconds = timeSeconds
        self.instruction = instruction
        self.shortInstruction = shortInstruction
        self.audioFileName = audioFileName
        self.audioScript = audioScript
    }
}

struct BrewParameters: Codable {
    let coffeeDose: Double
    let waterAmount: Double
    let waterTemperature: Double
    let grindSize: Int
    let brewTime: TimeInterval
    
    static let sampleBrewParameters = BrewParameters(
        coffeeDose: 18.0,
        waterAmount: 190.0,
        waterTemperature: 95.0,
        grindSize: 7,
        brewTime: 180.0
    )
}

struct RecipeBrewParameters: Codable {
    let coffeeGrams: Double
    let waterGrams: Double
    let ratio: String
    let grindSize: String
    let temperatureCelsius: Double
    let bloomWaterGrams: Double
    let bloomTimeSeconds: Int
    let totalBrewTimeSeconds: Int
    
    enum CodingKeys: String, CodingKey {
        case coffeeGrams = "coffee_grams"
        case waterGrams = "water_grams"
        case ratio
        case grindSize = "grind_size"
        case temperatureCelsius = "temperature_celsius"
        case bloomWaterGrams = "bloom_water_grams"
        case bloomTimeSeconds = "bloom_time_seconds"
        case totalBrewTimeSeconds = "total_brew_time_seconds"
    }
}

enum Difficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

// Sample recipe for previews and fallback
extension Recipe {
    static let sampleRecipe = Recipe(
        title: "Sample V60",
        brewingMethod: "V60",
        skillLevel: "Beginner",
        rating: 4.5,
        parameters: RecipeBrewParameters(
            coffeeGrams: 16.0,
            waterGrams: 256.0,
            ratio: "1:16",
            grindSize: "Medium-fine (like table salt)",
            temperatureCelsius: 96.0,
            bloomWaterGrams: 40.0,
            bloomTimeSeconds: 45,
            totalBrewTimeSeconds: 210
        ),
        preparationSteps: [
            "Heat water to 96°C",
            "Place filter in V60 and rinse with hot water",
            "Add 16g of ground coffee"
        ],
        brewingSteps: [
            BrewingStep(timeSeconds: 0, instruction: "Bloom: Pour 40mL of water and swirl gently"),
            BrewingStep(timeSeconds: 45, instruction: "Main pour: Add remaining water in circular motion"),
            BrewingStep(timeSeconds: 120, instruction: "Final swirl to flatten the bed"),
            BrewingStep(timeSeconds: 210, instruction: "Enjoy your coffee!")
        ],
        equipment: ["V60", "Paper filter", "Kettle", "Scale", "Grinder"],
        notes: "A simple and delicious V60 recipe for beginners.",
        servings: 1,
        whatToExpect: nil
    )
}
