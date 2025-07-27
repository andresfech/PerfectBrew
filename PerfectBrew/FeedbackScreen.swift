import SwiftUI

struct FeedbackScreen: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var storageService = StorageService()
    @State private var showingThankYou = false
    @State private var feedbackData = FeedbackData()
    let recipe: Recipe
    let brewParameters: BrewParameters
    
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
                
                // Recipe Info
                VStack(spacing: 12) {
                    Text(recipe.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(recipe.brewingMethod)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 10)
                
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
        .alert("thank_you".localized, isPresented: $showingThankYou) {
            Button("ok".localized) {
                // Navigate back to home or dismiss
            }
        } message: {
            Text("feedback_submitted".localized)
        }
    }
    
    private var canSubmit: Bool {
        // At least one input should be provided
        return feedbackData.followedRecipe != nil ||
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
            tasteRating: Int(feedbackData.sweetnessLevel),
            strengthRating: Int(feedbackData.bitternessLevel),
            acidityRating: Int(feedbackData.acidityLevel),
            notes: feedbackData.additionalNotes,
            date: Date()
        )
        
        // Save both detailed feedback and brew record
        storageService.saveDetailedFeedback(detailedFeedback)
        storageService.saveBrew(brew)
        
        showingThankYou = true
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

// MARK: - Data Models

struct FeedbackData: Codable {
    // Brew Execution
    var followedRecipe: String?
    var brewTimeMatch: String?
    var flowRate: String?
    
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

#Preview {
    NavigationView {
        FeedbackScreen(recipe: Recipe.sampleRecipe, brewParameters: BrewParameters.sampleBrewParameters)
    }
}
