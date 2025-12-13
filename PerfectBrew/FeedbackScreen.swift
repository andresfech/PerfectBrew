import SwiftUI

struct FeedbackScreen: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var storageService = StorageService()
    @State private var showingThankYou = false
    @State private var feedbackData = FeedbackData()
    @State private var showingRecommendations = false  // AEC-12
    @State private var diagnosticResult: BrewDiagnosticResult?  // AEC-12
    @State private var showingCoffeeSelection = false  // AEC-12
    let recipe: Recipe
    let brewParameters: BrewParameters
    var coffee: Coffee? = nil  // AEC-12: Optional coffee for smart recommendations
    @State private var selectedCoffee: Coffee? = nil  // AEC-12: Local selection if not passed
    
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
                
                // Diagnostic Section (AEC-11)
                FeedbackSection(title: "Diagnosis") {
                    VStack(spacing: 16) {
                        Text("How did it taste?")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(["None (Balanced)", "Sour/Tart", "Bitter/Dry", "Weak/Watery", "Strong/Heavy", "Hollow"], id: \.self) { option in
                                Button(action: {
                                    updateDefect(option)
                                }) {
                                    Text(option)
                                        .font(.caption)
                                        .padding(12)
                                        .frame(maxWidth: .infinity)
                                        .background(feedbackData.defect == option ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(feedbackData.defect == option ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        if let advice = feedbackData.diagnosticAdvice {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("💡 Suggestion for Next Time:")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                Text(advice)
                                    .font(.body)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .transition(.opacity)
                        }
                    }
                }
                
                // Taste Profile Section
                FeedbackSection(title: "taste_profile".localized) {
                    VStack(spacing: 20) {
                        SliderQuestion(
                            id: "sweetness_level",
                            label: "sweetness_level".localized,
                            value: $feedbackData.sweetnessLevel,
                            range: 0...5
                        )
                        
                        SliderQuestion(
                            id: "bitterness_level",
                            label: "bitterness_level".localized,
                            value: $feedbackData.bitternessLevel,
                            range: 0...5
                        )
                        
                        SliderQuestion(
                            id: "acidity_level",
                            label: "acidity_level".localized,
                            value: $feedbackData.acidityLevel,
                            range: 0...5
                        )
                        
                        MultipleChoiceQuestion(
                            id: "body",
                            label: "body_mouthfeel".localized,
                            options: ["light".localized, "medium".localized, "full".localized],
                            selection: $feedbackData.body
                        )
                        
                        TagsQuestion(
                            id: "flavor_notes",
                            label: "flavor_notes".localized,
                            options: ["fruity".localized, "chocolaty".localized, "nutty".localized, "earthy".localized, "floral".localized, "spicy".localized, "herbal".localized],
                            selectedTags: $feedbackData.flavorNotes
                        )
                    }
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
        }
    }
    
    // MARK: - Effective Coffee (AEC-12)
    
    private var effectiveCoffee: Coffee? {
        selectedCoffee ?? coffee
    }
    
    // MARK: - Coffee Selection Card (AEC-12)
    
    private var coffeeSelectionCard: some View {
        VStack(spacing: 12) {
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
    
    private var canSubmit: Bool {
        // At least overall rating should be provided
        return feedbackData.overallRating > 0 ||
               feedbackData.followedRecipe != nil ||
               feedbackData.brewTimeMatch != nil ||
               feedbackData.flowRate != nil ||
               feedbackData.sweetnessLevel > 0 ||
               feedbackData.bitternessLevel > 0 ||
               feedbackData.acidityLevel > 0 ||
               feedbackData.body != nil ||
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
            strengthRating: Int(feedbackData.bitternessLevel),
            acidityRating: Int(feedbackData.acidityLevel),
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
        
        if option == "None (Balanced)" {
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
    
    // Taste Profile
    var sweetnessLevel: Double = 0
    var bitternessLevel: Double = 0
    var acidityLevel: Double = 0
    var body: String?
    var flavorNotes: Set<String> = []
    
    // Adjustment Suggestions
    var adjustNextTime: String?
    var adjustmentAreas: Set<String> = []
    var additionalNotes: String = ""
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
