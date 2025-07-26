import SwiftUI

struct FeedbackScreen: View {
    @State private var tasteRating: Int = 3
    @State private var strengthRating: Int = 3
    @State private var acidityRating: Int = 3
    @State private var notes: String = ""
    @State private var showingSuccess = false
    @ObservedObject private var storageService = StorageService()
    
    let coffeeDose: Double
    let waterAmount: Double
    let waterTemperature: Double
    let grindSize: Int
    let brewTime: TimeInterval

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ratings")) {
                    Picker("Taste", selection: $tasteRating) {
                        ForEach(1...5, id: \.self) {
                            Text("\($0) star\($0 > 1 ? "s" : "")")
                        }
                    }
                    Picker("Strength", selection: $strengthRating) {
                        ForEach(1...5, id: \.self) {
                            Text("\($0) star\($0 > 1 ? "s" : "")")
                        }
                    }
                    Picker("Acidity", selection: $acidityRating) {
                        ForEach(1...5, id: \.self) {
                            Text("\($0) star\($0 > 1 ? "s" : "")")
                        }
                    }
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Button(action: {
                    let brew = Brew(
                        coffeeDose: coffeeDose,
                        waterAmount: waterAmount,
                        waterTemperature: waterTemperature,
                        grindSize: grindSize,
                        brewTime: brewTime,
                        tasteRating: tasteRating,
                        strengthRating: strengthRating,
                        acidityRating: acidityRating,
                        notes: notes,
                        date: Date()
                    )
                    
                    var brews = storageService.loadBrews()
                    brews.append(brew)
                    storageService.saveBrews(brews)
                    showingSuccess = true
                }) {
                    Text("Save to History")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Feedback")
            .alert("Brew Saved!", isPresented: $showingSuccess) {
                Button("OK") { }
            } message: {
                Text("Your brew has been saved to history.")
            }
        }
    }
}
