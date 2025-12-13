import SwiftUI

struct RecommendationsView: View {
    @StateObject var viewModel: RecommendationsViewModel
    
    init(coffee: Coffee) {
        _viewModel = StateObject(wrappedValue: RecommendationsViewModel(coffee: coffee))
    }
    
    var body: some View {
        List {
            Section(header: Text("Best Matches for \(viewModel.coffee.name)")) {
                if viewModel.recommendations.isEmpty {
                    Text("No recommendations found.")
                } else {
                    ForEach(viewModel.recommendations) { recommendation in
                        NavigationLink(destination: BrewDetailScreen(recipe: recommendation.recipe)) {
                            RecommendationRow(recommendation: recommendation)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Recommendations")
    }
}

struct RecommendationRow: View {
    let recommendation: Recommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(recommendation.recipe.localizedTitle)
                    .font(.headline)
                Spacer()
                
                // Match Score Badge
                Text("\(recommendation.score)%")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(scoreColor(recommendation.score))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            Text(recommendation.recipe.brewingMethod)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Reasons
            if !recommendation.reasons.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(recommendation.reasons, id: \.self) { reason in
                            let isWarning = reason.contains("Warning")
                            Text(reason)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(isWarning ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                                .foregroundColor(isWarning ? .red : .blue)
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .orange
        default: return .gray
        }
    }
}

