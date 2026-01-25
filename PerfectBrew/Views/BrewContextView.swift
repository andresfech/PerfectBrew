import SwiftUI

struct BrewContextView: View {
    @ObservedObject var viewModel: BrewingGuideViewModel
    @StateObject private var repository = CoffeeRepository.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select Coffee for Logging")) {
                    Button(action: {
                        viewModel.selectedCoffee = nil
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("Don't Log Coffee")
                                .foregroundColor(.primary)
                            if viewModel.selectedCoffee == nil {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    ForEach(repository.coffees) { coffee in
                        Button(action: {
                            viewModel.selectedCoffee = coffee
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(coffee.name)
                                        .font(.headline)
                                    Text(coffee.roaster)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if viewModel.selectedCoffee?.id == coffee.id {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Which Coffee?")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            repository.load()
        }
    }
}


