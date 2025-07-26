import SwiftUI

struct BrewHistoryScreen: View {
    @ObservedObject private var storageService = StorageService()
    @State private var brews: [Brew] = []

    var body: some View {
        NavigationView {
            List(brews) { brew in
                NavigationLink(destination: BrewDetailScreen(brew: brew)) {
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
