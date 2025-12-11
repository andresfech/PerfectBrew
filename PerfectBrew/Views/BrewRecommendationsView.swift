import SwiftUI

/// Displays UNIFIED brew recommendations after feedback submission (AEC-12 v2)
/// All adjustments align to ONE direction - no contradictions
struct BrewRecommendationsView: View {
    let result: BrewDiagnosticResult
    let recipe: Recipe
    let coffee: Coffee?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Direction Header (AEC-12 v2)
                directionHeader
                
                // Summary Card
                summaryCard
                
                // Expected vs Actual (if coffee context available)
                if result.hasCoffeeContext, let expected = result.expectedProfile {
                    comparisonCard(expected: expected, actual: result.actualProfile)
                }
                
                // Unified Adjustments List
                if !result.unifiedAdjustment.adjustments.isEmpty {
                    adjustmentsSection
                } else {
                    noAdjustmentsView
                }
                
                // Done Button
                doneButton
            }
            .padding(20)
        }
        .navigationTitle("Brew Analysis")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Direction Header (AEC-12 v2)
    
    private var directionHeader: some View {
        VStack(spacing: 16) {
            // Direction Icon with Arrow
            ZStack {
                Circle()
                    .fill(directionColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: result.direction.icon)
                    .font(.system(size: 36))
                    .foregroundColor(directionColor)
            }
            
            // Direction Title
            Text(result.direction.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Confidence Bar
            VStack(spacing: 6) {
                HStack {
                    Text("Confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(result.assessmentConfidence * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(directionColor)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(directionColor)
                            .frame(width: geo.size.width * result.assessmentConfidence, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(directionColor.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var directionColor: Color {
        switch result.direction {
        case .increase: return .orange
        case .decrease: return .blue
        case .adjustStrength: return .green
        case .improveTechnique: return .purple
        case .balanced: return .green
        }
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("What This Means")
                    .font(.headline)
            }
            
            Text(result.unifiedAdjustment.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Comparison Card
    
    private func comparisonCard(expected: ExtractionCharacteristics, actual: ActualTasteProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(.blue)
                Text("Expected vs Actual")
                    .font(.headline)
                Spacer()
                if let coffee = coffee {
                    Text(coffee.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 12) {
                comparisonRow(label: "Acidity", expected: expected.acidity, actual: actual.acidity)
                comparisonRow(label: "Sweetness", expected: expected.sweetness, actual: actual.sweetness)
                comparisonRow(label: "Body", expected: expected.body, actual: actual.body)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func comparisonRow(label: String, expected: Double, actual: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                gapIndicator(expected: expected, actual: actual)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                        .offset(x: CGFloat(expected) * (geometry.size.width - 12))
                    
                    Circle()
                        .stroke(Color.orange, lineWidth: 2)
                        .background(Circle().fill(Color.orange.opacity(0.3)))
                        .frame(width: 12, height: 12)
                        .offset(x: CGFloat(actual) * (geometry.size.width - 12))
                }
            }
            .frame(height: 12)
            
            HStack {
                HStack(spacing: 4) {
                    Circle().fill(Color.blue).frame(width: 6, height: 6)
                    Text("Expected").font(.caption2).foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Circle().stroke(Color.orange, lineWidth: 1).frame(width: 6, height: 6)
                    Text("Actual").font(.caption2).foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func gapIndicator(expected: Double, actual: Double) -> some View {
        let gap = expected - actual
        let absGap = abs(gap)
        
        if absGap < 0.1 {
            return AnyView(
                Text("✓ Match")
                    .font(.caption)
                    .foregroundColor(.green)
            )
        } else if gap > 0 {
            return AnyView(
                Text("↓ Under")
                    .font(.caption)
                    .foregroundColor(.orange)
            )
        } else {
            return AnyView(
                Text("↑ Over")
                    .font(.caption)
                    .foregroundColor(.red)
            )
        }
    }
    
    // MARK: - Adjustments Section (AEC-12 v2 - Unified)
    
    private var adjustmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.number")
                    .foregroundColor(directionColor)
                Text("Try These Adjustments")
                    .font(.headline)
                Spacer()
                Text("All \(result.direction.actionVerb)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Direction indicator bar
            HStack(spacing: 4) {
                ForEach(0..<result.unifiedAdjustment.adjustments.count, id: \.self) { _ in
                    Image(systemName: result.direction == .increase ? "arrow.up" : (result.direction == .decrease ? "arrow.down" : "arrow.right"))
                        .font(.caption2)
                        .foregroundColor(directionColor)
                }
                Text("unified direction")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(directionColor.opacity(0.1))
            .cornerRadius(4)
            
            // Adjustment cards
            ForEach(result.unifiedAdjustment.adjustments) { item in
                adjustmentCard(item)
            }
        }
    }
    
    private func adjustmentCard(_ item: AdjustmentItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Rank badge with impact
            VStack(spacing: 4) {
                Text("\(item.rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(rankColor(item.rank))
                    .clipShape(Circle())
                
                Text("\(item.impactPercent)%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Parameter and change
                HStack {
                    Image(systemName: item.category.icon)
                        .foregroundColor(categoryColor(item.category))
                    Text(item.parameter)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(item.suggestedChange)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Explanation
                Text(item.explanation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .green
        }
    }
    
    private func categoryColor(_ category: RecommendationCategory) -> Color {
        switch category {
        case .grind: return .orange
        case .temperature: return .red
        case .time: return .blue
        case .ratio: return .green
        case .technique: return .purple
        case .dose: return .brown
        }
    }
    
    // MARK: - No Adjustments
    
    private var noAdjustmentsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("Great Brew!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your brew is well-balanced. Keep doing what you're doing!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Done Button
    
    private var doneButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text("Done")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(directionColor)
                .cornerRadius(12)
        }
        .padding(.top, 10)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        BrewRecommendationsView(
            result: BrewDiagnosticResult(
                overallAssessment: .underExtracted,
                assessmentConfidence: 0.78,
                expectedProfile: ExtractionCharacteristics(
                    clarity: 0.8, acidity: 0.8, sweetness: 0.6, body: 0.3
                ),
                actualProfile: ActualTasteProfile(
                    acidity: 0.4, sweetness: 0.3, bitterness: 0.2, body: 0.4
                ),
                hasCoffeeContext: true,
                unifiedAdjustment: UnifiedBrewAdjustment(
                    direction: .increase,
                    confidence: 0.78,
                    summary: "Your Ethiopia Yirgacheffe needs more extraction to bring out its full potential",
                    adjustments: [
                        AdjustmentItem(
                            rank: 1,
                            category: .grind,
                            parameter: "Grind Size",
                            suggestedChange: "Grind 2 clicks finer",
                            impactPercent: 90,
                            explanation: "Finer grind increases surface area, allowing more extraction"
                        ),
                        AdjustmentItem(
                            rank: 2,
                            category: .temperature,
                            parameter: "Water Temperature",
                            suggestedChange: "Increase to 96-98°C",
                            impactPercent: 75,
                            explanation: "Hotter water extracts compounds faster and more completely"
                        ),
                        AdjustmentItem(
                            rank: 3,
                            category: .time,
                            parameter: "Brew Time",
                            suggestedChange: "Extend total brew time",
                            impactPercent: 60,
                            explanation: "More time allows more flavor compounds to dissolve"
                        )
                    ]
                ),
                recommendations: []
            ),
            recipe: Recipe.sampleRecipe,
            coffee: Coffee(
                name: "Ethiopia Yirgacheffe",
                roaster: "Test Roaster",
                roastLevel: .light,
                process: .washed,
                flavorTags: [.floral, .citrus]
            )
        )
    }
}
