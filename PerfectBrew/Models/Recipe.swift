import Foundation

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
    let servings: Int // Nueva propiedad para cantidad de personas
    
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
    }
    
    // Backward compatibility - if only 'steps' is provided, treat them as brewing steps
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        brewingMethod = try container.decode(String.self, forKey: .brewingMethod)
        skillLevel = try container.decode(String.self, forKey: .skillLevel)
        rating = try container.decode(Double.self, forKey: .rating)
        parameters = try container.decode(RecipeBrewParameters.self, forKey: .parameters)
        equipment = try container.decode([String].self, forKey: .equipment)
        notes = try container.decode(String.self, forKey: .notes)
        servings = try container.decodeIfPresent(Int.self, forKey: .servings) ?? 1 // Default a 1 persona
        
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
    }
    
    // Regular initializer for creating instances in previews and tests
    init(title: String, brewingMethod: String, skillLevel: String, rating: Double, parameters: RecipeBrewParameters, preparationSteps: [String], brewingSteps: [BrewingStep], equipment: [String], notes: String, servings: Int = 1) {
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
    }
    
    // Función para escalar la receta según la cantidad de personas
    func scaledForServings(_ newServings: Int) -> Recipe {
        guard newServings > 0 && newServings <= 4 else { return self }
        
        print("DEBUG: Scaling recipe '\(title)' from \(servings) to \(newServings) servings")
        print("DEBUG: Original coffee: \(parameters.coffeeGrams)g, water: \(parameters.waterGrams)g")
        
        // Si la receta ya está diseñada para la cantidad de personas solicitada, no escalar
        if servings == newServings {
            print("DEBUG: Recipe already designed for \(newServings) servings, returning as-is")
            return self
        }
        
        // Si la receta está diseñada para más personas de las solicitadas, escalar hacia abajo
        let scaleFactor = Double(newServings) / Double(servings)
        print("DEBUG: Scale factor: \(scaleFactor)")
        
        // Escalar parámetros de la receta
        let scaledParameters = RecipeBrewParameters(
            coffeeGrams: parameters.coffeeGrams * scaleFactor,
            waterGrams: parameters.waterGrams * scaleFactor,
            ratio: parameters.ratio,
            grindSize: adjustGrindSizeForServings(parameters.grindSize, servings: newServings),
            temperatureCelsius: parameters.temperatureCelsius,
            bloomWaterGrams: parameters.bloomWaterGrams * scaleFactor,
            bloomTimeSeconds: adjustStepTime(parameters.bloomTimeSeconds, servings: newServings),
            totalBrewTimeSeconds: adjustStepTime(parameters.totalBrewTimeSeconds, servings: newServings)
        )
        
        // Escalar pasos de preparación de manera inteligente
        let scaledPreparationSteps = preparationSteps.map { step in
            scalePreparationStepIntelligently(step, scaleFactor: scaleFactor, originalCoffee: parameters.coffeeGrams, originalWater: parameters.waterGrams)
        }
        
        // Escalar pasos de preparación de manera inteligente
        let scaledBrewingSteps = brewingSteps.map { step in
            BrewingStep(
                timeSeconds: adjustStepTime(step.timeSeconds, servings: newServings),
                instruction: scaleBrewingStepIntelligently(step.instruction, scaleFactor: scaleFactor, originalCoffee: parameters.coffeeGrams, originalWater: parameters.waterGrams)
            )
        }
        
        print("DEBUG: Scaled coffee: \(scaledParameters.coffeeGrams)g, water: \(scaledParameters.waterGrams)g")
        
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
            servings: newServings
        )
    }
    
    // Función auxiliar para ajustar el tamaño del molido según la cantidad de personas
    private func adjustGrindSizeForServings(_ originalGrindSize: String, servings: Int) -> String {
        if servings <= 2 {
            return originalGrindSize
        } else if servings == 3 {
            // Para 3 personas, hacer el molido ligeramente más grueso
            return originalGrindSize.replacingOccurrences(of: "fine", with: "medium-fine", options: .caseInsensitive)
                .replacingOccurrences(of: "medium-fine", with: "medium", options: .caseInsensitive)
        } else {
            // Para 4 personas, hacer el molido más grueso
            return originalGrindSize.replacingOccurrences(of: "fine", with: "medium", options: .caseInsensitive)
                .replacingOccurrences(of: "medium-fine", with: "medium-coarse", options: .caseInsensitive)
                .replacingOccurrences(of: "medium", with: "medium-coarse", options: .caseInsensitive)
        }
    }
    
    // Función auxiliar para ajustar el tiempo de bloom
    private func adjustBloomTimeForServings(_ originalTime: Int, servings: Int) -> Int {
        if servings <= 2 {
            return originalTime
        } else if servings == 3 {
            return originalTime + 15 // 15 segundos más
        } else {
            return originalTime + 30 // 30 segundos más
        }
    }
    
    // Función auxiliar para ajustar el tiempo total de preparación
    private func adjustBrewTimeForServings(_ originalTime: Int, servings: Int) -> Int {
        if servings <= 2 {
            return originalTime
        } else if servings == 3 {
            return originalTime + 30 // 30 segundos más
        } else {
            return originalTime + 60 // 1 minuto más
        }
    }
    
    // Función auxiliar para ajustar el tiempo de cada paso
    private func adjustStepTime(_ originalTime: Int, servings: Int) -> Int {
        if servings <= 2 {
            return originalTime
        } else if servings == 3 {
            return Int(Double(originalTime) * 1.2) // 20% más de tiempo
        } else {
            return Int(Double(originalTime) * 1.4) // 40% más de tiempo
        }
    }
    
    // Función auxiliar para escalar pasos de preparación
    private func scalePreparationStep(_ step: String, scaleFactor: Double) -> String {
        // Buscar números en el texto y escalarlos
        var scaledStep = step
        
        print("DEBUG: Scaling step: '\(step)' with factor: \(scaleFactor)")
        
        // Patrones específicos para cantidades de café y agua
        let coffeePatterns = [
            (regex: "Grind\\s+(\\d+)\\s+grams?\\s+of\\s+coffee", unit: "grams of coffee"),
            (regex: "Moler\\s+(\\d+)\\s+gramos?\\s+de\\s+café", unit: "gramos de café"),
            (regex: "Add\\s+(\\d+)\\s+grams?\\s+of\\s+ground\\s+coffee", unit: "grams of ground coffee"),
            (regex: "Agregar\\s+(\\d+)\\s+gramos?\\s+de\\s+café\\s+molido", unit: "gramos de café molido"),
            (regex: "\\b(\\d+)\\s*g\\s+of\\s+coffee\\b", unit: "g of coffee"),
            (regex: "\\b(\\d+)\\s*gramos\\s+de\\s+café\\b", unit: "gramos de café"),
            (regex: "\\b(\\d+)\\s*grams\\s+of\\s+coffee\\b", unit: "grams of coffee"),
            (regex: "\\b(\\d+)\\s*g\\s+café\\b", unit: "g café"),
            (regex: "\\b(\\d+)\\s*g\\s+coffee\\b", unit: "g coffee")
        ]
        
        let waterPatterns = [
            (regex: "Pour\\s+(\\d+)\\s*mL\\s+of\\s+water", unit: "mL of water"),
            (regex: "Verter\\s+(\\d+)\\s*mL\\s+de\\s+agua", unit: "mL de agua"),
            (regex: "Bloom:\\s+Pour\\s+(\\d+)\\s*mL\\s+of\\s+water", unit: "mL of water"),
            (regex: "Bloom:\\s+Verter\\s+(\\d+)\\s*mL\\s+de\\s+agua", unit: "mL de agua"),
            (regex: "\\b(\\d+)\\s*ml\\s+of\\s+water\\b", unit: "ml of water"),
            (regex: "\\b(\\d+)\\s*mL\\s+of\\s+water\\b", unit: "mL of water"),
            (regex: "\\b(\\d+)\\s*ml\\s+de\\s+agua\\b", unit: "ml de agua"),
            (regex: "\\b(\\d+)\\s*mL\\s+de\\s+agua\\b", unit: "mL de agua")
        ]
        
        // Escalar cantidades de café
        for pattern in coffeePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern.regex, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: scaledStep.utf16.count)
                let matches = regex.matches(in: scaledStep, options: [], range: range)
                
                for match in matches.reversed() {
                    if let range = Range(match.range(at: 1), in: scaledStep) {
                        let number = Double(scaledStep[range]) ?? 0
                        let scaledNumber = number * scaleFactor
                        let roundedNumber = Int(round(scaledNumber))
                        
                        print("DEBUG: Found coffee amount \(number), scaling to \(roundedNumber)")
                        scaledStep.replaceSubrange(range, with: "\(roundedNumber)")
                    }
                }
            }
        }
        
        // Escalar cantidades de agua
        for pattern in waterPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern.regex, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: scaledStep.utf16.count)
                let matches = regex.matches(in: scaledStep, options: [], range: range)
                
                for match in matches.reversed() {
                    if let range = Range(match.range(at: 1), in: scaledStep) {
                        let number = Double(scaledStep[range]) ?? 0
                        let scaledNumber = number * scaleFactor
                        let roundedNumber = Int(round(scaledNumber))
                        
                        print("DEBUG: Found water amount \(number), scaling to \(roundedNumber)")
                        scaledStep.replaceSubrange(range, with: "\(roundedNumber)")
                    }
                }
            }
        }
        
        print("DEBUG: Scaled step result: '\(scaledStep)'")
        return scaledStep
    }
    
    // Función auxiliar para escalar pasos de preparación
    private func scaleBrewingStep(_ step: String, scaleFactor: Double) -> String {
        // Similar a scalePreparationStep pero para pasos de preparación
        return scalePreparationStep(step, scaleFactor: scaleFactor)
    }
    
    // Función auxiliar para escalar pasos de preparación de manera inteligente
    private func scalePreparationStepIntelligently(_ step: String, scaleFactor: Double, originalCoffee: Double, originalWater: Double) -> String {
        var scaledStep = step
        
        print("DEBUG: Intelligently scaling step: '\(step)' with factor: \(scaleFactor)")
        
        // Solo escalar números que coincidan exactamente con las cantidades originales de café o agua
        let coffeeAmount = Int(originalCoffee)
        let waterAmount = Int(originalWater)
        
        // Escalar cantidad de café usando regex más robusto
        let coffeeRegex = "\\b\(coffeeAmount)\\s*(?:grams?|g)\\s+of\\s+coffee\\b"
        if let regex = try? NSRegularExpression(pattern: coffeeRegex, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: scaledStep.utf16.count)
            let matches = regex.matches(in: scaledStep, options: [], range: range)
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: scaledStep) {
                    let scaledAmount = Int(Double(coffeeAmount) * scaleFactor)
                    let replacement = scaledStep[range].replacingOccurrences(of: "\(coffeeAmount)", with: "\(scaledAmount)")
                    scaledStep.replaceSubrange(range, with: replacement)
                    print("DEBUG: Scaled coffee amount from \(coffeeAmount) to \(scaledAmount)")
                }
            }
        }
        
        // Escalar cantidad de agua usando regex más robusto
        let waterRegex = "\\b\(waterAmount)\\s*(?:grams?|g|ml|mL)\\s+of\\s+water\\b"
        if let regex = try? NSRegularExpression(pattern: waterRegex, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: scaledStep.utf16.count)
            let matches = regex.matches(in: scaledStep, options: [], range: range)
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: scaledStep) {
                    let scaledAmount = Int(Double(waterAmount) * scaleFactor)
                    let replacement = scaledStep[range].replacingOccurrences(of: "\(waterAmount)", with: "\(scaledAmount)")
                    scaledStep.replaceSubrange(range, with: replacement)
                    print("DEBUG: Scaled water amount from \(waterAmount) to \(scaledAmount)")
                }
            }
        }
        
        print("DEBUG: Intelligently scaled step result: '\(scaledStep)'")
        return scaledStep
    }
    
    // Función auxiliar para escalar pasos de preparación de manera inteligente
    private func scaleBrewingStepIntelligently(_ step: String, scaleFactor: Double, originalCoffee: Double, originalWater: Double) -> String {
        return scalePreparationStepIntelligently(step, scaleFactor: scaleFactor, originalCoffee: originalCoffee, originalWater: originalWater)
    }
    
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
    
    enum CodingKeys: String, CodingKey {
        case timeSeconds = "time_seconds"
        case instruction
        case shortInstruction = "short_instruction"
        case audioFileName = "audio_file_name"
    }
    
    // Backward compatibility - if no short instruction or audio file is specified, they will be nil
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeSeconds = try container.decode(Int.self, forKey: .timeSeconds)
        instruction = try container.decode(String.self, forKey: .instruction)
        shortInstruction = try container.decodeIfPresent(String.self, forKey: .shortInstruction)
        audioFileName = try container.decodeIfPresent(String.self, forKey: .audioFileName)
    }
    
    // Convenience initializer for creating steps
    init(timeSeconds: Int, instruction: String, shortInstruction: String? = nil, audioFileName: String? = nil) {
        self.timeSeconds = timeSeconds
        self.instruction = instruction
        self.shortInstruction = shortInstruction
        self.audioFileName = audioFileName
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
        servings: 1
    )
}
