import SwiftUI

struct BrewHistoryScreen: View {
    @ObservedObject private var storageService = StorageService()
    @State private var brews: [Brew] = []

    var body: some View {
        NavigationView {
            List(brews.reversed()) { brew in
                NavigationLink(destination: BrewHistoryDetailView(brew: brew)) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(brew.recipeTitle)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(brew.overallRating)★")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        
                        Text(brew.brewingMethod)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(brew.date, formatter: dateFormatter)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("brew_log".localized)
            .onAppear(perform: loadBrews)
        }
    }
    
    private func loadBrews() {
        brews = storageService.loadBrews()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

struct BrewHistoryDetailView: View {
    let brew: Brew
    
    @StateObject private var recipeDatabase = RecipeDatabase.shared
    @StateObject private var coffeeRepository = CoffeeRepository.shared
    @State private var recipe: Recipe?
    @State private var coffee: Coffee?
    @State private var showingRecommendations = false
    @State private var diagnosticResult: BrewDiagnosticResult?
    @State private var isLoadingRecommendations = false
    
    var body: some View {
        Form {
            Section(header: Text("Recipe")) {
                HStack {
                    Text("Recipe")
                    Spacer()
                    Text(brew.recipeTitle)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Method")
                    Spacer()
                    Text(brew.brewingMethod)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Parameters")) {
                HStack {
                    Text("Coffee Dose")
                    Spacer()
                    Text("\(brew.coffeeDose, specifier: "%.1f")g")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Water Amount")
                    Spacer()
                    Text("\(brew.waterAmount, specifier: "%.0f")ml")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Water Temperature")
                    Spacer()
                    Text("\(brew.waterTemperature, specifier: "%.0f")°C")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Grind Size")
                    Spacer()
                    Text("\(brew.grindSize)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Brew Time")
                    Spacer()
                    Text("\(brew.brewTime, specifier: "%.0f")s")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Taste Profile")) {
                HStack {
                    Text("Acidity")
                    Spacer()
                    Text(comparativeLabel(for: brew.feedbackData.acidityLevel).localized)
                        .foregroundColor(.orange)
                        .font(.subheadline)
                }
                HStack {
                    Text("Sweetness")
                    Spacer()
                    Text(comparativeLabel(for: brew.feedbackData.sweetnessLevel).localized)
                        .foregroundColor(.orange)
                        .font(.subheadline)
                }
                HStack {
                    Text("Body")
                    Spacer()
                    bodyDisplayView(brew.feedbackData)
                }
                
                if !brew.feedbackData.flavorNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Flavor Notes")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 4) {
                            ForEach(Array(brew.feedbackData.flavorNotes), id: \.self) { note in
                                Text(note)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.1))
                                    .foregroundColor(.orange)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Brew Execution")) {
                if let followedRecipe = brew.feedbackData.followedRecipe {
                    HStack {
                        Text("Followed Recipe")
                        Spacer()
                        Text(followedRecipe)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let brewTimeMatch = brew.feedbackData.brewTimeMatch {
                    HStack {
                        Text("Brew Time")
                        Spacer()
                        Text(brewTimeMatch)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let flowRate = brew.feedbackData.flowRate {
                    HStack {
                        Text("Flow Rate")
                        Spacer()
                        Text(flowRate)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !brew.feedbackData.adjustmentAreas.isEmpty {
                Section(header: Text("Adjustment Areas")) {
                    ForEach(Array(brew.feedbackData.adjustmentAreas), id: \.self) { area in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.orange)
                            Text(area)
                        }
                    }
                }
            }
            
            if !brew.feedbackData.additionalNotes.isEmpty {
                Section(header: Text("Notes")) {
                    Text(brew.feedbackData.additionalNotes)
                }
            }
            
            Section(header: Text("Date")) {
                Text(brew.date, formatter: dateFormatter)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            // Recommendations Section (AEC-12 v2)
            if recipe != nil {
                Section(header: Text("recommendations".localized)) {
                    Button(action: {
                        generateAndShowRecommendations()
                    }) {
                        HStack {
                            if isLoadingRecommendations {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.orange)
                            }
                            Text("view_brew_recommendations".localized)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .disabled(isLoadingRecommendations)
                }
            }
        }
        .navigationTitle("brew_details".localized)
        .onAppear {
            loadRecipeAndCoffee()
        }
        .background(
            NavigationLink(
                destination: Group {
                    if let result = diagnosticResult, let recipe = recipe {
                        BrewRecommendationsView(
                            result: result,
                            recipe: recipe,
                            coffee: coffee
                        )
                    } else {
                        // Fallback view if data is not ready
                        VStack(spacing: 20) {
                            ProgressView()
                            Text("Loading recommendations...")
                                .foregroundColor(.secondary)
                        }
                        .navigationTitle("Recommendations")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                },
                isActive: $showingRecommendations
            ) {
                EmptyView()
            }
        )
    }
    
    private func loadRecipeAndCoffee() {
        // Load recipe by title and method
        recipe = recipeDatabase.findRecipe(title: brew.recipeTitle, method: brew.brewingMethod)
        
        if recipe == nil {
            print("⚠️ BrewHistoryDetailView: Recipe not found - Title: '\(brew.recipeTitle)', Method: '\(brew.brewingMethod)'")
        } else {
            print("✅ BrewHistoryDetailView: Recipe found: '\(recipe!.title)'")
        }
        
        // Load coffee by ID if available
        if let coffeeID = brew.coffeeID {
            coffee = coffeeRepository.findCoffee(id: coffeeID)
            if coffee == nil {
                print("⚠️ BrewHistoryDetailView: Coffee not found for ID: \(coffeeID)")
            } else {
                print("✅ BrewHistoryDetailView: Coffee found: '\(coffee!.name)'")
            }
        } else {
            print("ℹ️ BrewHistoryDetailView: No coffeeID in brew - will generate generic recommendations")
        }
    }
    
    private func generateAndShowRecommendations() {
        guard let recipe = recipe else {
            print("❌ BrewHistoryDetailView: Cannot generate recommendations - recipe is nil")
            return
        }
        
        print("🔄 BrewHistoryDetailView: Generating recommendations...")
        isLoadingRecommendations = true
        
        // Generate recommendations using SmartDiagnosticService
        let result = SmartDiagnosticService.shared.diagnose(
            coffee: coffee,
            recipe: recipe,
            feedback: brew.feedbackData
        )
        
        print("✅ BrewHistoryDetailView: Recommendations generated successfully")
        print("   - Direction: \(result.direction.rawValue)")
        print("   - Confidence: \(result.assessmentConfidence)")
        print("   - Adjustments: \(result.unifiedAdjustment.adjustments.count)")
        print("   - Dimension Recommendations: \(result.dimensionRecommendations.count)")
        
        diagnosticResult = result
        isLoadingRecommendations = false
        showingRecommendations = true
    }
    
    /// 1–5 → not_enough / perfect / too_much. Legacy 0–1, 0–4, 0–5 supported.
    private func comparativeLabel(for value: Double) -> String {
        let norm: Double
        if value >= 1 && value <= 5 { norm = (value - 1) / 4 }
        else if value <= 1.0 { norm = value }
        else if value > 4.0 { norm = value / 5.0 }
        else { norm = value / 4.0 }
        if norm <= 0.25 { return "not_enough" }
        if norm >= 0.75 { return "too_much" }
        return "perfect"
    }
    
    @ViewBuilder private func bodyDisplayView(_ fd: FeedbackData) -> some View {
        if fd.bodyLevel >= 1 && fd.bodyLevel <= 5 {
            Text(comparativeLabel(for: fd.bodyLevel).localized)
                .foregroundColor(.orange)
                .font(.subheadline)
        } else if let b = fd.body {
            Text(b)
                .foregroundColor(.secondary)
                .font(.subheadline)
        } else {
            Text("perfect".localized)
                .foregroundColor(.orange)
                .font(.subheadline)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
}
