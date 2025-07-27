import SwiftUI

struct BrewHistoryScreen: View {
    @ObservedObject private var storageService = StorageService()
    @State private var brews: [Brew] = []

    var body: some View {
        NavigationView {
            List(brews) { brew in
                NavigationLink(destination: BrewHistoryDetailView(brew: brew)) {
                    VStack(alignment: .leading) {
                        Text("Brew on \(brew.date, formatter: dateFormatter)")
                            .font(.headline)
                        Text("Rating: \(brew.tasteRating) Stars")
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Brew History")
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
            Section(header: Text("Parameters")) {
                HStack {
                    Text("Coffee Dose")
                    Spacer()
                    Text("\(brew.coffeeDose, specifier: "%.1f")g")
                }
                HStack {
                    Text("Water Amount")
                    Spacer()
                    Text("\(brew.waterAmount, specifier: "%.0f")ml")
                }
                HStack {
                    Text("Water Temperature")
                    Spacer()
                    Text("\(brew.waterTemperature, specifier: "%.0f")°C")
                }
                HStack {
                    Text("Grind Size")
                    Spacer()
                    Text("\(brew.grindSize)")
                }
                HStack {
                    Text("Brew Time")
                    Spacer()
                    Text("\(brew.brewTime, specifier: "%.0f")s")
                }
            }
            
            Section(header: Text("Ratings")) {
                HStack {
                    Text("Taste")
                    Spacer()
                    Text("\(brew.tasteRating) stars")
                }
                HStack {
                    Text("Strength")
                    Spacer()
                    Text("\(brew.strengthRating) stars")
                }
                HStack {
                    Text("Acidity")
                    Spacer()
                    Text("\(brew.acidityRating) stars")
                }
            }
            
            if !brew.notes.isEmpty {
                Section(header: Text("Notes")) {
                    Text(brew.notes)
                }
            }
            
            Section(header: Text("Date")) {
                Text(brew.date, formatter: dateFormatter)
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
