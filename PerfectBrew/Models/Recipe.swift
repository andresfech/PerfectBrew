import Foundation

struct WhatToExpect: Codable {
    let description: String
    let audioFileName: String?
    let audioScript: String?
    
    // Spanish localization fields (AEC-13)
    let descriptionEs: String?
    let audioFileNameEs: String?
    let audioScriptEs: String?
    
    enum CodingKeys: String, CodingKey {
        case description
        case audioFileName = "audio_file_name"
        case audioScript = "audio_script"
        // Spanish keys
        case descriptionEs = "description_es"
        case audioFileNameEs = "audio_file_name_es"
        case audioScriptEs = "audio_script_es"
    }
    
    // Backward compatible decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decode(String.self, forKey: .description)
        audioFileName = try container.decodeIfPresent(String.self, forKey: .audioFileName)
        audioScript = try container.decodeIfPresent(String.self, forKey: .audioScript)
        // Spanish fields (optional)
        descriptionEs = try container.decodeIfPresent(String.self, forKey: .descriptionEs)
        audioFileNameEs = try container.decodeIfPresent(String.self, forKey: .audioFileNameEs)
        audioScriptEs = try container.decodeIfPresent(String.self, forKey: .audioScriptEs)
    }
    
    // MARK: - Localized Accessors (AEC-13)
    
    /// Returns description in current language, falls back to English
    var localizedDescription: String {
        if LocalizationManager.shared.currentLanguage == .spanish,
           let es = descriptionEs, !es.isEmpty {
            return es
        }
        return description
    }
    
    /// Returns audio file name in current language, falls back to English
    var localizedAudioFileName: String? {
        if LocalizationManager.shared.currentLanguage == .spanish,
           let es = audioFileNameEs, !es.isEmpty {
            return es
        }
        return audioFileName
    }
    
    /// Returns audio script in current language, falls back to English
    var localizedAudioScript: String? {
        if LocalizationManager.shared.currentLanguage == .spanish,
           let es = audioScriptEs, !es.isEmpty {
            return es
        }
        return audioScript
    }
}

// MARK: - Recipe Profile (Match My Coffee)
struct RecipeProfile: Codable, Equatable {
    let recommendedRoastLevels: [RoastLevel]
    let recommendedProcesses: [Process]
    let recommendedFlavorTags: [FlavorTag]
    let recommendedOrigins: [String]?
    let recommendedVarieties: [String]?
    
    // Optional: Could add forgiveness, etc.
    
    enum CodingKeys: String, CodingKey {
        case recommendedRoastLevels = "recommended_roast_levels"
        case recommendedProcesses = "recommended_processes"
        case recommendedFlavorTags = "recommended_flavor_tags"
        case recommendedOrigins = "recommended_origins"
        case recommendedVarieties = "recommended_varieties"
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
    let recipeProfile: RecipeProfile?
    let extractionCharacteristics: ExtractionCharacteristics?
    
    // Spanish localization fields (AEC-13)
    let titleEs: String?
    let preparationStepsEs: [String]?
    let notesEs: String?
    
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
        case recipeProfile = "recipe_profile"
        case extractionCharacteristics = "extraction_characteristics"
        // Spanish keys
        case titleEs = "title_es"
        case preparationStepsEs = "preparation_steps_es"
        case notesEs = "notes_es"
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
        
        // Decode what_to_expect
        whatToExpect = try container.decodeIfPresent(WhatToExpect.self, forKey: .whatToExpect)
        
        // Decode recipe_profile (Legacy Match My Coffee metadata)
        recipeProfile = try container.decodeIfPresent(RecipeProfile.self, forKey: .recipeProfile)
        
        // Decode extraction_characteristics (New Brew Intent Engine)
        extractionCharacteristics = try container.decodeIfPresent(ExtractionCharacteristics.self, forKey: .extractionCharacteristics)
        
        // Use whatToExpect description for notes if available, otherwise fallback to notes field
        if let wte = whatToExpect {
            notes = wte.description
        } else {
            notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        }
        
        // Spanish fields (AEC-13)
        titleEs = try container.decodeIfPresent(String.self, forKey: .titleEs)
        preparationStepsEs = try container.decodeIfPresent([String].self, forKey: .preparationStepsEs)
        notesEs = try container.decodeIfPresent(String.self, forKey: .notesEs)
        
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
    
    // MARK: - Localized Accessors (AEC-13)
    
    /// Returns title in current language, falls back to English
    var localizedTitle: String {
        if LocalizationManager.shared.currentLanguage == .spanish,
           let es = titleEs, !es.isEmpty {
            return es
        }
        return title
    }
    
    /// Returns preparation steps in current language, falls back to English
    var localizedPreparationSteps: [String] {
        if LocalizationManager.shared.currentLanguage == .spanish,
           let es = preparationStepsEs, !es.isEmpty {
            return es
        }
        return preparationSteps
    }
    
    /// Returns notes in current language, falls back to English (or whatToExpect)
    var localizedNotes: String {
        if LocalizationManager.shared.currentLanguage == .spanish {
            // First try notesEs, then whatToExpect.descriptionEs
            if let es = notesEs, !es.isEmpty {
                return es
            }
            if let wte = whatToExpect, let descEs = wte.descriptionEs, !descEs.isEmpty {
                return descEs
            }
        }
        return notes
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
        try container.encodeIfPresent(recipeProfile, forKey: .recipeProfile)
        try container.encodeIfPresent(extractionCharacteristics, forKey: .extractionCharacteristics)
        // Spanish fields (AEC-13)
        try container.encodeIfPresent(titleEs, forKey: .titleEs)
        try container.encodeIfPresent(preparationStepsEs, forKey: .preparationStepsEs)
        try container.encodeIfPresent(notesEs, forKey: .notesEs)
    }
    
    // Regular initializer for creating instances in previews and tests
    init(
        title: String,
        brewingMethod: String,
        skillLevel: String,
        rating: Double,
        parameters: RecipeBrewParameters,
        preparationSteps: [String],
        brewingSteps: [BrewingStep],
        equipment: [String],
        notes: String,
        servings: Int = 1,
        whatToExpect: WhatToExpect? = nil,
        recipeProfile: RecipeProfile? = nil,
        extractionCharacteristics: ExtractionCharacteristics? = nil,
        titleEs: String? = nil,
        preparationStepsEs: [String]? = nil,
        notesEs: String? = nil
    ) {
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
        self.recipeProfile = recipeProfile
        self.extractionCharacteristics = extractionCharacteristics
        self.titleEs = titleEs
        self.preparationStepsEs = preparationStepsEs
        self.notesEs = notesEs
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
            whatToExpect: whatToExpect,
            recipeProfile: recipeProfile, // Preserve original profile (metadata doesn't change with scale)
            extractionCharacteristics: extractionCharacteristics
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

struct BrewingStep: Codable, Equatable {
    let timeSeconds: Int
    let instruction: String
    let shortInstruction: String? // Optional short, imperative instruction
    let audioFileName: String? // Optional audio file name for this step
    let audioScript: String? // Optional detailed narration text for TTS generation
    
    // Spanish localization fields (AEC-13)
    let instructionEs: String?
    let shortInstructionEs: String?
    let audioFileNameEs: String?
    let audioScriptEs: String?
    
    enum CodingKeys: String, CodingKey {
        case timeSeconds = "time_seconds"
        case instruction
        case shortInstruction = "short_instruction"
        case audioFileName = "audio_file_name"
        case audioScript = "audio_script"
        // Spanish keys
        case instructionEs = "instruction_es"
        case shortInstructionEs = "short_instruction_es"
        case audioFileNameEs = "audio_file_name_es"
        case audioScriptEs = "audio_script_es"
    }
    
    // Backward compatibility decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeSeconds = try container.decode(Int.self, forKey: .timeSeconds)
        instruction = try container.decode(String.self, forKey: .instruction)
        shortInstruction = try container.decodeIfPresent(String.self, forKey: .shortInstruction)
        audioFileName = try container.decodeIfPresent(String.self, forKey: .audioFileName)
        audioScript = try container.decodeIfPresent(String.self, forKey: .audioScript)
        // Spanish fields (optional)
        instructionEs = try container.decodeIfPresent(String.self, forKey: .instructionEs)
        shortInstructionEs = try container.decodeIfPresent(String.self, forKey: .shortInstructionEs)
        audioFileNameEs = try container.decodeIfPresent(String.self, forKey: .audioFileNameEs)
        audioScriptEs = try container.decodeIfPresent(String.self, forKey: .audioScriptEs)
    }
    
    // Convenience initializer for creating steps
    init(timeSeconds: Int, instruction: String, shortInstruction: String? = nil, audioFileName: String? = nil, audioScript: String? = nil, instructionEs: String? = nil, shortInstructionEs: String? = nil, audioFileNameEs: String? = nil, audioScriptEs: String? = nil) {
        self.timeSeconds = timeSeconds
        self.instruction = instruction
        self.shortInstruction = shortInstruction
        self.audioFileName = audioFileName
        self.audioScript = audioScript
        self.instructionEs = instructionEs
        self.shortInstructionEs = shortInstructionEs
        self.audioFileNameEs = audioFileNameEs
        self.audioScriptEs = audioScriptEs
    }
    
    // MARK: - Localized Accessors (AEC-13)
    
    /// Returns instruction in current language, falls back to English
    var localizedInstruction: String {
        if LocalizationManager.shared.currentLanguage == .spanish,
           let es = instructionEs, !es.isEmpty {
            return es
        }
        return instruction
    }
    
    /// Returns short instruction in current language, falls back to English
    var localizedShortInstruction: String? {
        if LocalizationManager.shared.currentLanguage == .spanish,
           let es = shortInstructionEs, !es.isEmpty {
            return es
        }
        return shortInstruction
    }
    
    /// Returns audio file name in current language, falls back to English
    var localizedAudioFileName: String? {
        if LocalizationManager.shared.currentLanguage == .spanish,
           let es = audioFileNameEs, !es.isEmpty {
            return es
        }
        return audioFileName
    }
    
    /// Returns audio script in current language, falls back to English
    var localizedAudioScript: String? {
        if LocalizationManager.shared.currentLanguage == .spanish,
           let es = audioScriptEs, !es.isEmpty {
            return es
        }
        return audioScript
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

struct RecipeBrewParameters: Codable, Equatable {
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
    
    var localizedName: String {
        switch self {
        case .beginner: return "beginner".localized
        case .intermediate: return "intermediate".localized
        case .advanced: return "advanced".localized
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
        whatToExpect: nil,
        recipeProfile: RecipeProfile(
            recommendedRoastLevels: [.medium],
            recommendedProcesses: [.washed, .natural],
            recommendedFlavorTags: [.nutty, .chocolate],
            recommendedOrigins: nil,
            recommendedVarieties: nil
        ),
        extractionCharacteristics: ExtractionCharacteristics(
            clarity: 0.8,
            acidity: 0.7,
            sweetness: 0.6,
            body: 0.4,
            agitation: .medium,
            thermal: .medium
        )
    )
}
