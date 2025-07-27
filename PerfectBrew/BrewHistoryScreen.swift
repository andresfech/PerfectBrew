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
            .navigationTitle("Brew Log")
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
                    Text("Sweetness")
                    Spacer()
                    Text("\(Int(brew.feedbackData.sweetnessLevel))★")
                        .foregroundColor(.orange)
                }
                HStack {
                    Text("Bitterness")
                    Spacer()
                    Text("\(Int(brew.feedbackData.bitternessLevel))★")
                        .foregroundColor(.orange)
                }
                HStack {
                    Text("Acidity")
                    Spacer()
                    Text("\(Int(brew.feedbackData.acidityLevel))★")
                        .foregroundColor(.orange)
                }
                
                if let body = brew.feedbackData.body {
                    HStack {
                        Text("Body")
                        Spacer()
                        Text(body)
                            .foregroundColor(.secondary)
                    }
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
        }
        .navigationTitle("Brew Details")
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
}
