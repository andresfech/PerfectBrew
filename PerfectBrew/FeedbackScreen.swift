import SwiftUI

struct FeedbackScreen: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var storageService = StorageService()
    @State private var showingThankYou = false
    @State private var feedbackData = FeedbackData()
    @State private var showingRecommendations = false  // AEC-12
    @State private var diagnosticResult: BrewDiagnosticResult?  // AEC-12
    @State private var showingCoffeeSelection = false  // AEC-12
    @State private var showingTasteModal = false  // Phase 3: exertion-style taste modal
    @State private var expectedProfile: ExtractionCharacteristics? = nil  // Expected profile from coffee
    let recipe: Recipe
    let brewParameters: BrewParameters
    var coffee: Coffee? = nil  // AEC-12: Optional coffee for smart recommendations
    @State private var selectedCoffee: Coffee? = nil  // AEC-12: Local selection if not passed
    
    /// "Good outcome" value; stored in defect when user selects Balanced. Replaces "None (Balanced)".
    static let balancedValue = "Balanced"
    static let defectOptions = ["Sour/Tart", "Bitter/Dry", "Weak/Watery", "Strong/Heavy", "Hollow"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("perfect_brew".localized)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("rate_your_brew".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Recipe Info (AEC-13: localized title)
                VStack(spacing: 12) {
                    Text(formatRecipeTitle(recipe.localizedTitle))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(recipe.brewingMethod)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 10)
                
                // Coffee Selection Prompt (AEC-12)
                coffeeSelectionCard
                
                // Expected Profile Section (if coffee is selected)
                if let coffee = effectiveCoffee, let expected = expectedProfile {
                    ExpectedProfileCard(coffee: coffee, expectedProfile: expected)
                }
                
                // Overall Rating Section
                FeedbackSection(title: "overall_rating".localized) {
                    VStack(spacing: 20) {
                        OverallRatingQuestion(
                            id: "overall_rating",
                            label: "",
                            rating: $feedbackData.overallRating
                        )
                    }
                }
                
                // Brew Execution Section
                FeedbackSection(title: "brew_execution".localized) {
                    VStack(spacing: 20) {
                        MultipleChoiceQuestion(
                            id: "followed_recipe",
                            label: "followed_recipe_label".localized,
                            options: ["yes".localized, "mostly".localized, "no".localized],
                            selection: $feedbackData.followedRecipe
                        )
                        
                        MultipleChoiceQuestion(
                            id: "brew_time_match",
                            label: "brew_time_match_label".localized,
                            options: ["on_time".localized, "bit_short".localized, "too_long".localized],
                            selection: $feedbackData.brewTimeMatch
                        )
                        
                        MultipleChoiceQuestion(
                            id: "flow_rate",
                            label: "flow_rate_label".localized,
                            options: ["too_fast".localized, "just_right".localized, "too_slow".localized],
                            selection: $feedbackData.flowRate
                        )
                    }
                }
                
                // Result Section (AEC-11): Balanced as primary outcome, defects as "or had an issue?"
                FeedbackSection(title: "Result") {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How did it taste?")
                            .font(.headline)
                        
                        Button(action: { updateDefect(FeedbackScreen.balancedValue) }) {
                            HStack {
                                Image(systemName: isBalancedSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(isBalancedSelected ? .white : .secondary)
                                Text("Balanced")
                                    .font(.body)
                                    .fontWeight(isBalancedSelected ? .semibold : .regular)
                                Spacer()
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(isBalancedSelected ? Color.green : Color(.systemGray5))
                            .foregroundColor(isBalancedSelected ? .white : .primary)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        
                        Text("Or had an issue?")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(FeedbackScreen.defectOptions, id: \.self) { option in
                                Button(action: { updateDefect(option) }) {
                                    Text(option)
                                        .font(.caption)
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                        .background(feedbackData.defect == option ? Color.orange : Color(.systemGray5))
                                        .foregroundColor(feedbackData.defect == option ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                // Taste Profile Section (Phase 3: modal)
                FeedbackSection(title: "taste_profile".localized) {
                    Button(action: { showingTasteModal = true }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("rate_taste".localized)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("save_taste_subtitle".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color.orange.opacity(0.08))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .frame(minHeight: 44)
                    .accessibilityLabel("Open Taste Profile")
                    .accessibilityHint("Opens modal to rate acidity, sweetness, body")
                }
                
                // Flavor Notes Experienced Section (if coffee is selected)
                if let coffee = effectiveCoffee, !coffee.flavorTags.isEmpty {
                    FlavorTagFeedbackView(
                        coffee: coffee,
                        experiencedTags: $feedbackData.experiencedFlavorTags
                    )
                }
                
                // Adjustment Suggestions Section
                FeedbackSection(title: "adjustment_suggestions".localized) {
                    VStack(spacing: 20) {
                        MultipleChoiceQuestion(
                            id: "adjust_next_time",
                            label: "adjust_next_time_label".localized,
                            options: ["yes".localized, "no".localized],
                            selection: $feedbackData.adjustNextTime
                        )
                        
                        if feedbackData.adjustNextTime == "yes".localized {
                            CheckboxQuestion(
                                id: "adjustment_areas",
                                label: "adjustment_areas_label".localized,
                                options: ["grind_size".localized, "temperature".localized, "ratio".localized, "brew_time".localized, "pour_technique".localized],
                                selectedOptions: $feedbackData.adjustmentAreas
                            )
                        }
                        
                        TextAreaQuestion(
                            id: "additional_notes",
                            label: "additional_notes".localized,
                            text: $feedbackData.additionalNotes
                        )
                    }
                }
                
                // Submit Button
                Button(action: {
                    submitFeedback()
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.headline)
                        Text("submit_feedback".localized)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(canSubmit ? Color.orange : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!canSubmit)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("feedback".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCoffeeSelection) {
            CoffeeSelectionSheet(selectedCoffee: $selectedCoffee)
        }
        .sheet(isPresented: $showingTasteModal) {
            ExertionStyleTasteModal(feedbackData: $feedbackData, expectedProfile: expectedProfile)
        }
        .background(
            NavigationLink(
                destination: Group {
                    if let result = diagnosticResult {
                        BrewRecommendationsView(
                            result: result,
                            recipe: recipe,
                            coffee: effectiveCoffee
                        )
                    }
                },
                isActive: $showingRecommendations
            ) {
                EmptyView()
            }
        )
        .onAppear {
            // Initialize selectedCoffee from passed coffee
            if selectedCoffee == nil {
                selectedCoffee = coffee
            }
            // Calculate expected profile if coffee is available (force recalculation)
            DispatchQueue.main.async {
                calculateExpectedProfile()
            }
        }
        .onChange(of: effectiveCoffee) { _ in
            // Recalculate expected profile when coffee changes
            calculateExpectedProfile()
        }
    }
    
    // MARK: - Effective Coffee (AEC-12)
    
    private var effectiveCoffee: Coffee? {
        selectedCoffee ?? coffee
    }
    
    // MARK: - Expected Profile Calculation
    
    private func calculateExpectedProfile() {
        guard let coffee = effectiveCoffee else {
            expectedProfile = nil
            print("DEBUG: calculateExpectedProfile - No coffee available")
            return
        }
        print("DEBUG: calculateExpectedProfile - Computing profile for \(coffee.name)")
        expectedProfile = BrewingRuleEngine.shared.computeTargetProfile(for: coffee)
        print("DEBUG: calculateExpectedProfile - Profile calculated: acidity=\(expectedProfile?.acidity ?? 0), sweetness=\(expectedProfile?.sweetness ?? 0)")
    }
    
    // MARK: - Coffee Selection Card (AEC-12)
    
    private var coffeeSelectionCard: some View {
        VStack(spacing: 12) {
            // Always show coffee info if available, not just prompt
            if let coffee = effectiveCoffee {
                // Coffee is selected
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(coffee.name)
                            .font(.headline)
                        Text("\(coffee.roastLevel.rawValue) • \(coffee.process.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: { showingCoffeeSelection = true }) {
                        Text("Change")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            } else {
                // No coffee selected - prompt
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.orange)
                        Text("Which coffee did you brew?")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text("Select your coffee for personalized recommendations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showingCoffeeSelection = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("select_coffee".localized)
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private var isBalancedSelected: Bool {
        feedbackData.defect == Self.balancedValue
    }
    
    private var canSubmit: Bool {
        // At least overall rating or taste (1–5) should be provided
        return feedbackData.overallRating > 0 ||
               feedbackData.followedRecipe != nil ||
               feedbackData.brewTimeMatch != nil ||
               feedbackData.flowRate != nil ||
               (feedbackData.acidityLevel >= 1 && feedbackData.acidityLevel <= 5) ||
               (feedbackData.sweetnessLevel >= 1 && feedbackData.sweetnessLevel <= 5) ||
               (feedbackData.bodyLevel >= 1 && feedbackData.bodyLevel <= 5) ||
               !feedbackData.flavorNotes.isEmpty ||
               feedbackData.adjustNextTime != nil ||
               !feedbackData.adjustmentAreas.isEmpty ||
               !feedbackData.additionalNotes.isEmpty
    }
    
    private func submitFeedback() {
        // Create detailed feedback
        let detailedFeedback = DetailedBrewFeedback(
            recipeId: recipe.id,
            recipeTitle: recipe.title,
            brewingMethod: recipe.brewingMethod,
            feedbackData: feedbackData,
            date: Date()
        )
        
        // Create brew record
        let brew = Brew(
            recipeTitle: recipe.title,
            brewingMethod: recipe.brewingMethod,
            coffeeDose: brewParameters.coffeeDose,
            waterAmount: brewParameters.waterAmount,
            waterTemperature: brewParameters.waterTemperature,
            grindSize: brewParameters.grindSize,
            brewTime: brewParameters.brewTime,
            feedbackData: feedbackData,
            tasteRating: Int(feedbackData.overallRating),
            strengthRating: Int(round((feedbackData.bodyLevel - 1))),  // 1–5 → 0–4 (was from bitterness)
            acidityRating: Int(round(feedbackData.acidityLevel - 1)),  // 1–5 → 0–4
            notes: feedbackData.additionalNotes,
            date: Date(),
            coffeeID: effectiveCoffee?.id,  // AEC-12: Link to coffee
            defect: feedbackData.defect,
            adjustment: feedbackData.diagnosticAdvice
        )
        
        // Save both detailed feedback and brew record
        storageService.saveDetailedFeedback(detailedFeedback)
        storageService.saveBrew(brew)
        
        // AEC-12: Generate smart diagnostics and navigate to recommendations
        diagnosticResult = SmartDiagnosticService.shared.diagnose(
            coffee: effectiveCoffee,
            recipe: recipe,
            feedback: feedbackData
        )
        showingRecommendations = true
    }
    
    private func updateDefect(_ option: String) {
        feedbackData.defect = option
        
        if option == Self.balancedValue {
            feedbackData.diagnosticAdvice = nil
            return
        }
        
        // Map UI string to internal key
        let key: String
        switch option {
        case "Sour/Tart": key = "sour"
        case "Bitter/Dry": key = "bitter"
        case "Weak/Watery": key = "weak"
        case "Strong/Heavy": key = "strong"
        case "Hollow": key = "hollow"
        default: key = "none"
        }
        
        if let advice = DiagnosticService.shared.diagnose(defect: key, method: recipe.brewingMethod) {
            feedbackData.diagnosticAdvice = "\(advice.action) (\(advice.reason))"
        }
    }
}

// MARK: - Supporting Views

struct FeedbackSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            content
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MultipleChoiceQuestion: View {
    let id: String
    let label: String
    let options: [String]
    @Binding var selection: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                    }) {
                        HStack {
                            Image(systemName: selection == option ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selection == option ? .orange : .gray)
                            Text(option)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(12)
                        .background(selection == option ? Color.orange.opacity(0.1) : Color(.systemGray5))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct SliderQuestion: View {
    let id: String
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(Int(value))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $value, in: range, step: 1)
                .accentColor(.orange)
        }
    }
}

struct TagsQuestion: View {
    let id: String
    let label: String
    let options: [String]
    @Binding var selectedTags: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        if selectedTags.contains(option) {
                            selectedTags.remove(option)
                        } else {
                            selectedTags.insert(option)
                        }
                    }) {
                        Text(option)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTags.contains(option) ? Color.orange : Color(.systemGray5))
                            .foregroundColor(selectedTags.contains(option) ? .white : .primary)
                            .cornerRadius(16)
                    }
                }
            }
        }
    }
}

struct CheckboxQuestion: View {
    let id: String
    let label: String
    let options: [String]
    @Binding var selectedOptions: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        if selectedOptions.contains(option) {
                            selectedOptions.remove(option)
                        } else {
                            selectedOptions.insert(option)
                        }
                    }) {
                        HStack {
                            Image(systemName: selectedOptions.contains(option) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selectedOptions.contains(option) ? .orange : .gray)
                            Text(option)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(12)
                        .background(selectedOptions.contains(option) ? Color.orange.opacity(0.1) : Color(.systemGray5))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// MARK: - Expected Profile Card

struct ExpectedProfileCard: View {
    let coffee: Coffee
    let expectedProfile: ExtractionCharacteristics
    
    var body: some View {
        FeedbackSection(title: "expected_profile".localized) {
            VStack(alignment: .leading, spacing: 16) {
                // Expected flavor notes from coffee
                if !coffee.flavorTags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("expected_flavor_notes".localized)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(coffee.flavorTags) { tag in
                                FlavorTagButton(
                                    tag: tag,
                                    isSelected: true  // Always show as "expected"
                                ) {
                                    // Read-only, no action
                                }
                                .opacity(0.8)
                            }
                        }
                    }
                }
                
                // Expected characteristics
                VStack(alignment: .leading, spacing: 12) {
                    Text("you_should_taste".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        characteristicRow(
                            label: "Acidity",
                            value: expectedProfile.acidity,
                            icon: "bolt.fill",
                            color: .yellow
                        )
                        characteristicRow(
                            label: "Sweetness",
                            value: expectedProfile.sweetness,
                            icon: "sparkles",
                            color: .orange
                        )
                        characteristicRow(
                            label: "Body",
                            value: expectedProfile.body,
                            icon: "drop.fill",
                            color: .brown
                        )
                    }
                }
            }
        }
    }
    
    private func characteristicRow(label: String, value: Double, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Visual indicator
            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index < Int(value * 5) ? color : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

struct TextAreaQuestion: View {
    let id: String
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
            
            TextEditor(text: $text)
                .frame(minHeight: 80)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

struct OverallRatingQuestion: View {
    let id: String
    let label: String
    @Binding var rating: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(Int(rating))★")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        rating = Double(star)
                    }) {
                        Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(star <= Int(rating) ? .orange : .gray)
                    }
                }
            }
        }
    }
}

// MARK: - Flavor Tag Feedback View

struct FlavorTagFeedbackView: View {
    let coffee: Coffee
    @Binding var experiencedTags: Set<FlavorTag>
    
    var body: some View {
        FeedbackSection(title: "flavor_notes_experienced".localized) {
            VStack(alignment: .leading, spacing: 16) {
                Text("did_you_taste_note".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                    ForEach(coffee.flavorTags) { tag in
                        FlavorTagFeedbackButton(
                            tag: tag,
                            isExperienced: experiencedTags.contains(tag),
                            onToggle: {
                                if experiencedTags.contains(tag) {
                                    experiencedTags.remove(tag)
                                } else {
                                    experiencedTags.insert(tag)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

struct FlavorTagFeedbackButton: View {
    let tag: FlavorTag
    let isExperienced: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: isExperienced ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isExperienced ? .orange : .gray)
                
                Text(tag.rawValue)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(12)
            .background(isExperienced ? Color.orange.opacity(0.1) : Color(.systemGray5))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isExperienced ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Data Models

struct FeedbackData: Codable {
    // Overall Rating
    var overallRating: Double = 0
    
    // Brew Execution
    var followedRecipe: String?
    var brewTimeMatch: String?
    var flowRate: String?
    
    // Sensory Defect (AEC-11)
    var defect: String?
    var diagnosticAdvice: String? // Store the generated advice
    
    /// True when no defect selected: "Balanced", "None (Balanced)", "none", or nil. Use for backward compatibility.
    static func isNoDefect(_ value: String?) -> Bool {
        guard let v = value, !v.isEmpty else { return true }
        return v == "Balanced" || v == "None (Balanced)" || v.lowercased() == "none"
    }
    
    // Taste Profile (1–5 scale; Acidity, Sweetness, Body only. Bitterness deprecated.)
    var acidityLevel: Double = 3
    var sweetnessLevel: Double = 3
    var bodyLevel: Double = 3
    /// Legacy decode only. New UI uses bodyLevel (1–5).
    var body: String?
    /// Deprecated. Keep for legacy decode; never set by new UI.
    var bitternessLevel: Double = 0.5
    var flavorNotes: Set<String> = []
    
    // Flavor Tags Experienced (based on coffee's expected flavor tags)
    var experiencedFlavorTags: Set<FlavorTag> = []
    
    // Adjustment Suggestions
    var adjustNextTime: String?
    var adjustmentAreas: Set<String> = []
    var additionalNotes: String = ""
    
    enum CodingKeys: String, CodingKey {
        case overallRating, followedRecipe, brewTimeMatch, flowRate
        case defect, diagnosticAdvice
        case acidityLevel, sweetnessLevel, bitternessLevel, body, bodyLevel
        case flavorNotes, experiencedFlavorTags, adjustNextTime, adjustmentAreas, additionalNotes
    }
    
    init(
        overallRating: Double = 0,
        followedRecipe: String? = nil,
        brewTimeMatch: String? = nil,
        flowRate: String? = nil,
        defect: String? = nil,
        diagnosticAdvice: String? = nil,
        acidityLevel: Double = 3,
        sweetnessLevel: Double = 3,
        bodyLevel: Double = 3,
        body: String? = nil,
        bitternessLevel: Double = 0.5,
        flavorNotes: Set<String> = [],
        experiencedFlavorTags: Set<FlavorTag> = [],
        adjustNextTime: String? = nil,
        adjustmentAreas: Set<String> = [],
        additionalNotes: String = ""
    ) {
        self.overallRating = overallRating
        self.followedRecipe = followedRecipe
        self.brewTimeMatch = brewTimeMatch
        self.flowRate = flowRate
        self.defect = defect
        self.diagnosticAdvice = diagnosticAdvice
        self.acidityLevel = acidityLevel
        self.sweetnessLevel = sweetnessLevel
        self.bodyLevel = bodyLevel
        self.body = body
        self.bitternessLevel = bitternessLevel
        self.flavorNotes = flavorNotes
        self.experiencedFlavorTags = experiencedFlavorTags
        self.adjustNextTime = adjustNextTime
        self.adjustmentAreas = adjustmentAreas
        self.additionalNotes = additionalNotes
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        overallRating = try c.decodeIfPresent(Double.self, forKey: .overallRating) ?? 0
        followedRecipe = try c.decodeIfPresent(String.self, forKey: .followedRecipe)
        brewTimeMatch = try c.decodeIfPresent(String.self, forKey: .brewTimeMatch)
        flowRate = try c.decodeIfPresent(String.self, forKey: .flowRate)
        defect = try c.decodeIfPresent(String.self, forKey: .defect)
        diagnosticAdvice = try c.decodeIfPresent(String.self, forKey: .diagnosticAdvice)
        bitternessLevel = try c.decodeIfPresent(Double.self, forKey: .bitternessLevel) ?? 0.5
        body = try c.decodeIfPresent(String.self, forKey: .body)
        
        let a = try c.decodeIfPresent(Double.self, forKey: .acidityLevel) ?? 3
        acidityLevel = a <= 1 ? a * 4 + 1 : a
        let s = try c.decodeIfPresent(Double.self, forKey: .sweetnessLevel) ?? 3
        sweetnessLevel = s <= 1 ? s * 4 + 1 : s
        
        if let bl = try c.decodeIfPresent(Double.self, forKey: .bodyLevel) {
            bodyLevel = bl
        } else {
            let b0 = Self.bodyToBodyLevel(body)
            bodyLevel = b0
        }
        
        flavorNotes = try c.decodeIfPresent(Set<String>.self, forKey: .flavorNotes) ?? []
        experiencedFlavorTags = try c.decodeIfPresent(Set<FlavorTag>.self, forKey: .experiencedFlavorTags) ?? []
        adjustNextTime = try c.decodeIfPresent(String.self, forKey: .adjustNextTime)
        adjustmentAreas = try c.decodeIfPresent(Set<String>.self, forKey: .adjustmentAreas) ?? []
        additionalNotes = try c.decodeIfPresent(String.self, forKey: .additionalNotes) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(overallRating, forKey: .overallRating)
        try c.encodeIfPresent(followedRecipe, forKey: .followedRecipe)
        try c.encodeIfPresent(brewTimeMatch, forKey: .brewTimeMatch)
        try c.encodeIfPresent(flowRate, forKey: .flowRate)
        try c.encodeIfPresent(defect, forKey: .defect)
        try c.encodeIfPresent(diagnosticAdvice, forKey: .diagnosticAdvice)
        try c.encode(acidityLevel, forKey: .acidityLevel)
        try c.encode(sweetnessLevel, forKey: .sweetnessLevel)
        try c.encode(bodyLevel, forKey: .bodyLevel)
        try c.encodeIfPresent(Self.bodyLevelToBody(bodyLevel), forKey: .body)
        try c.encode(bitternessLevel, forKey: .bitternessLevel)
        try c.encode(flavorNotes, forKey: .flavorNotes)
        try c.encode(experiencedFlavorTags, forKey: .experiencedFlavorTags)
        try c.encodeIfPresent(adjustNextTime, forKey: .adjustNextTime)
        try c.encode(adjustmentAreas, forKey: .adjustmentAreas)
        try c.encode(additionalNotes, forKey: .additionalNotes)
    }
    
    /// Legacy body string → 1–5. light→1.5, medium→3, full→4.5.
    private static func bodyToBodyLevel(_ body: String?) -> Double {
        guard let b = body?.lowercased() else { return 3 }
        switch b {
        case "light", "ligero": return 1.5
        case "medium", "medio": return 3
        case "full", "completo": return 4.5
        default: return 3
        }
    }
    
    /// 1–5 → legacy body string for encoding.
    private static func bodyLevelToBody(_ bodyLevel: Double) -> String? {
        if bodyLevel < 2.25 { return "light" }
        if bodyLevel < 3.75 { return "medium" }
        return "full"
    }
}

struct DetailedBrewFeedback: Codable {
    let recipeId: UUID
    let recipeTitle: String
    let brewingMethod: String
    let feedbackData: FeedbackData
    let date: Date
}

// MARK: - Helper Functions

private func formatRecipeTitle(_ title: String) -> String {
    // Remove or replace dashes with more readable separators
    return title.replacingOccurrences(of: " - ", with: " • ")
}

// MARK: - Coffee Selection Sheet (AEC-12)

struct CoffeeSelectionSheet: View {
    @Binding var selectedCoffee: Coffee?
    @StateObject private var repository = CoffeeRepository.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Option to clear selection
                Button(action: {
                    selectedCoffee = nil
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                        Text("No Coffee (Generic Recommendations)")
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedCoffee == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // List of saved coffees
                Section(header: Text("Your Coffees")) {
                    if repository.coffees.isEmpty {
                        Text("No coffees saved yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(repository.coffees) { coffee in
                            Button(action: {
                                selectedCoffee = coffee
                                dismiss()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(coffee.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("\(coffee.roaster) • \(coffee.roastLevel.rawValue)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if selectedCoffee?.id == coffee.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("select_coffee".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            repository.load()
        }
    }
}

#Preview {
    NavigationView {
        FeedbackScreen(recipe: Recipe.sampleRecipe, brewParameters: BrewParameters.sampleBrewParameters)
    }
}
